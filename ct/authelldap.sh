#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tenninjas/Proxmox/main/misc/build.func)
# Copyright (c) 2024 tenninjas
# Author: tenninjas (tenninjas)
# License: MIT
# https://github.com/tenninjas/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
             _   _          _    __    __
            | | | |        | |  / /   / /
  __ _ _   _| |_| |__   ___| | / /___/ /___ _____ 
 / _` | | | | __| '_ \ / _ \ |/ / __  / __ `/ __ \
| (_| | |_| | |_| | | |  __/ | / /_/ / /_/ / /_/ /
 \__,_|\__,_|\__|_| |_|\___|_|/\__,_/\__,_/ .___/ 
                                         /_/ 
EOF
}
header_info
echo -e "Loading..."
APP="authelldap"
var_disk="4"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
header_info
if [[ ! -f /etc/systemd/system/lldap.service ]]; then msg_error "No LLDAP Installation Found!"; exit; fi
if [[ ! -f /etc/systemd/system/authelia.service ]]; then msg_error "No Authelia Installation Found!"; exit; fi
msg_info "Updating $APP"
apt update
apt upgrade -y lldap authelia
msg_ok "Updated $APP"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "LLDAP's WebUI should be reachable by going to the following URL:
     ${BL}http://${IP}:17170${CL}\n
You will need to create a secure user for authelia before integrating it. Please read more at:
     https://www.authelia.com/integration/ldap/introduction/#lldap
"