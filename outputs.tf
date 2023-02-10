output "ip" {
  value = libvirt_domain.domain-zabbix.network_interface[0].addresses[0]
}

output "url" {
  value = "http://${libvirt_domain.domain-zabbix.network_interface[0].addresses[0]}"
}