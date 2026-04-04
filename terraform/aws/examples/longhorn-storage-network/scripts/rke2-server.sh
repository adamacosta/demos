#!/bin/bash

set -xeo pipefail

do_check_running() {
  systemctl --quiet is-active rke2-server
  return $?
}

do_check_tools() {
  tools=(aws curl nc yq)
  for tool in "${tools[@]}"; do
    command -v >/dev/null "$tool"
  done
}

do_prep_env() {
  AWS_TOKEN=$(curl -s -XPUT \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
    "http://169.254.169.254/latest/api/token")
  INSTANCE_ID=$(curl -s \
    -H "X-aws-ec2-metadata-token: $AWS_TOKEN" \
    "http://169.254.169.254/latest/meta-data/instance-id")
  # Cannot query metadata for tags because cloud provider uses
  # '/' in tags, which aws will not allow if tags are accessible
  # from metadata because '/' is a reserved character for URLs
  # See https://github.com/kubernetes/cloud-provider-aws/issues/762
  CLUSTER_NAME=$(aws ec2 describe-instances \
    --instance-id "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].Tags[?starts_with(Key, 'kubernetes.io/cluster')].Key" \
    --output text | 
    awk -F '/' '{print $3}')
  CP_LB_URL=$(aws elbv2 describe-load-balancers \
    --name "$CLUSTER_NAME" \
    --query "LoadBalancers[0].DNSName" \
    --output text)
  
  export AWS_TOKEN
  export CLUSTER_NAME
  export CP_LB_URL
  export SERVER_URL="https://${CP_LB_URL}:9345"
}

do_check_cp_listener() {
  nc --wait 1 -z "$CP_LB_URL" 6443
  return $?
}

do_check_initializer() {
  TG_ARN=$(aws elbv2 describe-target-groups \
    --names "${CLUSTER_NAME}-9345-TCP" \
    --query "TargetGroups[0].TargetGroupArn" \
    --output text)
  INITIALIZER_ID=$(aws elbv2 describe-target-health \
    --target-group-arn "$TG_ARN" \
    --query "TargetHealthDescriptions[*].Target.Id" \
    --output text | 
    sed -E 's/[[:space:]]/\n/g' | sort | head -n 1)
  if [ "$INSTANCE_ID" == "$INITIALIZER_ID" ]; then
    return 0
  else
    return 1
  fi
}

do_append_san_to_config() {
  touch /etc/rancher/rke2/config.yaml
  
  san="$CP_LB_URL" yq -i \
    '.tls-san += [strenv(san)]' \
    /etc/rancher/rke2/config.yaml
}

do_append_server_to_config() {
  server="$SERVER_URL" yq -i \
    '.server = strenv(server)' \
    /etc/rancher/rke2/config.yaml
}

do_append_token_to_config() {
  token="$1" yq -i \
    '.token = strenv(token)' \
    /etc/rancher/rke2/config.yaml
}

do_create_join_token() {
  # Creating join token rather than letting rke2 do it
  # because we would otherwise need to wait X minutes
  # for rke2 to be activated before it creates one
  JOIN_TOKEN=$(openssl rand -hex 40)
  aws secretsmanager create-secret \
    --name "${CLUSTER_NAME}/token" \
    --secret-string "$JOIN_TOKEN"
  do_append_token_to_config "$JOIN_TOKEN"
}

do_retrieve_join_token() {
  # Will be uploaded by the time supervisor is listening,
  # but beware it may take a couple minutes after rke2
  # is running on initializer before target group
  # health check admits it as a healthy target
  timeout 5m bash -c "until nc -z $CP_LB_URL 9345; do sleep 5; done"
  JOIN_TOKEN=$(aws secretsmanager get-secret-value \
    --name "${CLUSTER_NAME}/token" \
    --query "SecretString" \
    --output text)
  do_append_token_to_config "$JOIN_TOKEN"
}

do_install_rke2() {
  # Do nothing if using an AMI that already has this installed
  # Check locations installer script will use and anything else that might be in PATH
  [ -x /usr/bin/rke2 ] && return 0
  [ -x /usr/local/bin/rke2 ] && return 0
  [ -x /opt/rke2/bin/rke2 ] && return 0
  command -v >/dev/null rke2 && return 0
  curl -fsLS https://get.rke2.io | INSTALL_RKE2_CHANNEL=stable INSTALL_RKE2_TYPE=server sh -
}

do_start_rke2() {
  do_install_rke2
  systemctl enable --force rke2-server
  # If kernel or init was updated, then we need a reboot and rke2 will start
  # when the system comes back up since it is now enabled
  # This means we may miss the default user config
  dnf needs-restarting -r >/dev/null || systemctl reboot
  systemctl start --no-block rke2-server
}

do_prep_user() {
  # # wait for rke2 to be up - won't take 10 minutes, but being safe
  timeout 10m bash -c 'until [ -f /etc/rancher/rke2/rke2.yaml ]; do sleep 5; done'

  mkdir /home/ec2-user/.kube
  cp /etc/rancher/rke2/rke2.yaml /home/ec2-user/.kube/config
  chown ec2-user:ec2-user /home/ec2-user/.kube/config
}

do_create_cluster() {
  do_append_san_to_config
  do_create_join_token
  do_start_rke2
}

do_join_cluster() {
  do_append_san_to_config
  do_append_server_to_config
  do_retrieve_join_token
  do_start_rke2
}

do_main() {
  # Do nothing if rke2 is already running to make script idempotent
  do_check_running && exit 0
  do_check_tools
  do_prep_env
  # If there is an existing cluster, join it
  # Otherwise, create or join based on whether this is the initializer node
  if ! do_check_cp_listener && do_check_initializer; then
    do_create_cluster
  else
    do_join_cluster
  fi
  do_prep_user
}

do_main