# **Módulo Terraform: cloudops-ref-repo-aws-ecs-cluster-terraform**

## Descripción:

Este módulo facilita la creación de un Cluster ECS en AWS.

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo
El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-ecs-cluster-terraform/
└── sample/ecs_cluster
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars.sample
    └── variables.tf
├── .gitignore
├── CHANGELOG.md
├── data.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
```

- Los archivos principales del módulo (`data.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.

## Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
sample/ecs_cluster/providers.tf
provider "aws" {
  alias = "alias01"
  # ... otras configuraciones del provider
  
  default_tags {
    tags = var.common_tags
  }
}

sample/ecs_cluster/main.tf
module "ecs_cluster" {
  source = ""
  providers = {
    aws.project = aws.alias01
  }
  # ... resto de la configuración
}
```

## Uso del Módulo:

```hcl
module "ecs_cluster" {
  source = ""
  
  providers = {
    aws.project = aws.project
  }

  # Common configuration
  client      = "cliente01"
  project     = "proyecto01"
  environment = "dev"

  # ECS Cluster configuration 
  cluster_config = {
    "app01" = {
      containerInsights       = "enabled"
      enableCapacityProviders = true
      additional_tags         = {
        service-tier = "standard"
        backup-policy = "daily"
      }
    },
    "app02" = {
      containerInsights       = "enabled"
      enableCapacityProviders = false
      additional_tags         = {
        service-tier = "premium"
        backup-policy = "hourly"
      }
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.cluster_capacity_providers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="cluster_config"></a> [cluster_config](#input\cluster_config) | Mapa de configuraciones de clusters ECS donde la clave es el nombre de la aplicación.| `map(object)` | n/a | yes |
| <a name="containerInsights"></a> [containerInsights](#input\containerInsights) | Value to assign to the setting. Valid values: enabled, disabled.| `string` | n/a | yes |
| <a name="enableCapacityProviders"></a> [enableCapacityProviders](#input\enableCapacityProviders) | If true, is enabled FARGATE and FARGATE_SPOT.| `bool` | n/a | yes |
| <a name="additional_tags"></a> [additional_tags](#input\additional_tags) | Additional tags to apply to the ECS cluster.| `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="cluster_info.cluster_name"></a> [cluster_info.cluster_name](#output\cluster_info.cluster_name) | Cluster name |
| <a name="cluster_info.cluster_arn"></a> [cluster_info.cluster_arn](#output\cluster_info.cluster_arn) | Cluster ARN |
| <a name="cluster_info.cluster_id"></a> [cluster_info.cluster_id](#output\cluster_info.cluster_id) | Cluster ID |
| <a name="cluster_info.application"></a> [cluster_info.application](#output\cluster_info.application) | Application name |
