#!/usr/bin/env bash
set -e

echo "==> Consul (client)"

echo "--> Grabbing IPs"
PRIVATE_IP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl --silent http://169.254.169.254/latest/meta-data/public-ipv4)

echo "--> Fetching"
pushd /tmp &>/dev/null
curl \
  --silent \
  --location \
  --output consul.zip \
  https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip
unzip -qq consul.zip
sudo mv consul /usr/local/bin/consul
sudo chmod +x /usr/local/bin/consul
rm -rf consul.zip
popd &>/dev/null

echo "Installing Consul..."
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/consul.d
sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "advertise_addr_wan": "$PUBLIC_IP",
  "bootstrap_expect": ${servers},
  "bind_addr": "$PRIVATE_IP",
  "data_dir": "/mnt/consul",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "node_name": "${hostname}",
  "retry_join_ec2": {
    "tag_key": "consul",
    "tag_value": "consul"
  },
  "server": true
}
EOF

echo "--> Writing profile"
sudo tee /etc/profile.d/consul.sh > /dev/null <<EOF
alias conslu="consul"
alias ocnsul="consul"
EOF
source /etc/profile.d/consul.sh

echo "--> Generating upstart configuration"
sudo tee /etc/systemd/system/consul.service > /dev/null <<EOF
[Unit]
Description=Consul Agent
Requires=network-online.target
After=network.target

[Service]
Environment=GOMAXPROCS=8
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -config-dir="/etc/consul.d"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

echo "--> Starting consul"
sudo systemctl enable consul
sleep 2

echo "--> Installing dnsmasq"
sudo apt-get -yqq install dnsmasq &>/dev/null
sudo tee /etc/dnsmasq.d/10-consul > /dev/null <<"EOF"
server=/consul/127.0.0.1#8600
no-poll
server=8.8.8.8
server=8.8.4.4
cache-size=0
EOF
sudo systemctl enable dnsmasq

echo "==> Consul is done!"
