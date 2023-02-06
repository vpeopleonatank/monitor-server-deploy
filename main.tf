terraform {
  required_version = ">= 1.0.1"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.10"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_domain" "terraform_test" {
  name = "terraform_test"
}