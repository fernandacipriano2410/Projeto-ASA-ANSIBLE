Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
    vb.check_guest_additions = false
  end

  config.trigger.before :up do |t|
    t.warn = "Desabilitando DHCP do VirtualBox na rede host-only"
    t.run = { inline: "bash scripts/desativar-dhcp-virtualbox.sh" }
  end

  maquinas = {
    "arq" => { ram: 512, porta: 2221 },
    "db"  => { ram: 512, porta: 2232 },
    "app" => { ram: 512, porta: 2223 },
    "cli" => { ram: 1024, porta: 2224 }
  }

  maquinas.each do |nome, dados|
    config.vm.define nome do |vm|
      vm.vm.hostname = "#{nome}.fernanda.julia.devops"
      vm.vm.provider "virtualbox" do |vb|
        vb.memory = dados[:ram]
        vb.name = "asa-fernanda-julia-#{nome}"
        mac = { "db" => "080027ABCD11", "app" => "080027ABCD22" }[nome]
        vb.customize ["modifyvm", :id, "--macaddress2", mac] if mac
      end

      if nome == "arq"
        vm.vm.network "private_network", ip: "192.168.56.138"
        (1..3).each do |n|
          vm.vm.disk :disk, name: "dados#{n}", size: "10GB", primary: false
        end
      else
        vm.vm.network "private_network", ip: "192.168.56.240", auto_config: false
      end

      vm.vm.network "forwarded_port", guest: 22, host: dados[:porta], id: "ssh", auto_correct: false

      if nome == "cli"
        vm.vm.provision "ansible" do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.playbook = "ansible/site.yml"
          ansible.inventory_path = "ansible/inventory.ini"
          ansible.limit = "all,localhost"
        end
      end
    end
  end
end
