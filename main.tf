terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.69.1"
    }
  }
}

provider "google" {
  # Configuration options
  credentials = "${file(var.gce_service_account)}" 
  project     = var.project # Replace this with your host project ID in quotes
  region      = var.region
  zone = var.zone
}

# KUBERNETES VPC
resource "google_compute_network" "vpc_network" {
name = "k8s-network"
auto_create_subnetworks = false
}

# PUBLIC SUBNET
resource "google_compute_subnetwork" "public-subnetwork" {
name = "k8s-subnetwork"
ip_cidr_range = "10.250.0.0/24"
region = var.region
network = google_compute_network.vpc_network.name  
}

# Router and Cloud NAT are required for installing packages from repos
## Create Cloud Router

resource "google_compute_router" "router" {
  project = var.project
  name    = "nat-router"
  network = google_compute_network.vpc_network.name 
  region  = var.region
}

## Create Nat Gateway

resource "google_compute_router_nat" "nat" {
  name                               = "dev-router-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}





#  CREATE INSTANCES


# STATIC IPS
resource "google_compute_address" "static1" {
  name = "controlplane-static-ip"
}

resource "google_compute_address" "static2" {
  name = "master1-static-ip"
}


resource "google_compute_instance" "controlplane" {
  project      = var.project
  zone         = var.zone
  name         = "controlplane"
  machine_type = var.machine_type
  tags = [ "kubernetes","controlplane" ]
  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  metadata = {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  network_interface {
   
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.public-subnetwork.self_link
     
    access_config {
       // external IP 
      nat_ip = google_compute_address.static1.address  # for remote-exec
    }
  }

 provisioner "remote-exec" {
     connection {
       host        = google_compute_address.static1.address
       type        = "ssh"
       user        = var.gce_ssh_user
       timeout     = "500s"
       private_key = file(var.gce_ssh_pv_key_file)
    }
    inline = [
      "sudo apt-get update -y",
      "sudo apt install python3-pip -y",
      "git clone https://github.com/kubernetes-sigs/kubespray.git ",
      "cd kubespray && git checkout release-2.22",
      "sudo pip install -r ~/kubespray/requirements-2.12.txt",
    ]
 }



}



# Create VM in  K8s VPC 
# master Node
resource "google_compute_instance" "kube-master" {
  project      = var.project
  zone         = var.zone
  name         = "master1"
  machine_type = var.machine_type
  tags = [ "kubernetes","kube-master" ]
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  
   metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
  
  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.public-subnetwork.self_link
   
  access_config {
     # external IP for shh connection after installation our cluster
      nat_ip = google_compute_address.static2.address  # 
    }

  }
}

# WORKER NODES
resource "google_compute_instance" "nodes" {
  project      = var.project
  zone         = var.zone
  
  count = var.num
  name         = element(var.tags,count.index)
  machine_type = var.machine_type
  tags = [ "kubernetes","kube-worker" ] # for firewall rules
  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  metadata = {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.public-subnetwork.self_link
    
  }

 
}


