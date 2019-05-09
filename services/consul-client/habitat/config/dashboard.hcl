service {
  id   = "dashboard"
  name = "dashboard"
  address = ""
  port = {{cfg.dashboard.port}}

  check = {
    id       = "dashboard-check-1"
    name     = "Dashboard Service Health Status"
    interval = "10s"
    args     = [ "curl", "http://{{cfg.dashboard.hostname}}:{{cfg.dashboard.port}}/health" ]
  }
}
