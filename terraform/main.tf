resource "google_compute_instance" "nfs_instance" {
  name         = "nfs-instance"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-2404-lts-amd64"
      size  = 30
    }
  }

  metadata_startup_script = <<EOF
  #!/bin/bash -ex
  apt-get update
  apt-get install -y nfs-kernel-server
  mkdir /opt/sfw
  chmod 1777 /opt/sfw
  echo "/opt/sfw/ *(rw,sync,no_root_squash,subtree_check)" | tee /etc/exports
  exportfs -ra
  EOF

  network_interface {
    network = "default"
    access_config {}
  }
}

module "controller" {
  depends_on = [ google_compute_instance.nfs_instance ]
  source = "./node"
  node_count = 1
  role = "controller"
  nfs_ip = google_compute_instance.nfs_instance.network_interface[0].access_config[0].nat_ip
}

module "workers" {
  depends_on = [ module.controller ]
  source = "./node"
  node_count = 3
  role = "worker"
  k3s_ip = module.controller.node_ips[0]
  nfs_ip = google_compute_instance.nfs_instance.network_interface[0].access_config[0].nat_ip
}

resource "google_compute_firewall" "cluster_fw" {
  name    = "cluster-firewall"
  network = "default"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  allow {
    ports = ["32000-32767"]
    protocol = "tcp"
  }

}