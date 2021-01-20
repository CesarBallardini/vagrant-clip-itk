# -*- mode: ruby -*-
# vi: set ft=ruby :

# Para aprovechar este Vagrantfile necesita Vagrant y Virtualbox instalados:
#
#   * Virtualbox
#
#   * Vagrant
#
#   * Plugins de Vagrant:
#       + vagrant-proxyconf y su configuracion si requiere de un Proxy para salir a Internet
#       + vagrant-cachier
#       + vagrant-disksize
#       + vagrant-share
#       + vagrant-vbguest

VAGRANTFILE_API_VERSION = "2"

HOSTNAME = "clip"
DOMAIN   = "dev.ballardini.com.ar"


$post_up_message = <<POST_UP_MESSAGE
------------------------------------------------------
CLIP ITK

Desarrollo de aplicacines en Clipper xBase
------------------------------------------------------
POST_UP_MESSAGE


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.post_up_message = $post_up_message

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true

    # uso cachier con NFS solamente si el hostmanager gestiona los nombres en /etc/hosts del host
    if Vagrant.has_plugin?("vagrant-cachier")

      config.cache.auto_detect = false
      # W: Download is performed unsandboxed as root as file '/var/cache/apt/archives/partial/xyz' couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)

      config.cache.synced_folder_opts = {
        owner: "_apt"
      }
      # Configure cached packages to be shared between instances of the same base box.
      # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
      config.cache.scope = :box
   end

  end

 config.vm.define HOSTNAME do |srv|

    srv.vm.box = "ubuntu/focal64"
    #srv.vm.box = "debian/buster64"
    srv.vm.network "private_network", ip: "192.168.33.11"

    srv.vm.boot_timeout = 3600
    srv.vm.box_check_update = true
    srv.ssh.forward_agent = true
    srv.ssh.forward_x11 = true
    srv.vm.hostname = HOSTNAME

    if Vagrant.has_plugin?("vagrant-hostmanager")
      srv.hostmanager.aliases = %W(#{HOSTNAME}.#{DOMAIN} )
    end

    if Vagrant.has_plugin?("vagrant-vbguest") then
        srv.vbguest.auto_update = true
        srv.vbguest.no_install = false
    end

    srv.vm.synced_folder ".", "/vagrant", disabled: false, SharedFoldersEnableSymlinksCreate: false


    srv.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.cpus = 2
      vb.memory = "1024"
      # https://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm mas parametros para personalizar en VB
    end
  end

    ##
    # Aprovisionamiento
    #
    config.vm.provision "fix-no-tty", type: "shell" do |s|
        s.privileged = false
        s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
    end

    config.vm.provision "actualiza", type: "shell" do |s|  # http://foo-o-rama.com/vagrant--stdin-is-not-a-tty--fix.html
        s.privileged = false
        s.inline = <<-SHELL
          export DEBIAN_FRONTEND=noninteractive
          export APT_LISTCHANGES_FRONTEND=none
          export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

          sudo -E apt-get --purge remove apt-listchanges -y > /dev/null 2>&1
          sudo -E apt-get update -y -qq > /dev/null 2>&1
          sudo dpkg-reconfigure --frontend=noninteractive libc6 > /dev/null 2>&1
          sudo -E apt-get install linux-image-amd64 ${APT_OPTIONS}  || true
          sudo -E apt-get upgrade ${APT_OPTIONS} > /dev/null 2>&1
          sudo -E apt-get dist-upgrade ${APT_OPTIONS} > /dev/null 2>&1
          sudo -E apt-get autoremove -y > /dev/null 2>&1
          sudo -E apt-get autoclean -y > /dev/null 2>&1
          sudo -E apt-get clean > /dev/null 2>&1
        SHELL
    end

    config.vm.provision "ssh_pub_key", type: :shell do |s|
      begin
          ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
          s.inline = <<-SHELL
            mkdir -p /root/.ssh/
            touch /root/.ssh/authorized_keys
            echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
            echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
          SHELL
      rescue
          puts "No hay claves publicas en el HOME de su pc"
          s.inline = "echo OK sin claves publicas"
      end
    end

    config.vm.provision "compila_clip", type: "shell", keep_color: true, run: "never" do |s|
        s.privileged = false
        s.inline = <<-SHELL
          export DEBIAN_FRONTEND=noninteractive
          export APT_LISTCHANGES_FRONTEND=none
          export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

          echo
          echo '########################### Requisitos de clip en Debian 10'
          echo
          sudo -E apt-get update -y -qq 
          sudo apt-get install ${APT_OPTIONS} flex bison git
          sudo apt-get install ${APT_OPTIONS} libc6-dev libgpm-dev libncurses5-dev libpth-dev libmariadbclient-dev
          sudo apt-get install ${APT_OPTIONS} gcc-multilib libc6-i386 build-essential
          sudo apt-get install ${APT_OPTIONS} debhelper # para el make deb

          echo
          echo '########################### Clona repositorio'
          echo
          git clone https://github.com/CesarBallardini/clip-itk
          cd clip-itk/
          git checkout fix-make-deb  # rama de trabajo hasta que pueda construir los .deb

          echo
          echo '########################### Compila clip'
          echo
          sudo make system

          clip -V

          echo
          echo '########################### Genera tgz'
          echo
          sudo make tgz
          rsync -Pav clip_distrib /vagrant/


        SHELL
    end

    config.vm.provision "instala_clip", type: "shell", keep_color: true, run: "never" do |s|
        s.privileged = true
        s.inline = <<-SHELL
          export DEBIAN_FRONTEND=noninteractive
          export APT_LISTCHANGES_FRONTEND=none
          export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

          echo
          echo 'requisitos para cmpilar .prg con clip'
          echo
          sudo apt-get install ${APT_OPTIONS} libc6-dev libgpm-dev libncurses5-dev libpth-dev libmariadbclient-dev
          
          cd $(dirname $(find /vagrant/clip_distrib/ -name install.sh))

          CLIPROOT=/usr/local/clip
          COMPRESS_PRG='gzip'
          UNCOMPRESS_PRG='gzip -d'

          root=/

          [ ! -x /usr/sbin/groupadd ] || /usr/sbin/groupadd clip >/dev/null 2>&1 || true

          LOCALEDIRS="$CLIPROOT/locale.pot $CLIPROOT/locale.po $CLIPROOT/locale.mo"
          mkdir -p $LOCALEDIRS
          chgrp -R clip $LOCALEDIRS 2>/dev/null || true
          chmod -R g+w $LOCALEDIRS || true

          tar xzf clip-com_1.2.0-0.tar.gz        -C $root/
          tar xzf clip-dev_1.2.0-0.tar.gz        -C $root/
          tar xzf clip-gzip_1.2.0-0.tar.gz       -C $root/
          tar xzf clip-lib_1.2.0-0.tar.gz        -C $root/
          tar xzf clip-oasis_1.2.0-0.tar.gz      -C $root/
          tar xzf clip-postscript_1.2.0-0.tar.gz -C $root/
          tar xzf clip-prg_1.2.0-0.tar.gz        -C $root/
          tar xzf clip-r2d2_1.2.0-0.tar.gz       -C $root/
          tar xzf clip-rtf_1.2.0-0.tar.gz        -C $root/
          tar xzf clip-xml_1.2.0-0.tar.gz        -C $root/

          echo "/usr/local/clip/lib" | sudo tee  /etc/ld.so.conf.d/clip.conf
          sudo ldconfig


        SHELL
    end
end
