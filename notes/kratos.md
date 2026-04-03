```
Not really getting anywhere on this node config:

 

Normal-looking ssh command accepted per /var/log/secure:

```
Mar 20 00:43:30 osdc04 sshd[1689]: pam_unix(sshd:session): session opened for user openspace(uid=1000) by openspace(uid=0)
Mar 20 00:43:30 osdc04 sudo[1693]: openspace : PWD=/home/openspace ; USER=root ; COMMAND=/bin/sh -c 'mkdir -p /etc/rancher/rke2/config.yaml.d#012cat <<EOF > /etc/rancher/rke2/config.yaml.d/60-rancher.yaml#012{#012  "system-default-registry": ""#012}#012EOF#012curl --insecure -fL https://rancher.jhcx.internal/system-agent-install.sh | sudo  sh -s - --server https://rancher.jhcx.internal --label cattle.io/os=linux --token ndtg9789qlpc2rpr9wb7f8x9dngtxqtq27c895gpcmlbzdlfb89w75 --ca-checksum 299862190d635dbe27ef6c2e018b1b34235816ae500a853bf762f9e5a8821ba1 --etcd --controlplane --worker'
Mar 20 00:43:30 osdc04 sudo[1693]: pam_unix(sudo:session): session opened for user root(uid=0) by openspace(uid=1000)
Mar 20 00:43:30 osdc04 sudo[1714]:    root : PWD=/home/openspace ; USER=root ; COMMAND=/bin/sh -s - --server https://rancher.jhcx.internal --label cattle.io/os=linux --token ndtg9789qlpc2rpr9wb7f8x9dngtxqtq27c895gpcmlbzdlfb89w75 --ca-checksum 299862190d635dbe27ef6c2e018b1b34235816ae500a853bf762f9e5a8821ba1 --etcd --controlplane --worker
```

Rancher System Agent going nowhere (restarted with debug here, but this is identical to 1st startup):

```
Mar 20 00:46:40 osdc04 systemd[1]: Started Rancher System Agent.
Mar 20 00:46:40 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:46:40Z" level=info msg="Rancher System Agent version v0.3.13 (5a64be2) is starting"
Mar 20 00:46:40 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:46:40Z" level=info msg="Using directory /var/lib/rancher/agent/work for work"
Mar 20 00:46:40 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:46:40Z" level=debug msg="Instantiated new image utility with imagesDir: /var/lib/rancher/agent/images, imageCredentialProviderConfig: /var/lib/rancher/credentialprovider/config.yaml, imageCredentialProviderBinDir: /var/lib/rancher/credentialprovider/bin, agentRegistriesFile: /etc/rancher/agent/registries.yaml"
Mar 20 00:46:40 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:46:40Z" level=info msg="Starting remote watch of plans"
Mar 20 00:46:40 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:46:40Z" level=info msg="Starting /v1, Kind=Secret controller"
Mar 20 00:46:40 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:46:40Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:46:45 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:46:45Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:46:50 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:46:50Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:46:55 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:46:55Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:47:00 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:47:00Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:47:05 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:47:05Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:47:10 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:47:10Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:47:15 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:47:15Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:47:20 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:47:20Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:47:25 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:47:25Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:47:30 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:47:30Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:47:35 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:47:35Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version 299573"
Mar 20 00:47:40 osdc04 rancher-system-agent[1900]: I0320 00:47:40.334593    1900 reflector.go:556] "Warning: watch ended with error" reflector=pkg/mod/k8s.io/client-go@v0.33.1/tools/cache/reflector.go:285 type="*v1.Secret" err="an error on the server (\"unable to decode an event from the watch stream: stream error: stream ID 5; INTERNAL_ERROR; received from peer\") has prevented the request from succeeding"
```

It just sits there...

```console
[root@osdc04 openspace]# systemctl status rancher-system-agent.service

● rancher-system-agent.service - Rancher System Agent
     Loaded: loaded (/etc/systemd/system/rancher-system-agent.service; enabled; preset: disabled)
    Drop-In: /etc/systemd/system/rancher-system-agent.service.d
             └─override.conf
     Active: active (running) since Fri 2026-03-20 00:46:40 GMT; 6min ago
       Docs: https://www.rancher.com
   Main PID: 1900 (rancher-system-)
      Tasks: 20 (limit: 203492)
     Memory: 18.3M
        CPU: 180ms
     CGroup: /system.slice/rancher-system-agent.service
             └─1900 /usr/local/bin/rancher-system-agent sentinel

Mar 20 00:52:24 osdc04 rancher-system-agent[1900]: time="2026-03-20T00:52:24Z" level=debug msg="[K8s] Processing secret custom-0b6b74fb33ab-machine-plan in namespace fleet-default at generation 0 with resource version>

[root@osdc04 openspace]# systemctl status rke2-server
Unit rke2-server.service could not be found.

[root@osdc04 openspace]# ps -ef | grep kube
root        1930    1656  0 00:54 pts/0    00:00:00 grep --color=auto kube
```

4. The cluster.yaml:

```yaml
apiVersion: provisioning.cattle.io/v1
kind: Cluster
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
    openspace.kratos.us/ownerName: osdc-cluster01
    openspace.kratos.us/ownerNamespace: openspace-system
  name: osdc-cluster01
  namespace: fleet-default
spec:
  clusterAgentDeploymentCustomization: {}
  fleetAgentDeploymentCustomization: {}
  kubernetesVersion: v1.33.7-rke2r1
  localClusterAuthEndpoint: {}
  rkeConfig:
    chartValues:
      rke2-multus: {}
    etcd:
      snapshotRetention: 5
      snapshotScheduleCron: 0 */5 * * *
    machineGlobalConfig:
      cni: multus,canal
      disable:
        - rke2-ingress-nginx
      disable-kube-proxy: false
      etcd-expose-metrics: false
      profile: null
    machinePoolDefaults: {}
    machineSelectorConfig:
      - config:
          cloud-provider-name: ''
          protect-kernel-defaults: false
          selinux: true
    machineSelectorFiles:
      - fileSources:
          - configMap:
              items:
                - key: kubelet-config.yaml
                  path: /var/lib/rancher/rke2/agent/etc/kubelet.conf.d/01-custom.conf
              name: osdc-config
    registries:
      configs:
        harbor.jhcx.internal:
          authConfigSecretName: registryconfig-auth-openspace-osdc
          insecureSkipVerify: true
      mirrors:
        docker.io:
          endpoint:
            - https://harbor.jhcx.internal:443
          rewrite:
            (.*): openspace-infra/$1
    upgradeStrategy:
      controlPlaneConcurrency: '1'
      controlPlaneDrainOptions:
        deleteEmptyDirData: true
        disableEviction: false
        enabled: false
        force: false
        gracePeriod: -1
        ignoreDaemonSets: true
        ignoreErrors: false
        postDrainHooks: null
        preDrainHooks: null
        skipWaitForDeleteTimeoutSeconds: 0
        timeout: 120
      workerConcurrency: '1'
      workerDrainOptions:
        deleteEmptyDirData: true
        disableEviction: false
        enabled: false
        force: false
        gracePeriod: -1
        ignoreDaemonSets: true
        ignoreErrors: false
        postDrainHooks: null
        preDrainHooks: null
        skipWaitForDeleteTimeoutSeconds: 0
        timeout: 120
```

5. In Rancher Cluster:

```console
[root@mcm01 openspace]# kubectl get clusters.management.cattle.io c-m-7slcp5bg -o yaml

apiVersion: management.cattle.io/v3
kind: Cluster
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
    argocd.argoproj.io/tracking-id: osdc-cluster01-cluster:provisioning.cattle.io/Cluster:fleet-default/osdc-cluster01
    authz.management.cattle.io/creator-role-bindings: '{"created":["cluster-owner"],"required":["cluster-owner"]}'
    authz.management.cattle.io/initial-sync: "true"
    field.cattle.io/creatorId: system:serviceaccount:openspace-system:argocd-application-controller
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"provisioning.cattle.io/v1","kind":"Cluster","metadata":{"annotations":{"argocd.argoproj.io/sync-wave":"1","argocd.argoproj.io/tracking-id":"osdc-cluster01-cluster:provisioning.cattle.io/Cluster:fleet-default/osdc-cluster01","openspace.kratos.us/ownerName":"osdc-cluster01","openspace.kratos.us/ownerNamespace":"openspace-system"},"name":"osdc-cluster01","namespace":"fleet-default"},"spec":{"clusterAgentDeploymentCustomization":{},"fleetAgentDeploymentCustomization":{},"kubernetesVersion":"v1.33.7-rke2r1","localClusterAuthEndpoint":{},"rkeConfig":{"chartValues":{"rke2-multus":{}},"etcd":{"snapshotRetention":5,"snapshotScheduleCron":"0 */5 * * *"},"machineGlobalConfig":{"cni":"multus,canal","disable":["rke2-ingress-nginx"],"disable-kube-proxy":false,"etcd-expose-metrics":false,"profile":null},"machinePoolDefaults":{},"machineSelectorConfig":[{"config":{"cloud-provider-name":"","protect-kernel-defaults":false,"selinux":true}}],"machineSelectorFiles":[{"fileSources":[{"configMap":{"items":[{"key":"kubelet-config.yaml","path":"/var/lib/rancher/rke2/agent/etc/kubelet.conf.d/01-custom.conf"}],"name":"osdc-config"}}]}],"registries":{"configs":{"harbor.jhcx.internal":{"authConfigSecretName":"registryconfig-auth-openspace-osdc","insecureSkipVerify":true}},"mirrors":{"docker.io":{"endpoint":[https://harbor.jhcx.internal:443],"rewrite":{"(.*)":"openspace-infra/$1"}}}},"upgradeStrategy":{"controlPlaneConcurrency":"1","controlPlaneDrainOptions":{"deleteEmptyDirData":true,"disableEviction":false,"enabled":false,"force":false,"gracePeriod":-1,"ignoreDaemonSets":true,"ignoreErrors":false,"postDrainHooks":null,"preDrainHooks":null,"skipWaitForDeleteTimeoutSeconds":0,"timeout":120},"workerConcurrency":"1","workerDrainOptions":{"deleteEmptyDirData":true,"disableEviction":false,"enabled":false,"force":false,"gracePeriod":-1,"ignoreDaemonSets":true,"ignoreErrors":false,"postDrainHooks":null,"preDrainHooks":null,"skipWaitForDeleteTimeoutSeconds":0,"timeout":120}}}}}
    lifecycle.cattle.io/create.cluster-agent-controller-cleanup: "true"
    lifecycle.cattle.io/create.cluster-provisioner-controller: "true"
    lifecycle.cattle.io/create.cluster-scoped-gc: "true"
    lifecycle.cattle.io/create.mgmt-cluster-rbac-remove: "true"
    objectset.rio.cattle.io/applied: H4sIAAAAAAAA/5xUTY/bNhD9K8WcJa3t2tkNgR6CbQ9BizRIvy6+jMixzDVFEsORXHex/70gLdVGWm+DnCiRb2bevMfhM2C0vxMnGzwo6NFjRz15aTSKOGpsuBu/hQoO1htQ8OiGJMRQQU+CBgVBPQN6HwTFBp/KL3dBmyYvkcNTzpFOXtdHHAkULKH6L4gw6oP1XW1zoZCMrvW52mI5f6nIYbSZrPXdFcWJlto5IqkN7RAq2Fly5gqkmVACv8/p0ykJ9SoRj1YTah0GLypE8imipno6P9OsMUZndWmw1sELh6zI0JIW1+SVPQmlXMRhkjOeTMbubDdwiQQFz9srubegtnCjn3G5hWpbRC+wqb+ymYWHCkL7RFoSScM2XIUW9Sa56tIyvYIOR09cd+MB1G0u1Tc/Wm++u3j/ejaPPf3LwS+KKtqDgouNg5McOfvSHBglpGZI56gPt0q9FjBX+dxtqG5JgKa33iZhFMryCg90G30ZoplTbWyKDk83pHmpoBhlg//V9pQE+wjKD85V4LAlV6bqlnx7THtQsH67eLOgN2bRbhYP96vNerHatGtamfVDe99uFuuH5Wq5Wr/N1SYauu7r++R03LRd3k6RdJnfjry877Gjn0ditiaD89D6dCTOZDLjM/13Gfs9RRdOuePHIUno7V/Tjb8C/kKaSUonke2IQp+oy5qefvv0EyjYI7eBm6e9/rOxXog9uruLRdbvGDNJQ0mzjdNEQdmwTObdP6S/MNkdo9d74nmtS9tqXDXL1VXaQfZflTU/CzVGW+MgezUumlWTs54vwq17Sx5bRx9IjoEPH4Oz+jRfhDIT/692gf0R+FA4TXU+nyfbx8BC5rG8T9mSzHb+gyzz3B+oHbpEFbig0U1PQBblB29isF5y9Jm2mbAvFRytN+GYPjLtiMnML8d0/vJ3AAAA///ZflqRdgYAAA
    objectset.rio.cattle.io/id: cluster-create
    objectset.rio.cattle.io/owner-gvk: provisioning.cattle.io/v1, Kind=Cluster
    objectset.rio.cattle.io/owner-name: osdc-cluster01
    objectset.rio.cattle.io/owner-namespace: fleet-default
    openspace.kratos.us/ownerName: osdc-cluster01
    openspace.kratos.us/ownerNamespace: openspace-system
    provisioning.cattle.io/administrated: "true"
    provisioning.cattle.io/management-cluster-display-name: osdc-cluster01
  creationTimestamp: "2026-03-20T00:42:45Z"
  finalizers:
  - wrangler.cattle.io/mgmt-cluster-remove
  - controller.cattle.io/cluster-agent-controller-cleanup
  - controller.cattle.io/cluster-scoped-gc
  - controller.cattle.io/cluster-provisioner-controller
  - controller.cattle.io/mgmt-cluster-rbac-remove
  generation: 12
  labels:
    objectset.rio.cattle.io/hash: 49060e6d0b5087254025b4e2d48b7b5048121249
  name: c-m-7slcp5bg
  resourceVersion: "299732"
  uid: bbe31bd9-15d7-421e-b634-8887ae1a0962
spec:
  agentImageOverride: ""
  answers: {}
  clusterAgentDeploymentCustomization: {}
  clusterSecrets:
    privateRegistryURL: harbor.jhcx.internal/openspace-infra
  description: ""
  desiredAgentImage: harbor.jhcx.internal/openspace-infra/rancher/rancher-agent:v2.12.6
  desiredAuthImage: harbor.jhcx.internal/openspace-infra/rancher/kube-api-auth:v0.2.4
  displayName: osdc-cluster01
  enableNetworkPolicy: null
  fleetAgentDeploymentCustomization: {}
  fleetWorkspaceName: fleet-default
  importedConfig:
    kubeConfig: ""
  internal: false
  localClusterAuthEndpoint:
    enabled: false
  windowsPreferedCluster: false
status:
  agentImage: ""
  aksStatus:
    privateRequiresTunnel: null
    rbacEnabled: null
    upstreamSpec: null
  allocatable:
    cpu: "0"
    memory: "0"
    pods: "0"
  appliedEnableNetworkPolicy: false
  appliedSpec:
    agentImageOverride: ""
    answers: {}
    clusterSecrets: {}
    description: ""
    desiredAgentImage: ""
    desiredAuthImage: ""
    displayName: ""
    enableNetworkPolicy: null
    internal: false
    localClusterAuthEndpoint:
      enabled: false
    windowsPreferedCluster: false
  authImage: ""
  capabilities:
    loadBalancerCapabilities: {}
  capacity:
    cpu: "0"
    memory: "0"
    pods: "0"
  conditions:
  - lastUpdateTime: "2026-03-20T00:43:31Z"
    message: waiting for viable init node
    reason: Waiting
    status: Unknown
    type: Updated
  - lastUpdateTime: "2026-03-20T00:42:45Z"
    status: "True"
    type: BackingNamespaceCreated
  - lastUpdateTime: "2026-03-20T00:42:45Z"
    status: "True"
    type: DefaultProjectCreated
  - lastUpdateTime: "2026-03-20T00:42:45Z"
    status: "True"
    type: SystemProjectCreated
  - lastUpdateTime: "2026-03-20T00:42:45Z"
    status: "True"
    type: InitialRolesPopulated
  - lastUpdateTime: "2026-03-20T00:42:45Z"
    status: "True"
    type: CreatorMadeOwner
  - lastUpdateTime: "2026-03-20T00:42:46Z"
    status: "True"
    type: NoDiskPressure
  - lastUpdateTime: "2026-03-20T00:42:46Z"
    status: "True"
    type: NoMemoryPressure
  - lastUpdateTime: "2026-03-20T00:42:46Z"
    status: "True"
    type: ServiceAccountSecretsMigrated
  - lastUpdateTime: "2026-03-20T00:42:55Z"
    status: "False"
    type: Connected
  - lastUpdateTime: "2026-03-20T00:43:31Z"
    status: "True"
    type: Provisioned
  - lastUpdateTime: "2026-03-20T00:43:40Z"
    message: Cluster agent is not connected
    reason: Disconnected
    status: "False"
    type: Ready
  driver: ""
  eksStatus:
    generatedNodeRole: ""
    managedLaunchTemplateID: ""
    managedLaunchTemplateVersions: null
    privateRequiresTunnel: null
    securityGroups: null
    subnets: null
    upstreamSpec: null
    virtualNetwork: ""
  gkeStatus:
    privateRequiresTunnel: null
    upstreamSpec: null
  limits:
    cpu: "0"
    memory: "0"
    pods: "0"
  provider: ""
  requested:
    cpu: "0"
    memory: "0"
    pods: "0"
```
