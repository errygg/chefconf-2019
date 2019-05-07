#!/usr/bin/env bash

echo "==> Rebooting"
# Trap the reboot as an exit, because the script has to return 0 or else
# Terraform will thing the provisoiner failed.
function reboot {
  sudo systemctl reboot
}
trap reboot EXIT
