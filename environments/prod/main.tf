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
# Provider (Default is Host Project for Network Ops)
############################################

provider "google" {
  project = var.host_project_id
  region  = var.region
}

############################################
# Enable Required APIs (In Host Project)
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
# Module 1: VPC (Host Project)
############################################

module "shared_vpc" {
  source = "../../modules/shared-vpc"

  host_project_id        = var.host_project_id
  network_name           = var.network_name
  routing_mode           = var.routing_mode
  enable_shared_vpc_host = var.enable_shared_vpc_host
  service_project_ids    = var.service_project_ids # This links Service Project to Host

  depends_on = [google_project_service.required_apis]
}

############################################
# Module 2: Subnets & IP Reservation
############################################

module "subnets" {
  source = "../../modules/subnets"

  # 1. Service Project (Where IPs are created)
  project_id = var.service_project_id

  # 2. Host Project (Where Subnets exist)
  host_project_id = var.host_project_id

  region = var.region

  # Subnet Names (Module looks them up in Host Project)
  kubernetes_subnet_name = var.kubernetes_subnet_name
  backend_subnet_name    = var.backend_subnet_name

  # Reserved IPs (Created in Service Project)
  k8s_master_ip       = var.k8s_master_ip
  k8s_worker_count    = var.k8s_worker_count
  k8s_worker_ips      = var.k8s_worker_ips
  backend_service_ips = var.backend_service_ips
}

############################################
# Module 3: Firewall (Host Project)
############################################

module "firewall" {
  source = "../../modules/firewall"

  # Firewall rules always live in the Host Project (VPC Owner)
  project_id        = var.host_project_id
  network_self_link = module.shared_vpc.network_self_link

  internal_source_ranges = var.internal_source_ranges
  k8s_api_source_ranges  = var.k8s_api_source_ranges
}

############################################
# Module 4: Service Accounts (Service Project)
############################################

module "service_accounts" {
  source = "../../modules/service-account"

  # SAs should belong to the Service Project (Tenant)
  project_id               = var.service_project_id
  
  k8s_master_sa_name       = var.k8s_master_sa_name
  k8s_worker_sa_name       = var.k8s_worker_sa_name
  backend_services_sa_name = var.backend_services_sa_name

  # Note: APIs must be enabled in Service Project too if not already
}

############################################
# Module 5: Compute Instances (Service Project)
############################################

module "compute_instances" {
  source = "../../modules/compute-instance"

  # VMs are created in the Service Project (Tenant)
  project_id        = var.service_project_id
  zone              = var.zone
  
  # They attach to the Network in the Host Project
  network_self_link = module.shared_vpc.network_self_link

  # Subnet Links come from the Subnets module (which read them from Host Project)
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

  # Golden Images
  os_images = var.os_images

  boot_disk_type = var.boot_disk_type
  labels         = var.labels
}

############################################
# Module 6: Cloud Storage (Service Project)
############################################

module "cloud_storage" {
  source = "../../modules/cloud-storage"

  # Buckets usually belong to the Service Project
  project_id                  = var.service_project_id
  
  location                    = var.region
  terraform_state_bucket_name = var.terraform_state_bucket_name

  create_backup_bucket = var.create_backup_bucket
  backup_bucket_name   = var.backup_bucket_name
  additional_buckets   = var.additional_buckets

  labels = var.labels
}

############################################
# Module 7: Artifact Registry (Service Project)
############################################

module "artifact_registry" {
  source = "../../modules/artifact-registry"

  # Repo belongs to Service Project
  project_id           = var.service_project_id
  
  location             = var.region
  docker_repository_id = var.docker_repository_id
  k8s_worker_sa_email  = module.service_accounts.k8s_worker_sa_email

  labels = var.labels

  depends_on = [module.service_accounts]
}