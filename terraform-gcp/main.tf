# VPC
resource "google_compute_network" "vpc" {
  name                    = "monitor-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "monitor-subnet"
  ip_cidr_range = "192.168.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
}

# Firewall (SSH)
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# VM Instance
resource "google_compute_instance" "monitor_vm" {
  for_each     = var.instances
  name         = each.key
  machine_type = var.instance_type

  labels = {
    managed_by = "terraform"
    role       = each.key
  }

  boot_disk {
    initialize_params {
      image = each.value
      size  = 10
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.name

    # Allocate an ephemeral external IP automatically.
    access_config {
    }
  }

  # Automatically inject your SSH public key
  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }
}
