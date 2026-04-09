terraform {
  backend "gcs" {
    bucket = "terraform-state-project-96d8ec0c"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.30"
    }
  }
}

provider "google" {
  project = "project-96d8ec0c-24f0-4d1c-bb4"
  region  = "asia-south1"

  impersonate_service_account = "terraform-sa@project-96d8ec0c-24f0-4d1c-bb4.iam.gserviceaccount.com"
}

resource "google_compute_network" "vpc" {
  name                    = "sreddy-my-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "asia-south1"
  network       = google_compute_network.vpc.id
}

resource "google_compute_instance" "vm" {
  name         = "sreddy-test-vm"
  machine_type = "e2-micro"
  zone         = "asia-south1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  tags = ["created-by-sahana-reddy"]
}
