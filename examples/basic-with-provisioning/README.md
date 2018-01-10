# Prometheus with Provisioning

Creates one Prometheus server, integrated with Triton's Container Monitor service. Terraform to create and manage the 
infrastructure resources and provision the machines.

> :warning: _Note: This method with Terraform provisioning is only recommended for prototyping and light testing._

## Usage

Initialize and create the environment:

```
terraform init
terraform plan
terraform apply
```

## Cleanup

Remove all resources created by Terraform:

```
terraform destroy
```
