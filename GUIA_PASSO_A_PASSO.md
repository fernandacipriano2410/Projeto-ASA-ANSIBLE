# Guia de execução

1. Verificar `VBoxManage list hostonlyifs` e configurar `vboxnet0` em `192.168.56.1/24`.
2. Executar `ansible-galaxy collection install -r requirements.yml`.
3. Na raiz: `vagrant validate` e `vagrant up`.
4. Verificar `vagrant status` (ARQ, DB, APP, CLI ativos).
5. Configurar a resolução do domínio no Ubuntu hospedeiro, se necessário, com `scripts/configurar-dns-hospedeiro.sh`.
6. Testar `cd ansible && ansible todos -m ping` e os serviços conforme README.
7. Na raiz, usar o verificador do professor, se fornecido: `python3 verifica-proj1.py fernanda.julia`.
8. Para reaplicar: `vagrant provision cli` (o provisionador da última máquina alcança todos os hosts).

## Diagnóstico

- `No package matching nfs-common`: inspecionar `apt-get update`, fontes APT e conectividade; `comum.yml` atualiza os índices antes da instalação.
- `REMOTE HOST IDENTIFICATION HAS CHANGED`: confirmar fingerprint pela VM com `vagrant ssh NOME -c 'sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub'`; então atualizar apenas a entrada correspondente no `known_hosts`.
- `cli.fernanda.julia.devops` NXDOMAIN: conferir `dhcpd.leases`, DHCP, BIND9 e registro DDNS.
- `Can't open /etc/dhcp/ddns.key`: a geração TSIG deve ocorrer antes do `dhcpd -t` (já ordenado em `tasks/arq.yml`).
- `GRUB` durante upgrade: verificar `/dev/sda` e estado do `dpkg`; não usar comandos destrutivos em discos sem confirmar o ambiente.
- `vagrant up` inicia VMs mas não reprovisiona após uma primeira execução: `vagrant provision cli`.

Os comandos nesta versão não devem ser executados sobre máquinas de produção. O bloco de LVM gerencia três discos extras de 10 GB.
