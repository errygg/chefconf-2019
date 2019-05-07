#!/usr/bin/env bash
set -e

echo "==> Habitat"

echo "--> Installing hab"
pushd /tmp &>/dev/null
curl \
  --silent \
  --location \
  --output hab.tgz \
  https://api.bintray.com/content/habitat/stable/linux/x86_64/hab-%24latest-x86_64-linux.tar.gz?bt_package=hab-x86_64-linux
tar -zxvf hab.tgz
sudo mv hab*/hab /usr/local/bin/hab
sudo chmod +x /usr/local/bin/hab
rm -rf hab.tgz
popd &>/dev/null

echo "--> Downloading hab cores"
sudo hab pkg install core/curl
#sudo hab pkg install core/hab-butterfly
#sudo hab pkg install core/hab-butterfly

