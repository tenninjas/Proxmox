#!/usr/bin/env bash

# Copyright (c) 2021-2024 tenninjas
# Author: tenninjas (tenninjas)
# License: MIT
# https://github.com/tenninjas/Proxmox/raw/main/LICENSE

# https://github.com/lldap/lldap/
# https://codeberg.org/Masgalor/LLDAP
# https://www.authelia.com/integration/deployment/bare-metal/
# https://www.authelia.com/integration/ldap/introduction/

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y gpg
msg_ok "Installed Dependencies"

msg_info "Setting up 3rd-Party Repositories"
source /etc/os-release
os=$ID
if [ "$os" == "ubuntu" ]; then
  DISTRO="xUbuntu"
else
  DISTRO="${os^}"
fi
echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/lldap-repo.gpg] \
http://download.opensuse.org/repositories/home:/Masgalor:/LLDAP/${DISTRO}_${VERSION_ID}/ /" >/etc/apt/sources.list.d/lldap.list
curl -o Masgalor-LLDAP.key -L "https://download.opensuse.org/repositories/home:Masgalor:LLDAP/${DISTRO}_${VERSION_ID}/Release.key" && \
gpg --no-default-keyring --keyring ./temp-keyring.gpg --import Masgalor-LLDAP.key && \
gpg --no-default-keyring --keyring ./temp-keyring.gpg --export --output /usr/share/keyrings/lldap-repo.gpg && \
rm -f ./temp-keyring* ./Masgalor-LLDAP.key
echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/authelia-repo.gpg] \
https://apt.authelia.com/stable/debian/debian all main" >/etc/apt/sources.list.d/authelia.list
curl -o authelia.asc -L "https://apt.authelia.com/organization/signing.asc" && \
gpg --no-default-keyring --keyring ./temp-keyring.gpg --import authelia.asc && \
gpg --no-default-keyring --keyring ./temp-keyring.gpg --export --output /usr/share/keyrings/authelia-repo.gpg && \
rm -f ./temp-keyring* ./authelia.asc
$STD apt update
msg_ok "Repositories Set Up"

msg_info "Installing lldap"
$STD apt install -y lldap
systemctl enable -q --now lldap
msg_ok "Installed lldap"

msg_info "Installing authelia"
$STD apt install -y authelia
msg_ok "Installed authelia"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
