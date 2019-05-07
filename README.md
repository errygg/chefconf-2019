# chefconf-2019

1. First we'll build all the Habitat packages and export them as Docker containers

```bash
> cd services/counter
> hab studio enter
$ build
$ hab pkg export docker ./results/<.hart file>
```

In a seperate terminal:

```bash
> cd services/consul-client
```


In a seperate tab:

```bash
> docker run -it -p 8080:8080 errygg/counter
```

Browse to http://localhost:8080

1. Start the dashboard app locally, start with `COUNTING_SERVICE_URL` set to the
local address exported from the counter app hab application.

```bash
hab ...
```

1. Start up a Consul dev server

```bash
consul -dev ...
```

1. Start the counter app and register it with Consul (with the Consul agent
running alongside the counter app)

```bash
hab ...
```

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