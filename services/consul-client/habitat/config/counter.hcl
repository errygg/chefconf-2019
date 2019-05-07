service = {
  id   = "counter"
  name = "counter"
  port = {{cfg.counter.port}}

  checks: {
    id       = "check1"
    name     = "is_alive"
    interval = "10s"
    args     = ["curl" "{{cfg.counter.hostname}}:{{cfg.counter.port}}/health"]
  }

}
