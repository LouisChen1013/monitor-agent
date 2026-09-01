output "vm_public_ip" {
  description = "VM Public IP to Ansible hosts"
  value = {
    for name, instance in aws_instance.monitor_vm :
    name => instance.public_ip
  }
}

output "vm_private_ip" {
  description = "Private IPs of all instances."
  value = {
    for name, instance in aws_instance.monitor_vm :
    name => instance.private_ip
  }
}
