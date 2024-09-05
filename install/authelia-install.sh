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
$STD apt-get install -y mc
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
echo "deb http://download.opensuse.org/repositories/home:/Masgalor:/LLDAP/${DISTRO}_${VERSION_ID}/ /" >/etc/apt/sources.list.d/home:Masgalor:LLDAP.list
curl -fsSL https://download.opensuse.org/repositories/home:Masgalor:LLDAP/${DISTRO}_${VERSION_ID}/Release.key | gpg --dearmor >/etc/apt/trusted.gpg.d/home_Masgalor_LLDAP.gpg


echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/postgresql-repo.gpg] \
http://apt.postgresql.org/pub/repos/apt \
$(awk -F= '/VERSION_CODENAME=/ {print $2}' /etc/os-release)-pgdg main" >/etc/apt/sources.list.d/pgdg.list
curl -LO 'https://www.postgresql.org/media/keys/ACCC4CF8.asc' && \
gpg --no-default-keyring --keyring ./temp-keyring.gpg --import ACCC4CF8.asc && \
gpg --no-default-keyring --keyring ./temp-keyring.gpg --export --output /usr/share/keyrings/postgresql-repo.gpg && \
rm -f ./temp-keyring*
msg_ok "Repositories Set Up"

msg_info "Installing lldap"
$STD apt update
$STD apt install -y lldap
systemctl enable -q --now lldap
msg_ok "Installed lldap"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
