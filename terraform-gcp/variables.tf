variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
  default     = "gcp_project_id"
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "asia-east1"
}

variable "gcp_zone" {
  description = "GCP Zone"
  type        = string
  default     = "asia-east1-a"
}

variable "instance_type" {
  description = "VM Size"
  type        = string
  default     = "e2-micro"
}

variable "instance_max" {
  description = "max number of instance"
  type        = number
  default     = 5

  validation {
    condition     = var.instance_max < 6
    error_message = "Do not deploy more than 5 instance"
  }
}

variable "instances" {
  description = "instance"
  type        = map(string)
  validation {
    condition     = length(var.instances) <= var.instance_max
    error_message = "Deployment failed: You have exceeded the maximum allowed instance limit."
  }
  validation {
    condition = alltrue([
      for _, os in var.instances : contains([
        "ubuntu-os-cloud/ubuntu-2604-lts-amd64",
        "debian-cloud/debian-12"
      ], os)
    ])
    error_message = "Deployment failed: Only Ubuntu (ubuntu-2604-lts) and Debian (debian-12) OS images are allowed."
  }
}

variable "ssh_user" {
  description = "SSH user to add to instance metadata"
  type        = string
  default     = "ssh_username"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used for instance metadata"
  type        = string
  default     = "ssh_public_key_path"
}
