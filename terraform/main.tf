terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name                    = "${var.project}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project}-subnet"
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.vpc_network.name
  region        = var.region
}

resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_compute_instance" "vm_instance" {
  name         = "instance-${random_id.instance_id.hex}"
  machine_type = "e2-micro"
  tags         = ["www", "ssh"]
  // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_attached_disk
  lifecycle {
    ignore_changes = [attached_disk]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }

  boot_disk {
    initialize_params {
      image = var.os_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "ssh-keygen -R ${self.network_interface.0.access_config.0.nat_ip}"
  }

}

resource "google_compute_firewall" "http_firewall" {
  name    = "http-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["www"]
}

resource "google_compute_firewall" "ssh_firewall" {
  name    = "ssh-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_disk" "data_disk" {
  name = "datadisk"
  size = "30"
  type = "pd-standard"
  zone = var.zone
}

resource "google_compute_attached_disk" "vm_attached_disk" {
  disk     = google_compute_disk.data_disk.id
  instance = google_compute_instance.vm_instance.id


  connection {
    type = "ssh"
    user = var.ssh_user
    host = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
  }

  provisioner "file" {
    source      = "scripts/setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo sed -i -e 's/\r$//' /tmp/setup.sh", # Remove the spurious CR characters.
      "sudo /tmp/setup.sh",
    ]
  }
}

