### Overview
This repo provisions **Callzen confidential infra** on GCP using Terraform.

- **Environment entrypoint**: `terraform/environments/prod/`
- **Modules**: `terraform/modules/*`
- **Kubernetes control-plane**: **3 master nodes** (same golden image) + N workers
- **Networking**: Shared VPC (host project owns VPC + firewall; service project owns VMs/IPs/buckets/AR)

---

### Prerequisites (on any machine / jump box)
- **Terraform**: `>= 1.5`
- **Google Cloud SDK (`gcloud`)**
- **Access to GCP**:
  - Permissions in **host project** (VPC/firewall) and **service project** (VMs/IPs/buckets/AR)
  - Shared VPC is attached correctly (service project attached to host VPC)

---

### About the 3 master nodes
The code creates **exactly 3 masters** when both are set:

- `k8s_master_count = 3`
- `k8s_master_ips` contains **3 IPs** (one per master)

Instance names will be:
- `k8s-master`
- `k8s-master-2`
- `k8s-master-3`

All masters boot from the same image:
- `os_images.k8s_master = "projects/<project>/global/images/<image-name>"`

Note: VMs do **not** need access to the GCS bucket that originally stored the tarball once the **Compute Image** exists.

---

### Configure variables
Copy the example vars file and edit values:

```bash
cd terraform/environments/prod
cp terraform.tfvars.example terraform.tfvars
```

Update at minimum:
- **Projects**: `host_project_id`, `service_project_id`
- **Network/Subnets**: `network_name`, `kubernetes_subnet_name`, `backend_subnet_name`
- **IPs**: ensure all static internal IPs are inside your subnet primary range (e.g. `10.120.0.0/16`)
- **Images**: set `os_images` to your golden images
- **Buckets**: bucket names must be globally unique

---

### Run (from jump box / laptop)
From `terraform/environments/prod`:

```bash
terraform init
terraform validate
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

To destroy:

```bash
terraform destroy
```

---

### Remote state (recommended for multiple laptops)
If you plan to run Terraform from more than one laptop, you should use a **remote backend** (GCS bucket) so everyone shares the same state.

This repo currently has an empty `terraform/environments/prod/backend.tf`.
Add a GCS backend like:

```hcl
terraform {
  backend "gcs" {
    bucket = "<your-terraform-state-bucket>"
    prefix = "prod"
  }
}
```

Then re-init:

```bash
terraform init -reconfigure
```

---

### Running from another laptop (additional steps)
On the other laptop:

1. Install tools:
   - Terraform (same major/minor as your first machine)
   - `gcloud`

2. Authenticate (choose one):
   - **User ADC**:
     - `gcloud auth login`
     - `gcloud auth application-default login`
   - **Service Account (CI-style)**:
     - Use a service account with required roles and set credentials via `GOOGLE_APPLICATION_CREDENTIALS`

3. Ensure IAM is in place:
   - Terraform runner needs permissions in **host project** and **service project**
   - If the **image** is in a different project: grant `roles/compute.imageUser` on that image project
   - If startup scripts pull from GCS: grant `roles/storage.objectViewer` to the VM service accounts on that bucket

4. Use the same backend:
   - If using GCS backend, both machines must run `terraform init` and will share the same state.
   - Commit and share `.terraform.lock.hcl` so provider versions stay consistent across machines.

---

### Notes / troubleshooting
- If `terraform init` fails due to TLS/cert issues, update your OS trust store and retry, or use a corporate proxy CA if applicable.
- Keep `terraform.tfvars` out of git if it contains sensitive values.

