# Prometheus with Images

Creates one Prometheus server, integrated with Triton's Container Monitor service. Uses Packer to build the 
Prometheus machines and then Terraform to create and manage the infrastructure resources.

Note: This example uses the [`triton_image`](https://www.terraform.io/docs/providers/triton/d/triton_image.html)
data source to find the image built by Packer. This depends on the `image_name` property set in the Packer build.
If you change this image name, you must also update the data source that finds this image.

## Usage

Build the necessary images using [Packer](https://www.packer.io/):

1. Change directories to the `packer` directory: 
  ```
  cd packer
  ```
1. Copy the example variables file `prometheus-vars.json.example` to `prometheus-vars.json` and modify its contents to 
specify the path to the TLS certificates to use to authenticate to the CMON endpoint. The sdc-docker setup script is the 
easiest way to obtain these files - https://raw.githubusercontent.com/joyent/sdc-docker/master/tools/sdc-docker-setup.sh.
1. Build the Prometheus image using Packer:
  ```
  packer build -var-file prometheus-vars.json prometheus.json
  ```
1. Initialize and create the environment using Terraform:
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
