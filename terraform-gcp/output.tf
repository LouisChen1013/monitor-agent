output "vm_public_ip" {
  description = "VM Public IP to Ansible hosts"
  value = {
    for name, instance in google_compute_instance.monitor_vm :
    name => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "vm_private_ip" {
  description = "VM Private IP"
  value = {
    for name, instance in google_compute_instance.monitor_vm :
    name => instance.network_interface[0].network_ip
  }
}
