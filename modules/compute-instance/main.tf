# Confidential VMs for Kubernetes and Backend Services

terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

############################################
# Kubernetes Master Node
############################################

resource "google_compute_instance" "k8s_master" {
  name         = var.k8s_master_name
  project      = var.project_id
  zone         = var.zone
  machine_type = var.k8s_master_machine_type

  tags = ["k8s-master", "kubernetes", "confidential-vm"]

  confidential_instance_config {
    enable_confidential_compute = true
  }

  shielded_instance_config {
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = var.enable_vtpm
    enable_integrity_monitoring = var.enable_integrity_monitoring
  }

  scheduling {
    automatic_restart   = var.automatic_restart
    on_host_maintenance = var.on_host_maintenance
    preemptible         = var.preemptible
  }

  boot_disk {
    initialize_params {
      image = var.os_images.k8s_master
      size  = var.k8s_master_boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network_self_link
    subnetwork = var.kubernetes_subnet_self_link
    network_ip = var.k8s_master_ip
  }

  service_account {
    email  = var.k8s_master_sa_email
    scopes = ["cloud-platform"]
  }

  metadata = merge(
    {
      enable-oslogin         = var.enable_oslogin ? "TRUE" : "FALSE"
      block-project-ssh-keys = var.block_project_ssh_keys ? "TRUE" : "FALSE"
    },
    var.custom_metadata
  )

  metadata_startup_script = var.k8s_master_startup_script

  allow_stopping_for_update = true
  labels                    = var.labels
}

############################################
# Kubernetes Worker Nodes
############################################

resource "google_compute_instance" "k8s_workers" {
  count        = var.k8s_worker_count
  name         = "${var.k8s_worker_name_prefix}-${count.index + 1}"
  project      = var.project_id
  zone         = var.zone
  machine_type = var.k8s_worker_machine_type

  tags = ["k8s-worker", "kubernetes", "confidential-vm"]

  confidential_instance_config {
    enable_confidential_compute = true
  }

  shielded_instance_config {
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = var.enable_vtpm
    enable_integrity_monitoring = var.enable_integrity_monitoring
  }

  scheduling {
    automatic_restart   = var.automatic_restart
    on_host_maintenance = var.on_host_maintenance
    preemptible         = var.preemptible
  }

  boot_disk {
    initialize_params {
      image = var.os_images.k8s_worker
      size  = var.k8s_worker_boot_disk_size
      type  = var.boot_disk_type
    }
  }

  dynamic "attached_disk" {
    for_each = var.k8s_worker_data_disk_size > 0 ? [1] : []
    content {
      source = google_compute_disk.k8s_worker_data_disk[count.index].self_link
    }
  }

  network_interface {
    network    = var.network_self_link
    subnetwork = var.kubernetes_subnet_self_link
    network_ip = var.k8s_worker_ips[count.index]
  }

  service_account {
    email  = var.k8s_worker_sa_email
    scopes = ["cloud-platform"]
  }

  metadata = merge(
    {
      enable-oslogin         = var.enable_oslogin ? "TRUE" : "FALSE"
      block-project-ssh-keys = var.block_project_ssh_keys ? "TRUE" : "FALSE"
    },
    var.custom_metadata
  )

  metadata_startup_script = var.k8s_worker_startup_script

  allow_stopping_for_update = true
  labels                    = var.labels

  depends_on = [google_compute_disk.k8s_worker_data_disk]
}

############################################
# Worker Data Disks
############################################

resource "google_compute_disk" "k8s_worker_data_disk" {
  count   = var.k8s_worker_data_disk_size > 0 ? var.k8s_worker_count : 0
  name    = "${var.k8s_worker_name_prefix}-${count.index + 1}-data"
  project = var.project_id
  zone    = var.zone
  type    = var.data_disk_type
  size    = var.k8s_worker_data_disk_size

  labels = var.labels
}

############################################
# Backend Service VMs (Per-Service Images)
############################################

resource "google_compute_instance" "backend_services" {
  for_each = var.backend_services

  name         = each.value.name
  project      = var.project_id
  zone         = var.zone
  machine_type = each.value.machine_type

  tags = ["backend", each.key, "confidential-vm"]

  confidential_instance_config {
    enable_confidential_compute = true
  }

  shielded_instance_config {
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = var.enable_vtpm
    enable_integrity_monitoring = var.enable_integrity_monitoring
  }

  scheduling {
    automatic_restart   = var.automatic_restart
    on_host_maintenance = var.on_host_maintenance
    preemptible         = var.preemptible
  }

  boot_disk {
    initialize_params {
      image = var.os_images.backend[each.key]
      size  = each.value.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  dynamic "attached_disk" {
    for_each = each.value.data_disk_size > 0 ? [1] : []
    content {
      source = google_compute_disk.backend_data_disk[each.key].self_link
    }
  }

  network_interface {
    network    = var.network_self_link
    subnetwork = var.backend_subnet_self_link
    network_ip = each.value.ip_address
  }

  service_account {
    email  = var.backend_services_sa_email
    scopes = ["cloud-platform"]
  }

  metadata = merge(
    {
      enable-oslogin         = var.enable_oslogin ? "TRUE" : "FALSE"
      block-project-ssh-keys = var.block_project_ssh_keys ? "TRUE" : "FALSE"
    },
    var.custom_metadata
  )

  metadata_startup_script = lookup(each.value, "startup_script", "")

  allow_stopping_for_update = true
  labels                    = merge(var.labels, { service = each.key })

  depends_on = [google_compute_disk.backend_data_disk]

  lifecycle {
    precondition {
      condition     = contains(keys(var.os_images.backend), each.key)
      error_message = "Missing backend image for service '${each.key}' in os_images.backend"
    }
  }
}

############################################
# Backend Data Disks
############################################

resource "google_compute_disk" "backend_data_disk" {
  for_each = { for k, v in var.backend_services : k => v if v.data_disk_size > 0 }

  name    = "${each.value.name}-data"
  project = var.project_id
  zone    = var.zone
  type    = var.data_disk_type
  size    = each.value.data_disk_size

  labels = merge(var.labels, { service = each.key })
}
