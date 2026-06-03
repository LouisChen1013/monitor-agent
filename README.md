# Monitor Agent Deployment

## Terraform

Create `terraform-gcp/terraform.tfvars`:

```hcl
gcp_project = "your-gcp-project-id"
gcp_region  = "asia-east1"
gcp_zone    = "asia-east1-a"

ssh_user            = "your-ssh-user"
ssh_public_key_path = "/path/to/id_rsa.pub"

instances = {
  monitor-ubuntu = "ubuntu-os-cloud/ubuntu-2604-lts-amd64"
  monitor-debian = "debian-cloud/debian-12"
}
```

Deploy:

```sh
cd terraform-gcp
terraform init
terraform apply
terraform output vm_public_ip
```

## Ansible

Update `ansible/ansible.cfg`:

```ini
remote_user=your-ssh-user
private_key_file=/path/to/id_rsa
```

Deploy the agent:

```sh
cd ../ansible
ansible-playbook deploy.yaml
```

## Destroy

```sh
cd ../terraform-gcp
terraform destroy
```
