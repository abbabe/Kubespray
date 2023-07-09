output kube-master-ip {
  value       = google_compute_instance.kube-master.network_interface[0].network_ip
  sensitive   = false
  description = "private ip of the kube-master"
}

output kubemaster-ipexternal {
  value       = google_compute_instance.kube-master.network_interface[0].access_config[0].nat_ip
  sensitive   = false
  description = "external public ip of the kube-master"
}

output worker-1-ip {
  value       = google_compute_instance.nodes[0].network_interface[0].network_ip
  sensitive   = false
  description = "private ip of the worker1"
}

output worker_ips {
  value       = google_compute_instance.nodes[*].network_interface[0].network_ip
  sensitive   = false
  description = "private ip of the worker1"
}

output controlplane-ipexternal {
  value       = google_compute_instance.controlplane.network_interface[0].access_config[0].nat_ip
  sensitive   = false
  description = "external public ip of the ansible controlplane"
}

output controlplane-ipinternal {
  value       = google_compute_instance.controlplane.network_interface[0].network_ip
  sensitive   = false
  description = "internal public ip of the ansible controlplane"
}

