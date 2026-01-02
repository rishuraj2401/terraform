############################################
# Root module for Callzen Confidential Infra
############################################

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
# Provider
############################################

provider "google" {
  project = var.host_project_id
  region  = var.region
}

############################################
# Enable Required APIs
############################################

resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ])

  project            = var.host_project_id
  service            = each.key
  disable_on_destroy = false
}

############################################
# Module 1: VPC
############################################

module "shared_vpc" {
  source = "../../modules/shared-vpc"

  host_project_id        = var.host_project_id
  network_name           = var.network_name
  routing_mode           = var.routing_mode
  enable_shared_vpc_host = var.enable_shared_vpc_host
  service_project_ids    = var.service_project_ids

  depends_on = [google_project_service.required_apis]
}

############################################
# Module 2: Subnets
############################################

module "subnets" {
  source = "../../modules/subnet"

  project_id        = var.host_project_id
  region            = var.region
  network_self_link = module.shared_vpc.network_self_link

  kubernetes_subnet_name = var.kubernetes_subnet_name
  kubernetes_subnet_cidr = var.kubernetes_subnet_cidr

  backend_subnet_name = var.backend_subnet_name
  backend_subnet_cidr = var.backend_subnet_cidr

  k8s_master_ip       = var.k8s_master_ip
  k8s_worker_count    = var.k8s_worker_count
  k8s_worker_ips      = var.k8s_worker_ips
  backend_service_ips = var.backend_service_ips

  enable_private_google_access = true
}

############################################
# Module 3: Firewall
############################################

module "firewall" {
  source = "../../modules/firewall"

  project_id        = var.host_project_id
  network_self_link = module.shared_vpc.network_self_link

  internal_source_ranges = var.internal_source_ranges
  k8s_api_source_ranges  = var.k8s_api_source_ranges
}

############################################
# Module 4: Service Accounts
############################################

module "service_accounts" {
  source = "../../modules/service-account"

  project_id               = var.host_project_id
  k8s_master_sa_name       = var.k8s_master_sa_name
  k8s_worker_sa_name       = var.k8s_worker_sa_name
  backend_services_sa_name = var.backend_services_sa_name

  depends_on = [google_project_service.required_apis]
}

############################################
# Module 5: Compute Instances (Golden Images)
############################################

module "compute_instances" {
  source = "../../modules/compute-instance"

  project_id        = var.host_project_id
  zone              = var.zone
  network_self_link = module.shared_vpc.network_self_link

  kubernetes_subnet_self_link = module.subnets.kubernetes_subnet_self_link
  backend_subnet_self_link    = module.subnets.backend_subnet_self_link

  # Kubernetes Master
  k8s_master_name           = var.k8s_master_name
  k8s_master_machine_type   = var.k8s_master_machine_type
  k8s_master_boot_disk_size = var.k8s_master_boot_disk_size
  k8s_master_ip             = var.k8s_master_ip
  k8s_master_sa_email       = module.service_accounts.k8s_master_sa_email
  k8s_master_startup_script = var.k8s_master_startup_script

  # Kubernetes Workers
  k8s_worker_count          = var.k8s_worker_count
  k8s_worker_name_prefix    = var.k8s_worker_name_prefix
  k8s_worker_machine_type   = var.k8s_worker_machine_type
  k8s_worker_boot_disk_size = var.k8s_worker_boot_disk_size
  k8s_worker_ips            = var.k8s_worker_ips
  k8s_worker_sa_email       = module.service_accounts.k8s_worker_sa_email
  k8s_worker_startup_script = var.k8s_worker_startup_script

  # Backend Services
  backend_services          = var.backend_services
  backend_services_sa_email = module.service_accounts.backend_services_sa_email

  # 🔥 PER-ROLE / PER-SERVICE GOLDEN IMAGES
  os_images = var.os_images

  boot_disk_type = var.boot_disk_type
  labels         = var.labels
}

############################################
# Module 6: Cloud Storage
############################################

module "cloud_storage" {
  source = "../../modules/cloud-storage"

  project_id                  = var.host_project_id
  location                    = var.region
  terraform_state_bucket_name = var.terraform_state_bucket_name

  create_backup_bucket = var.create_backup_bucket
  backup_bucket_name   = var.backup_bucket_name
  additional_buckets   = var.additional_buckets

  labels = var.labels

  depends_on = [google_project_service.required_apis]
}

############################################
# Module 7: Artifact Registry
############################################

module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id           = var.host_project_id
  location             = var.region
  docker_repository_id = var.docker_repository_id
  k8s_worker_sa_email  = module.service_accounts.k8s_worker_sa_email

  labels = var.labels

  depends_on = [
    google_project_service.required_apis,
    module.service_accounts
  ]
}
