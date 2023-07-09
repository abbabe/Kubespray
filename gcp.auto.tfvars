
region = "us-east1"
zone =   "us-east1-b"
project = "<PROJECT ID>"
machine_type = "e2-standard-2"
image = "ubuntu-os-cloud/ubuntu-2004-lts"
gce_ssh_user = "<SSH KEY USER NAME"
gce_ssh_pub_key_file ="~/.ssh/<YOUR PUBLIC KEY>"
gce_ssh_pv_key_file = "~/.ssh/<YOUR PRIVATE KEY>"
gce_service_account = "~/.ssh/<YOUR GCP SERVICE ACCOUNT .json>"

tags = ["worker1", "worker2"]
num = 2




