variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default     = "/opt/kvm/pool1"
}

variable "ubuntu_22_04_img_url" {
  description = "ubuntu 22.04 image"
  default     = "https://cloud-images.ubuntu.com/jammy/20230110/jammy-server-cloudimg-amd64.img"
}

variable "zabbix_vm_hostname" {
  description = "zabbix vm hostname"
  default     = "zabbix"
}

variable "ssh_username" {
  description = "the ssh user to use"
  default     = "zabbix"
}

variable "ssh_private_key" {
  description = "the private key to use"
  default     = "~/.ssh/id_libvirt"
}
