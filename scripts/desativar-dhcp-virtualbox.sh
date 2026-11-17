#!/usr/bin/env bash
set -euo pipefail
iface="${VBOX_HOSTONLY_IFACE:-vboxnet0}"
command -v VBoxManage >/dev/null || { echo 'VBoxManage ausente' >&2; exit 1; }
VBoxManage list hostonlyifs | grep -q "Name: *${iface}" || { echo "Interface ${iface} ausente. Crie a rede host-only 192.168.56.1/24 primeiro." >&2; exit 1; }
# Nunca desabilitar o DHCP da rede NAT, somente a interface host-only do projeto.
if VBoxManage dhcpserver modify --interface="$iface" --disable; then
  echo "DHCP VirtualBox desabilitado em ${iface}"
else
  echo "Verifique 'VBoxManage list dhcpservers' e a sintaxe da sua versao do VirtualBox" >&2
  exit 1
fi
