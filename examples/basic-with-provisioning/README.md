# Prometheus with Provisioning

Creates one Prometheus server, integrated with Triton's Container Monitor service. Terraform to create and manage the 
infrastructure resources and provision the machines.

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
