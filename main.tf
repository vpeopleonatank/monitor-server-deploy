provider "libvirt" {
  uri = "qemu+ssh://deploys@ams-kvm-remote-host/system"
}

resource "libvirt_pool" "zabbix" {
  name = "zabbix"
  type = "dir"
  path = var.libvirt_disk_path
}

resource "libvirt_volume" "zabbix-qcow2" {
  name = "zabbix-qcow2"
  pool = libvirt_pool.zabbix.name
  source = var.ubuntu_22_04_img_url
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/config/cloud_init.yml")
}

data "template_file" "network_config" {
  template = file("${path.module}/config/network_config.yml")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.zabbix.name
}

resource "libvirt_domain" "domain-zabbix" {
  name   = var.zabbix_vm_hostname
  memory = "8000"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
    hostname       = var.zabbix_vm_hostname
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.zabbix-qcow2.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello World'"
    ]

    connection {
      type                = "ssh"
      user                = var.ssh_username
      host                = libvirt_domain.domain-zabbix.network_interface[0].addresses[0]
      private_key         = file(var.ssh_private_key)
      bastion_host        = "ams-kvm-remote-host"
      bastion_user        = "deploys"
      bastion_private_key = file("~/.ssh/deploys.pem")
      timeout             = "2m"
    }
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "[nginx]" > nginx.ini
      echo "${libvirt_domain.domain-zabbix.network_interface[0].addresses[0]}" >> nginx.ini
      echo "[nginx:vars]" >> nginx.ini
      echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand=\"ssh -W %h:%p -q ams-kvm-remote-host\"'" >> nginx.ini
      ansible-playbook -u ${var.ssh_username} --private-key ${var.ssh_private_key} -i nginx.ini ansible/playbook.yml
      EOT
  }
}