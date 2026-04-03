# BWXT

Multiple networks, including commercial and closed

Want to use Harvester on closed cluster, running internal AI workloads on rke2 guest clusters managed by Rancher

Uses AKS on the commercial network, but unavailable to closed, which is airgapped from Internet

Closed network is classified, connected to DOE - requires STIG and FIPS compliance

For POC:

Harvester on Internet-connected nodes

rke2 guest cluster managed by Rancher

Want to see GPU workloads of some sort come up in containers

Verify that Cohesity backup works

Would like to see workload failover when a cluster node goes down