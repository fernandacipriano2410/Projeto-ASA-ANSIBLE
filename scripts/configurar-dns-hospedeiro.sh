#!/usr/bin/env bash
set -euo pipefail
iface="${1:-vboxnet0}"
# Somente configura o resolved na interface host-only; nao afeta outros dominios.
ip link show "$iface" >/dev/null
sudo resolvectl dns "$iface" 192.168.56.138
sudo resolvectl domain "$iface" '~fernanda.julia.devops'
sudo resolvectl flush-caches
resolvectl status "$iface"
