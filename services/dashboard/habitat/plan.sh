pkg_name=consul-dashboard-app
pkg_origin=errygg
pkg_version="0.1.0"
pkg_scaffolding=core/scaffolding-go
pkg_deps=( core/consul )
scaffolding_go_build_deps=( github.com/gorilla/mux )

do_build() {
  do_default_build
}
