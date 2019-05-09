# chefconf-2019

This is the project that is used for my ChefConf 2019 talk on Consul and
Habitat.

In all, this demo consists of 6 containers: counter service, dashboard service,
Consul client, Consul server, and 2 Envoy sidecar containers.

## Setup

1. Ensure the `consul:latest` is pulled down locally.
1. Ensure the `errygg/consul` package is built and pushed to Habitat Builder.

1. First we'll build all the Habitat packages and export them as Docker containers

```bash
> cd services/counter
> hab studio enter
$ build
$ hab pkg export docker ./results/<.hart file>
```

```bash
> cd services/dashboard
> hab studio enter
$ build
$ hab pkg export docker ./results/<.hart file>
```

```bash
> cd services/consul-client
> hab studio enter
$ build
$ hab pkg export docker ./results/<.hart file>
```

1. Run `docker-compose` to setup all the initial containers (without Envoy)

```bash
> cd compose
> docker-compose up
```

1. Browse to all the services and ensure they are running

Consul Server: http://localhost:8500
Counter Service: http://localhost:8080
Dashboard Service: http://localhost:TBD

1. Start the dashboard app and register it with Consul (with the Consul agent
running alongside the counter app). Start the dashboard with `COUNTING_SERVICE_URL`
set to the DNS endpoint for the counter app (`counter.consul.service`).

```bash
hab ...
```

1. Deploy the Envoy proxy to each of the counter and dashboard habitat apps.

```bash
???
```

1. Flip the switch in the consul config file to use Consul Connect

```bash
???
```

Great, now we know how Habitat apps work with Consul Connect and Envoy and we've
secured our connections... on our laptop. What about a real environment.

1. Spin up a K8 cluster with Consul Helm

1. Spin up some VMs and register them with Consul in K8s

1. Deploy the counter application to K8 w/ Consul and Envoy

1. Deploy the dashboard application to the VMs w/ Consul and Envoy

1. Show the awesomeness...

# Demo Diagram

+-----------+
| Counter   |
| Service   |
|           |
+-----------++--------+             +---------+
             | Consul |             | Consul  |
             | Agent  +<----------->+ Server  |
             |        |             |         |
+-----------++--------+             +---------+
| Dashboard |
| Service   |
|           |
+-----------+


# Resources

Guide on how to create [Habitat Wrapper Plans](https://forums.habitat.sh/t/habitat-wrapper-plans/1024)

Example [Habitat Wrapper Plan for Vault](https://github.com/qubitrenegade/habitat-vault-wrapper)

Consul Service [Checks](https://www.consul.io/docs/agent/checks.html)

Current [work-in-progress plan](https://bldr.habitat.sh/#/pkgs/errygg/consul/latest) for modifications to core/consul

Consul Service [Definitions](https://www.consul.io/docs/agent/services.html)

Consul Connect [Demo](https://github.com/thomashashi/thomas_cc_demo)

Consul and Docker [blog](https://medium.com/zendesk-engineering/making-docker-and-consul-get-along-5fceda1d52b9)

Consul 101 [demo](https://github.com/hashicorp/demo-consul-101) including the counting and dashboard services

Official Consul Docker [image](https://hub.docker.com/_/consul)

Docker [Compose](https://docs.docker.com/compose/gettingstarted/)

Example Consul Docker Compose [file](https://github.com/hashicorp/consul/blob/master/demo/docker-compose-cluster/docker-compose.yml)

Example Consul Client Habitat [package](https://github.com/qubitrenegade/habitat-consul-client)