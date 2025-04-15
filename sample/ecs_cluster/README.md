# Ejemplo de Implementación: Cluster ECS

Este directorio contiene un ejemplo de implementación del módulo de Cluster ECS. Muestra cómo configurar y desplegar un cluster ECS en AWS utilizando el módulo de referencia.

## Estructura del Ejemplo

```
ecs_cluster/
├── data.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── terraform.tfvars.sample
└── variables.tf
```

## Requisitos Previos

- Terraform >= 1.0
- AWS CLI configurado con credenciales válidas
- Permisos IAM adecuados para crear recursos ECS

## Configuración

1. Copia el archivo `terraform.tfvars.sample` a `terraform.tfvars` y personaliza las variables según tus necesidades:

```bash
cp terraform.tfvars.sample terraform.tfvars
```

2. Edita el archivo `terraform.tfvars` para configurar:
   - Perfil AWS
   - Región AWS
   - Entorno (dev, qa, pdn)
   - Cliente
   - Proyecto
   - Etiquetas comunes

## Uso

1. Inicializa Terraform:

```bash
terraform init
```

2. Verifica el plan de ejecución:

```bash
terraform plan
```

3. Aplica la configuración:

```bash
terraform apply
```

## Personalización

Este ejemplo crea un cluster ECS con las siguientes características:

- Container Insights habilitado
- Capacity Providers (FARGATE y FARGATE_SPOT) habilitados
- Retención de logs configurada a 90 días
- Etiquetas adicionales para clasificación de recursos

Puedes personalizar la configuración modificando el bloque `cluster_config` en el archivo `main.tf`:

```hcl
cluster_config = {
  "app01" = {
    containerInsights       = "enabled"
    enableCapacityProviders = true
    log_retention_days      = 90
    additional_tags         = {
      service-tier = "standard"
      backup-policy = "daily"
    }
  }
}
```

Para añadir más clusters, simplemente agrega más entradas al mapa:

```hcl
cluster_config = {
  "app01" = {
    containerInsights       = "enabled"
    enableCapacityProviders = true
    log_retention_days      = 90
    additional_tags         = {
      service-tier = "standard"
      backup-policy = "daily"
    }
  },
  "app02" = {
    containerInsights       = "disabled"
    enableCapacityProviders = false
    log_retention_days      = 30
    additional_tags         = {
      service-tier = "basic"
    }
  }
}
```

## Outputs

Después de aplicar la configuración, puedes obtener información sobre el cluster ECS creado mediante:

```bash
terraform output
```

Los outputs incluyen:
- Nombre del cluster
- ARN del cluster
- ID del cluster
- Nombre de la aplicación
- Nombre del grupo de logs
- ARN del grupo de logs
