# longhorn-storage-network

Check for target group health:

```sh
TG_ARN=$(aws elbv2 describe-target-groups \
  --names lhnet-9345-TCP \
  --query "TargetGroups[0].TargetGroupArn" \
  --output text \
  --no-cli-pager)
aws elbv2 describe-target-health \
  --target-group-arn "$TG_ARN" \
  --query "TargetHealthDescriptions[*].[Target.Id,TargetHealth.State]" \
  --no-cli-pager
```

Grab IPs for the new instances, sorted by instance ID, and choose the first as an initializer node:

```console
$ aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=demo" "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances | [*][0] | sort_by(@, &InstanceId)[*].[InstanceId, PublicIpAddress]" \
  --no-cli-pager \
  --output text
i-00c9a0ba92ba8a969	3.138.67.154
i-037a24ea1904ce55c	3.17.74.206
i-06ef10ad01ad956c7	18.118.33.28
$ ssh ec2-user@3.138.67.154
```

Create `tmuxinator` config:

```sh
cat <<EOF > "$HOME/.config.tmuxinator/${CLUSTER_NAME}.yaml"
# ${HOME}/.config/tmuxinator/${CLUSTER_NAME}$.yml

name: $CLUSTER_NAME
root: ~/

windows:
  - editor:
      layout: even-vertical
      synchronize: after
      panes:
EOF
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=demo" "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].PublicIpAddress" \
  --no-cli-pager \
  --output text
```

Create a NAD:

```sh
kubectl apply -f -<<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: longhorn-system
---
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: storage-net
  namespace: longhorn-system
spec:
  config: '{
            "cniVersion": "0.3.1",
            "type": "bridge",
            "bridge": "lhnet-br",
            "promiscMode": true,
            "ipam": {
              "type": "whereabouts",
              "log_file": "/var/log/whereabouts.log",
              "log_level": "debug",
              "range": "192.168.0.0/16"
            }
          }'
EOF
```

Create daemonset:

```sh
kubectl apply -f -<<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: lhnet-test
  namespace: longhorn-system
spec:
  selector:
    matchLabels:
      app: lhnet-test
  template:
    metadata:
      annotations:
        k8s.v1.cni.cncf.io/networks: longhorn-system/storage-net
      labels:
        app: lhnet-test
    spec:
      containers:
      - command:
        - sleep
        - inf
        image: wbitt/network-multitool
        name: nettool
        resources: {}
EOF
```