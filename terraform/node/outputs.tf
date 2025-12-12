output "node_ips" {
  value = [ for instance in google_compute_instance.k8s_node : instance.network_interface[0].access_config[0].nat_ip ]
}