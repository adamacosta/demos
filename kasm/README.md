# Kasm on Harvester

## Upstream documentation

- [RGS KASM Better Together White Paper](https://ranchergovernment.com/hubfs/RGS_KASM%20Better%20Together_Whitepaper_REV1.pdf)
- [Install KASM on Kubernetes](https://docs.kasm.com/docs/install/kubernetes)
- [kasm-helm on Github](https://github.com/kasmtech/kasm-helm/blob/release/1.18.1/charts/kasm/README.md)
- [Harvester KASM Autoscale Provider](https://docs.kasm.com/docs/how-to/autoscale/autoscale_providers/harvester)
- [Cert Manager CA Issuer](https://cert-manager.io/docs/configuration/ca/)

## Architecture Notes

Kasm Workspaces is to be installed in a multi-server configuration. The Kasm Agent is a separate application from the Helm chart that needs to run on its own VM.

## Installation

- [Airgap Prep](./docs/airgap.md)
- [RKE2 Cluster](./docs/rke2.md)
- [Kasm Workspaces](./docs/kasm.md)
- [Kasm Docker Agent](./docs/agent.md)
