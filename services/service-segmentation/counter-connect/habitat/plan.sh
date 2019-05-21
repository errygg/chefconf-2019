pkg_name=counter-connect
pkg_origin=errygg
pkg_version=0.1.0
pkg_deps=( core/curl core/go errygg/dnsmasq/2.80/20190513203448 errygg/consul )
pkg_bin_dirs=(bin)
pkg_scaffolding=core/scaffolding-go

scaffolding_go_build_deps=( github.com/gorilla/mux )

pkg_svc_user="root"
pkg_svc_group="root"
