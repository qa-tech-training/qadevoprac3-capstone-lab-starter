resource "google_compute_instance" "k8s_node" {
    count = var.node_count
    name = "k8s-${var.role}-${count.index}"
    machine_type = "e2-medium"
    zone = "europe-west1-b"

    boot_disk {
      initialize_params {
        image = "ubuntu-2404-lts-amd64"
        size = 32
      }
    }

    metadata_startup_script = <<EOF
    #!/bin/bash -ex
    export NfsPublicIp=${var.nfs_ip}
    export K3sPublicIp=${var.k3s_ip}
    ${file("${path.root}/${var.role}.sh")}
    EOF

    network_interface {
      network = "default"
      access_config {}
    }

}
