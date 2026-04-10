# IP allocation failure prevents Longhorn pods from starting containers after storage network created

```console
hvst-0:~ # kubectl get ds harvester-whereabouts -n kube-system -oyaml | yq '.spec.template.spec.containers[0] | (.command, .args)'
- /bin/sh
- -c
- |
  SLEEP=false source /install-cni.sh
  /token-watcher.sh &
  /ip-control-loop -log-level debug
```

```console
hvst-0:~ # kubectl logs $(kubectl get pod -n kube-system -l app=whereabouts --no-headers | head -n 1 | awk '{print $1}') -n kube-system
Done configuring CNI.  Sleep=false
Sleep and Watching for service account token and CA file changes...
2026-04-08T19:43:21Z [debug] Filtering pods with filter key 'spec.nodeName' and filter value 'hvst-1'
2026-04-08T19:43:21Z [verbose] pod controller created
2026-04-08T19:43:21Z [verbose] Starting informer factories ...
2026-04-08T19:43:21Z [verbose] Informer factories started
2026-04-08T19:43:21Z [verbose] starting network controller
2026-04-08T19:43:21Z [verbose] using expression: 30 4 * * *
2026-04-09T04:30:00Z [verbose] starting reconciler run
2026-04-09T04:30:00Z [debug] NewReconcileLooper - inferred connection data
2026-04-09T04:30:00Z [debug] listing IP pools
2026-04-09T04:30:00Z [debug] listing Pods
2026-04-09T04:30:00Z [debug] Added IP 10.240.30.6 for pod longhorn-system/bim-120818352e217d5bf9e0ed8053e0be5b16269437e221056fe3f3389b
2026-04-09T04:30:00Z [debug] Added IP 10.240.30.5 for pod longhorn-system/bim-3b04e8b1db81c3e4ba6067fc6bbe2da0ee1f771e0ecdce913983ae7f
2026-04-09T04:30:00Z [debug] Added IP 10.240.30.4 for pod longhorn-system/bim-ea761cf490f6dbda8e3955c2bb7fb0af89a0c6e9c7244c3464baf2ea
2026-04-09T04:30:00Z [debug] Added IP 10.240.30.3 for pod longhorn-system/instance-manager-5e559c238d56f48a8bfe896545c977c3
2026-04-09T04:30:00Z [debug] Added IP 10.240.30.2 for pod longhorn-system/instance-manager-c1d59911ac77de1fd42f9813c9e78fe3
2026-04-09T04:30:00Z [debug] Added IP 10.240.30.7 for pod longhorn-system/instance-manager-df0b99505805fa8250eb680a84858426
2026-04-09T04:30:00Z [debug] the IP reservation: IP: 10.240.30.3 is reserved for pod: longhorn-system/instance-manager-5e559c238d56f48a8bfe896545c977c3
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-5e559c238d56f48a8bfe896545c977c3 matches allocation; Allocation IP: 10.240.30.3; PodIPs: map[10.240.30.3:{}]
2026-04-09T04:30:00Z [debug] the IP reservation: IP: 10.240.30.4 is reserved for pod: longhorn-system/bim-ea761cf490f6dbda8e3955c2bb7fb0af89a0c6e9c7244c3464baf2ea
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-ea761cf490f6dbda8e3955c2bb7fb0af89a0c6e9c7244c3464baf2ea matches allocation; Allocation IP: 10.240.30.4; PodIPs: map[10.240.30.4:{}]
2026-04-09T04:30:00Z [debug] the IP reservation: IP: 10.240.30.5 is reserved for pod: longhorn-system/bim-3b04e8b1db81c3e4ba6067fc6bbe2da0ee1f771e0ecdce913983ae7f
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-3b04e8b1db81c3e4ba6067fc6bbe2da0ee1f771e0ecdce913983ae7f matches allocation; Allocation IP: 10.240.30.5; PodIPs: map[10.240.30.5:{}]
2026-04-09T04:30:00Z [debug] the IP reservation: IP: 10.240.30.6 is reserved for pod: longhorn-system/bim-120818352e217d5bf9e0ed8053e0be5b16269437e221056fe3f3389b
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-120818352e217d5bf9e0ed8053e0be5b16269437e221056fe3f3389b matches allocation; Allocation IP: 10.240.30.6; PodIPs: map[10.240.30.6:{}]
2026-04-09T04:30:00Z [debug] the IP reservation: IP: 10.240.30.7 is reserved for pod: longhorn-system/instance-manager-df0b99505805fa8250eb680a84858426
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-df0b99505805fa8250eb680a84858426 matches allocation; Allocation IP: 10.240.30.7; PodIPs: map[10.240.30.7:{}]
2026-04-09T04:30:00Z [debug] the IP reservation: IP: 10.240.30.2 is reserved for pod: longhorn-system/instance-manager-c1d59911ac77de1fd42f9813c9e78fe3
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-c1d59911ac77de1fd42f9813c9e78fe3 matches allocation; Allocation IP: 10.240.30.2; PodIPs: map[10.240.30.2:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-c1d59911ac77de1fd42f9813c9e78fe3 matches allocation; Allocation IP: 10.240.30.2; PodIPs: map[10.240.30.2:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-5e559c238d56f48a8bfe896545c977c3 matches allocation; Allocation IP: 10.240.30.3; PodIPs: map[10.240.30.3:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-ea761cf490f6dbda8e3955c2bb7fb0af89a0c6e9c7244c3464baf2ea matches allocation; Allocation IP: 10.240.30.4; PodIPs: map[10.240.30.4:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-3b04e8b1db81c3e4ba6067fc6bbe2da0ee1f771e0ecdce913983ae7f matches allocation; Allocation IP: 10.240.30.5; PodIPs: map[10.240.30.5:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-120818352e217d5bf9e0ed8053e0be5b16269437e221056fe3f3389b matches allocation; Allocation IP: 10.240.30.6; PodIPs: map[10.240.30.6:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-df0b99505805fa8250eb680a84858426 matches allocation; Allocation IP: 10.240.30.7; PodIPs: map[10.240.30.7:{}]
2026-04-09T04:30:00Z [debug] no IP addresses to cleanup
2026-04-09T04:30:00Z [verbose] reconciler success
```

[token-watcher.sh](https://github.com/k8snetworkplumbingwg/whereabouts/blob/v0.9.3/script/token-watcher.sh)

```sh
#!/bin/sh

set -u -e

source /lib.sh

echo "Sleep and Watching for service account token and CA file changes..."
# enter sleep/watch loop
while true; do
  # Check the md5sum of the service account token and ca.
  svcaccountsum="$(get_token_md5sum)"
  casum="$(get_ca_file_md5sum)"
  if [ "$svcaccountsum" != "$LAST_SERVICEACCOUNT_MD5SUM" ] || ([ "$SKIP_TLS_VERIFY" != "true" ] && [ "$casum" != "$LAST_KUBE_CA_FILE_MD5SUM" ]); then
    log "Detected service account or CA file change, regenerating kubeconfig..."
    generateKubeConfig
    LAST_SERVICEACCOUNT_MD5SUM="$svcaccountsum"
    LAST_KUBE_CA_FILE_MD5SUM="$casum"
  fi

  sleep 1
done
```

All of this *seems* to imply the `token-watcher.sh` script is running in the background, but we never see the "Detected service account or CA file change, regenerating kubeconfig..." line in the log.

```console
kubectl exec -it $(kubectl get pod -n kube-system -l app=whereabouts --no-headers | head -n 1 | awk '{print $1}') -n kube-system -- /bin/sh
/ # ps aef
PID   USER     TIME  COMMAND
    1 root      0:00 /bin/sh -c SLEEP=false source /install-cni.sh /token-watcher.sh & /ip-control-loop -log-level debug
   29 root      0:35 {token-watcher.s} /bin/sh /token-watcher.sh
   30 root      0:04 /ip-control-loop -log-level debug
293313 root      0:00 /bin/sh
296710 root      0:00 sleep 1s
296711 root      0:00 ps aef
/ # grep -Eo 'LAST_SERVICEACCOUNT_MD5SUM=[a-z0-9]+' /proc/29/environ | sed 's/LAST_SERVICEACCOUNT_MD5SUM=//'
543de6457b9e58fd75714748422ab749
/ # source lib.sh
/ # get_token_md5sum
35dd03df1ae18324a40b00a2b475a818
```

However, we can see the checksums do not match. Given the check loop runs every second, this should not be the case. If we check the token from the kubeconfig:

```console
adam@acmbp1 ~ $ kubectl exec -it -n kube-system $(kubectl get pod -n kube-system -l app=whereabouts --no-headers | head -n 1 | awk '{print $1}') -- cat /host/etc/cni/net.d/whereabouts.d/whereabouts.kubeconfig | yq '.users[0].user.token' | jwt decode --json - | jq -r '.payload.iat | strftime("%Y-%m-%d %H:%M:%S")'
2026-04-08 19:43:17
adam@acmbp1 ~ $ kubectl exec -it -n kube-system $(kubectl get pod -n kube-system -l app=whereabouts --no-headers | head -n 1 | awk '{print $1}') -- cat /host/etc/cni/net.d/whereabouts.d/whereabouts.kubeconfig | yq '.users[0].user.token' | jwt decode --json - | jq -r '.payload.exp | strftime("%Y-%m-%d %H:%M:%S")'
2026-04-08 20:43:24
adam@acmbp1 ~ $ date -u +"%Y-%m-%d %H:%M:%S"
2026-04-09 08:13:39
```

We can see it expired yesterday, an hour after it was issued, which was the same time the pod last started this container. The token watch loop does seem to be running, given the presence of the `sleep 1` command in the process list of the pod, but it is not regenerating the file.

To experiment, run the function `generateKubeConfig` from the pod:

```console
/ # generateKubeConfig
```

Then check the kubeconfig again:

```console
adam@acmbp1 ~ $ kubectl exec -it -n kube-system $(kubectl get pod -n kube-system -l app=whereabouts --no-headers | head -n 1 | awk '{print $1}') -- cat /host/etc/cni/net.d/whereabouts.d/whereabouts.kubeconfig | yq '.users[0].user.token' | jwt decode --json - | jq -r '.payload.iat | strftime("%Y-%m-%d %H:%M:%S")'
2026-04-09 07:00:07
adam@acmbp1 ~ $ date -u +"%Y-%m-%d %H:%M:%S"
2026-04-09 08:24:03
```

There's possible some timezone weirdness going on here with the Harvester host and Macbook not agreeing on the offset from UTC, but we can see this now gets the current service account token, which is reissued every hour, rather than the original token it had before. So this works when run manually, but seems to be doing nothing when run from the backgrounded token watcher script.

```console
/ # ps aef
PID   USER     TIME  COMMAND
    1 root      0:00 /bin/sh -c SLEEP=false source /install-cni.sh /token-watcher.sh & /ip-control-loop -log-level debug
   29 root      0:38 {token-watcher.s} /bin/sh /token-watcher.sh
   30 root      0:04 /ip-control-loop -log-level debug
293313 root      0:00 /bin/sh
319330 root      0:00 sleep 1s
319331 root      0:00 ps aef
```

The process ID for `sleep 1s` has changed, from `296710` to `319330`. The watch loop is clearly running, but check the log again:

```console
adam@acmbp1 ~ $ kubectl logs $(kubectl get pod -n kube-system -l app=whereabouts --no-headers | head -n 1 | awk '{print $1}') -n kube-system | tail -n 10
2026-04-09T04:30:00Z [debug] the IP reservation: IP: 10.240.30.2 is reserved for pod: longhorn-system/instance-manager-c1d59911ac77de1fd42f9813c9e78fe3
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-c1d59911ac77de1fd42f9813c9e78fe3 matches allocation; Allocation IP: 10.240.30.2; PodIPs: map[10.240.30.2:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-c1d59911ac77de1fd42f9813c9e78fe3 matches allocation; Allocation IP: 10.240.30.2; PodIPs: map[10.240.30.2:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-5e559c238d56f48a8bfe896545c977c3 matches allocation; Allocation IP: 10.240.30.3; PodIPs: map[10.240.30.3:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-ea761cf490f6dbda8e3955c2bb7fb0af89a0c6e9c7244c3464baf2ea matches allocation; Allocation IP: 10.240.30.4; PodIPs: map[10.240.30.4:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-3b04e8b1db81c3e4ba6067fc6bbe2da0ee1f771e0ecdce913983ae7f matches allocation; Allocation IP: 10.240.30.5; PodIPs: map[10.240.30.5:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-120818352e217d5bf9e0ed8053e0be5b16269437e221056fe3f3389b matches allocation; Allocation IP: 10.240.30.6; PodIPs: map[10.240.30.6:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-df0b99505805fa8250eb680a84858426 matches allocation; Allocation IP: 10.240.30.7; PodIPs: map[10.240.30.7:{}]
2026-04-09T04:30:00Z [debug] no IP addresses to cleanup
2026-04-09T04:30:00Z [verbose] reconciler success
```

Nothing has changed. What if we simply run the token watcher script ourselves:

```console
/ # export LAST_SERVICEACCOUNT_MD5SUM="$(get_token_md5sum)"
/ # export LAST_KUBE_CA_FILE_MD5SUM="$(get_ca_file_md5sum)"
/ # ./token-watcher.sh
Sleep and Watching for service account token and CA file changes...

```

It seems to be doing exactly what the backgrounded version of itself is, entering its watch loop and sleeping for 1s repeatedly. Unfortunately, the service account token won't be reissued until it expires. We can check when that will happen:

```console
adam@acmbp1 ~ $ kubectl exec -it $(kubectl get pod -n kube-system -l app=whereabouts --no-headers | head -n 1 | awk '{print $1}') -n kube-system -- cat /var/run/secrets/kubernetes.io/serviceaccount/token | jwt decode --json - | jq -r '.payload.exp | strftime("%Y-%m-%d %H:%M:%S")'
2026-04-09 09:36:50
adam@acmbp1 ~ $ date -u +"%Y-%m-%d %H:%M:%S"
2026-04-09 09:15:18
```

This implies that we can leave the script running in the foreground of our `exec` session and we should see a log statement about generating a new kubeconfig in about 21 minutes minus the buffer time that `kubelet` subtracts to ensure it issues a new token before it expires. We can check and eventually see a new token:

```console
adam@acmbp1 ~ $ kubectl exec -it $(kubectl get pod -n kube-system -l app=whereabouts --no-headers | head -n 1 | awk '{print $1}') -n kube-system -- cat /var/run/secrets/kubernetes.io/serviceaccount/token | jwt decode --json - | jq -r '.payload.exp | strftime("%Y-%m-%d %H:%M:%S")'
2026-04-09 10:24:58
```

We see it gets issued about 12 minutes before it was scheduled to expire. However, the token watcher script has not logged anything:

```console
/ # ./token-watcher.sh
Sleep and Watching for service account token and CA file changes...

```

And the kubeconfig itself still has the expired token:

```console
adam@acmbp1 ~ $ kubectl exec -it -n kube-system $(kubectl get pod -n kube-system -l app=whereabouts --no-headers | head -n 1 | awk '{print $1}') -- cat /host/etc/cni/net.d/whereabouts.d/whereabouts.kubeconfig | yq '.users[0].user.token' | jwt decode --json - | jq -r '.payload.exp | strftime("%Y-%m-%d %H:%M:%S")'
2026-04-09 08:00:14
```

Nothing new has been logged either:

```console
adam@acmbp1 ~ $ kubectl logs $(kubectl get pod -n kube-system -l app=whereabouts --no-headers | head -n 1 | awk '{print $1}') -n kube-system | tail -n 10
2026-04-09T04:30:00Z [debug] the IP reservation: IP: 10.240.30.2 is reserved for pod: longhorn-system/instance-manager-c1d59911ac77de1fd42f9813c9e78fe3
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-c1d59911ac77de1fd42f9813c9e78fe3 matches allocation; Allocation IP: 10.240.30.2; PodIPs: map[10.240.30.2:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-c1d59911ac77de1fd42f9813c9e78fe3 matches allocation; Allocation IP: 10.240.30.2; PodIPs: map[10.240.30.2:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-5e559c238d56f48a8bfe896545c977c3 matches allocation; Allocation IP: 10.240.30.3; PodIPs: map[10.240.30.3:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-ea761cf490f6dbda8e3955c2bb7fb0af89a0c6e9c7244c3464baf2ea matches allocation; Allocation IP: 10.240.30.4; PodIPs: map[10.240.30.4:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-3b04e8b1db81c3e4ba6067fc6bbe2da0ee1f771e0ecdce913983ae7f matches allocation; Allocation IP: 10.240.30.5; PodIPs: map[10.240.30.5:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/bim-120818352e217d5bf9e0ed8053e0be5b16269437e221056fe3f3389b matches allocation; Allocation IP: 10.240.30.6; PodIPs: map[10.240.30.6:{}]
2026-04-09T04:30:00Z [debug] pod reference longhorn-system/instance-manager-df0b99505805fa8250eb680a84858426 matches allocation; Allocation IP: 10.240.30.7; PodIPs: map[10.240.30.7:{}]
2026-04-09T04:30:00Z [debug] no IP addresses to cleanup
2026-04-09T04:30:00Z [verbose] reconciler success
```

This seems to indicate the condition for the check loop never evalutes to true:

```sh
svcaccountsum="$(get_token_md5sum)"
casum="$(get_ca_file_md5sum)"
if [ "$svcaccountsum" != "$LAST_SERVICEACCOUNT_MD5SUM" ] || ([ "$SKIP_TLS_VERIFY" != "true" ] && [ "$casum" != "$LAST_KUBE_CA_FILE_MD5SUM" ]); then
  log "Detected service account or CA file change, regenerating kubeconfig..."
  generateKubeConfig
  LAST_SERVICEACCOUNT_MD5SUM="$svcaccountsum"
  LAST_KUBE_CA_FILE_MD5SUM="$casum"
fi
```

However, we can verify the checksums are different:

```console
/ # md5sum /var/run/secrets/kubernetes.io/serviceaccount/token
f73002220a2a737aa553d8fed7f220ab  /var/run/secrets/kubernetes.io/serviceaccount/token
/ # md5sum /host/etc/cni/net.d/whereabouts.d/whereabouts.kubeconfig
248c45885d67469b491069aefbbfba64  /host/etc/cni/net.d/whereabouts.d/whereabouts.kubeconfig
```

After inspecting the script on the host rather than on Github, it turns out it simply had a bug that was fixed in `whereabouts` 0.9.3 but Harvester as of 1.7.1 is using `whereabouts` 0.9.2, which has a broken token watcher script. See [whereabouts/pull/661](https://github.com/k8snetworkplumbingwg/whereabouts/pull/661).

Harvester 1.8.x will pick up the fix. See [harvester/charts/harvester/values.yaml](https://github.com/harvester/harvester/blob/v1.8/deploy/charts/harvester/values.yaml#L609).
