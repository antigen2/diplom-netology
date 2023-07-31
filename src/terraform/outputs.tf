output "instance_info" {
  value = {
    external_ip_address = yandex_compute_instance_group.node-group-01.instances[*].network_interface[0].nat_ip_address
    internal_ip_address = yandex_compute_instance_group.node-group-01.instances[*].network_interface[0].ip_address
    name = yandex_compute_instance_group.node-group-01.instances[*].name
  }
}
