terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.22"
    }
  }
}

provider "google" {
  project = var.gcp_project
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

variable "gcp_project" {}
output "JENKINS_IP" {
  value = google_compute_instance.jenkins_server.network_interface[0].access_config[0].nat_ip
}

resource "google_compute_instance" "jenkins_server" {
  name         = "jenkins-server"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-2404-lts-amd64"
      size  = 16
    }
  }

  metadata_startup_script = <<EOF
  #!/bin/bash -ex
  apt-get update
  apt-get install -y wget curl unzip openjdk-21-jdk
  wget https://releases.hashicorp.com/terraform/1.14.1/terraform_1.14.1_linux_amd64.zip
  unzip terraform_1.14.1_linux_amd64.zip -d /usr/local/bin
  rm terraform_1.14.1_linux_amd64.zip
  curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz
  tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz
  sudo install terrascan /usr/local/bin && rm terrascan
  curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
  echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
  apt-get update
  apt-get install -y jenkins
  systemctl enable --now jenkins
  EOF

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_firewall" "default" {
  name    = "lab-firewall"
  network = "default"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

}