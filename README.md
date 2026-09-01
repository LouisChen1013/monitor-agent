# Monitor Agent Deployment

## Terraform GCP

Create `terraform-gcp/terraform.tfvars`:

```hcl
gcp_project = "your-gcp-project-id"
gcp_region  = "asia-east1"
gcp_zone    = "asia-east1-a"

ssh_user            = "your-ssh-user"
ssh_public_key_path = "~/.ssh/monitor-agent-key.pub"

instances = {
  "central" = "rhel-cloud/rhel-8"
  "backend"  = "windows-cloud/windows-2022",
  "frontend"    = "rhel-cloud/rhel-8"
  "infra" = "ubuntu-os-cloud/ubuntu-2604-lts-amd64",
}
```

Deploy:

```sh
cd terraform-gcp
terraform init
terraform apply
terraform output vm_public_ip
terraform output vm_private_ip
```

## Terraform AWS

Create `terraform-aws/terraform.tfvars`:

```hcl
aws_region = "ap-east-2"
instance_type = "t3.small"

key_pair_name       = "monitor-agent-key"
ssh_public_key_path = "~/.ssh/monitor-agent-key.pub"

instances = {
  central  = "rhel-8"
  backend  = "windows-server-2022"
  frontend = "rhel-8"
  infra    = "ubuntu-2604"
}
```

AMI IDs are region-specific. You can use the built-in aliases `ubuntu-2604`, `rhel-8`, and `windows-server-2022`; Terraform will resolve them to AMI IDs for the selected region.

Useful outputs:

```sh
terraform output vm_public_ip
terraform output vm_private_ip
```

Deploy:

```sh
cd terraform-aws
terraform init
terraform apply
terraform output vm_public_ip
terraform output vm_private_ip
```

## Ansible

Update `ansible/ansible.cfg`:

```ini
remote_user=your-ssh-user
private_key_file=~/.ssh/monitor-agent-key
```

The default AWS dynamic inventory connects to instances by public IP.

For AWS dynamic inventory, install the required Python dependencies if Ansible reports missing `botocore[crt]`:

```sh
python3 -m pip install "botocore[crt]" boto3
```

Deploy the agent:

```sh
cd ../ansible
ansible-playbook deploy.yaml
```

Report host OS, CPU, RAM, and disk:

```sh
ansible-playbook install_python.yaml
ansible-playbook system_report.yaml
```

## Destroy

```sh
cd ../terraform-gcp
terraform destroy
```

For AWS:

```sh
cd ../terraform-aws
terraform destroy
```
