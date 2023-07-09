# FIREWALL RULES


# KUBE MASTER FIREWALL RULE

resource "google_compute_firewall" "kube-master-fw" {
  name    = var.fw-k8s-master
  network = google_compute_network.vpc_network.name # 

  allow {
    protocol = "icmp"
  }
 # 6443	Kubernetes API server
 # 2379-2380	etcd server client API
 # 10250	Kubelet API
 # 10259	kube-scheduler
 # 10257	kube-controller-manager
 # |TCP|Inbound|22|remote access with ssh|Self|

  allow {
    protocol = "tcp"
    ports    = ["6443","2379-2380", "10250", "10257","10259","30000-32767" ]

  }
  source_tags = ["kube-master"]
  target_tags = ["kube-master"] 
  source_ranges = ["0.0.0.0/0"]




}

# KUBE WORKER FIREWALL RULE
resource "google_compute_firewall" "kube-worker-fw" {
  name    = var.fw-k8s-worker
  network = google_compute_network.vpc_network.name 


# |TCP|Inbound|10250|Kubelet API|Self, Control plane|
# |TCP|Inbound|30000-32767|NodePort Services|All|
# |TCP|Inbound|22|remote access with ssh|Self|
# |UDP|Inbound|8472|Cluster-Wide Network Comm. - Flannel VXLAN|Self|
  allow {
   protocol = "tcp"
    ports    = ["10250", "30000-32767"]
  }

  source_tags = ["kube-worker"]
  target_tags   = ["kube-worker"]
  source_ranges = ["0.0.0.0/0"]
}

# SSH FIREWALL RULE
resource "google_compute_firewall" "ssh" {
 

  allow {
    protocol = "icmp"
  }

  name    = "ssh"
  network = google_compute_network.vpc_network.name 

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["kube-master", "kube-worker", "controlplane"]
  source_ranges = ["0.0.0.0/0"]
}




# UDP  FIREWALL RULE
resource "google_compute_firewall" "udp" {


  name    = "udp"
  network = google_compute_network.vpc_network.name 

# UDP|Inbound|8472|Cluster-Wide Network Comm. - Flannel VXLAN|Self
  allow {
    protocol = "udp"
    ports    = ["8472"]
  }

  target_tags   = ["kube-master", "kube-worker"]
  source_tags = ["kube-master", "kube-worker"]
}

# OTHER  PORTS FIREWALL RULE
resource "google_compute_firewall" "http-https" {
  

  name    = "http-https"
  network = google_compute_network.vpc_network.name 
  
  allow {
    protocol = "icmp"
  }
   allow {
    protocol = "tcp"
    ports    = ["80","443"]
    
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["kube-master", "controlplane", "kube-worker"]

}