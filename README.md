# Projeto 01 — DevOps com Vagrant e Ansible

IFPB — Administração de Sistemas Abertos (2026.2)  
Professor: Leonidas Lima  
Equipe: Fernanda e Júlia

## Objetivo

Criar quatro máquinas Debian Bookworm com VirtualBox/Vagrant e provisioná-las automaticamente com Ansible, **a partir de `vagrant up`**.

## Antes de executar

No Ubuntu hospedeiro, instalar VirtualBox, Vagrant, Ansible, `ssh`, `ansible.posix` e `community.general`.

```bash
ansible-galaxy collection install -r requirements.yml
VBoxManage list hostonlyifs
VBoxManage list dhcpservers
```

A interface host-only `vboxnet0` precisa existir e estar configurada como `192.168.56.1/24`. O script chamado pelo Vagrant desliga somente o DHCP dessa interface. O DHCP NAT do VirtualBox deve permanecer ativo.

## Instalação

Na raiz do projeto:

```bash
vagrant validate
vagrant up
```

O Vagrant cria ARQ, DB, APP e CLI nessa ordem. Na última VM (CLI), chama o **provisionador Ansible** com o `ansible/site.yml` uma única vez para todas as VMs. O primeiro play gera `keys/fernanda` e `keys/julia`; o segundo prepara o ARQ; o terceiro configura DB, APP e CLI.

Ao recriar máquinas, verifique os avisos de identidade SSH; **não desabilite a verificação de host**. Se precisar reprovisionar depois da primeira instalação:

```bash
vagrant provision cli
```

Não utilize `vagrant up cli` isoladamente para construir o laboratório pela primeira vez; execute `vagrant up` sem argumentos.

## Infraestrutura

| VM | IP host-only | RAM | Serviço |
|---|---|---|---|
| ARQ | 192.168.56.138 | 512 MB | DHCP, BIND9, LVM, NFS |
| DB | 192.168.56.104, reserva por MAC | 512 MB | MariaDB, autofs |
| APP | 192.168.56.184, reserva por MAC | 512 MB | Apache, autofs |
| CLI | DHCP dinâmico (192.168.56.50–100) | 1024 MB | Firefox, xauth, autofs |

## Rede e DNS

O ARQ é servidor autoritativo `fernanda.julia.devops` e fornece DHCP. O domínio resolve ARQ, DB, APP e, via DDNS/TSIG, CLI. O DNS do **Ubuntu hospedeiro** deve consultar `192.168.56.138` para a zona do projeto. Consulte o script opcional `scripts/configurar-dns-hospedeiro.sh` depois de `vagrant up`; ele pode solicitar `sudo`.

## Evidências

```bash
cd ansible
ansible todos -m ping
ansible arq -b -m command -a 'lvs dados/ifpb'
ansible arq -b -m command -a 'systemctl is-active bind9'
ansible db -b -m command -a 'systemctl is-active mariadb'
ansible app -b -m command -a 'systemctl is-active apache2'
cd ..
python3 verifica-proj1.py fernanda.julia
```

O verificador do professor não acompanha esta entrega e modifica temporariamente usuários/arquivos do laboratório: execute apenas se estiver autorizado e após confirmar as identidades SSH.

## Observações

- Não publicar `keys/` nem a chave TSIG.
- Esta versão preserva DDNS porque o teste do professor usa `cli.fernanda.julia.devops`.
- O upgrade (`apt upgrade` modo seguro) está ativo em `ansible/vars.yml` por exigência do enunciado. Se o Debian/GRUB apresentar falha durante upgrade, interrompa e investigue, não force desativação permanente do requisito.
- O IP `192.168.56.184` para APP segue a interpretação adotada anteriormente; confirme a formação `1XY` com o professor.
- O provisionamento completo ainda precisa ser testado em um **ambiente zerado**; análises de sintaxe não comprovam execução no VirtualBox.
