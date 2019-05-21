pkg_origin=errygg
pkg_name=dashboard-connect
pkg_version=0.1.0
pkg_description="Example dashboard application with Consul Connect"
pkg_deps=( core/curl core/go errygg/dnsmasq/2.80/20190513203448 errygg/consul )
pkg_bin_dirs=(bin)
pkg_scaffolding=core/scaffolding-go

scaffolding_go_build_deps=(
  github.com/gorilla/mux
  github.com/graarh/golang-socketio
  github.com/GeertJohan/go.rice
)

pkg_svc_user="root"
pkg_svc_group="root"
