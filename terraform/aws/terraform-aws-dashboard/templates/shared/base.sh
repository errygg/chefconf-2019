#!/usr/bin/env bash
set -e

echo "==> Base"

echo "--> Grabbing IPs"
PRIVATE_IP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl --silent http://169.254.169.254/latest/meta-data/public-ipv4)

echo "--> Adding helper for IP retrieval"
sudo tee /etc/profile.d/ips.sh > /dev/null <<EOF
function private-ip {
  echo "$PRIVATE_IP"
}

function public-ip {
  echo "$PUBLIC_IP"
}
EOF

echo "--> Formatting disk"
sudo mkfs.xfs -K /dev/xvdb
sudo mkdir -p /mnt
sudo mount -o discard /dev/xvdb /mnt
sudo tee -a /etc/fstab > /dev/null <<"EOF"
/dev/xvdb   /mnt   xfs    defaults,nofail,discard   0   2
EOF

echo "--> Installing common dependencies"
sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq \
  --force-yes \
  -o=Dpkg::Use-Pty=0 \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  dist-upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq \
  --force-yes \
  -o=Dpkg::Use-Pty=0 \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  update
sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq \
  --force-yes \
  -o=Dpkg::Use-Pty=0 \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq \
  -o=Dpkg::Use-Pty=0 \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  install \
  apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  git \
  jq \
  linux-image-extra-virtual \
  software-properties-common \
  unzip \
  vim \
  wget
sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq \
  -o=Dpkg::Use-Pty=0 \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  clean
sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq \
  -o=Dpkg::Use-Pty=0 \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  autoclean
sudo DEBIAN_FRONTEND=noninteractive apt-get -yqq \
  -o=Dpkg::Use-Pty=0 \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  autoremove

sudo chown ubuntu:ubuntu /home/ubuntu/.vimrc

echo "--> Disabling checkpoint"
sudo tee /etc/profile.d/checkpoint.sh > /dev/null <<"EOF"
export CHECKPOINT_DISABLE=1
EOF
source /etc/profile.d/checkpoint.sh

echo "--> Setting hostname..."
echo "${hostname}" | sudo tee /etc/hostname
sudo hostname -F /etc/hostname
echo "127.0.0.1  ${hostname}" | sudo tee -a /etc/hosts

echo "--> Configuring MOTD"
sudo rm -rf /etc/update-motd.d/*
sudo tee /etc/update-motd.d/00-hashicorp > /dev/null <<"EOF"
#!/bin/sh
echo "Welcome to the HashiCorp demo! Have a great day!"
EOF
sudo chmod +x /etc/update-motd.d/00-hashicorp
sudo run-parts /etc/update-motd.d/ &>/dev/null

echo "--> Ignoring LastLog"
sudo sed -i'' 's/PrintLastLog\ yes/PrintLastLog\ no/' /etc/ssh/sshd_config
sudo service ssh restart &>/dev/null

echo "--> Setting bash prompt"
sudo tee -a "/home/ubuntu/.bashrc" > /dev/null <<"EOF"
export PS1="demo@hashicorp > "
EOF
sudo touch "/home/ubuntu/.sudo_as_admin_successful"
sudo chown -R ubuntu:ubuntu "/home/ubuntu/"

echo "==> Base is done!"
