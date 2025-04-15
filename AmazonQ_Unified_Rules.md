# Reglas para Generación de Infraestructura como Código

## 1. Introducción y Propósito
Este documento establece las reglas y estándares para la creación y modificación de infraestructura como código (IaC) en nuestra organización. Su objetivo es garantizar implementaciones consistentes, seguras y mantenibles que sigan las mejores prácticas de la industria.

**IMPORTANTE**: Estas reglas constituyen la línea base obligatoria que toda herramienta de Inteligencia Artificial (Amazon Q, ChatGPT, Claude, etc.) debe seguir al generar o modificar infraestructura como código para nuestra organización. Ninguna IA debe desviarse de estos estándares sin autorización explícita.

## 2. Instrucciones para Amazon Q
- Cuando se solicite ayuda para crear o modificar infraestructura como código (IaC), Amazon Q debe seguir estas reglas sin excepción:
    - **Monitoreo**: Implementar las reglas de monitoreo definidas en la sección correspondiente.
    - **Nomenclatura**: Seguir los estándares de nomenclatura establecidos para todos los recursos.
    - **Seguridad**: Aplicar las mejores prácticas de seguridad definidas y hacer recomendaciones de seguridad de nube (AWS, Azure y GCP).
    - **Documentación**: Generar documentación clara para cada componente creado.
    - **Modularización**: Estructurar el código en módulos reutilizables y escalables.
    - **Etiquetado**: Aplicar etiquetas consistentes a todos los recursos de acuerdo a la Política de Etiquetado.
    - **Validación**: Incluir pasos de validación y pruebas.

## 3. Proceso de Verificación
- Para cada solicitud de IaC, Amazon Q debe:
    - Identificar qué reglas aplican al caso específico
    - Confirmar explícitamente que está siguiendo cada regla aplicable
    - Proporcionar una lista de verificación al final de la respuesta
## 4. Convenciones de Nomenclatura
- Todos los recursos de infraestructura deben seguir el estándar: `{client}-{functionality}-{environment}-resource-type`
  - Ejemplo: `pragma-backupstrategy-dev-backup-vault`
  - Ejemplo: `acme-webapp-pdn-lambda`
  - Ejemplo: `client-datawarehouse-qa-rds`

## 5. Seguridad
- Todos los recursos deben implementar seguridad en tránsito:
  - Usar TLS/SSL para todas las comunicaciones
  - Configurar políticas de seguridad para API Gateway, ALB, CloudFront
  - Todos los servicios deben tener habilitados los logs y estos deben tener una retención definida
  - Implementar VPC endpoints para servicios AWS cuando sea posible
  - Usar AWS PrivateLink para conexiones entre servicios

- Todos los recursos deben implementar seguridad en reposo:
  - Cifrado de datos con AWS KMS para todos los servicios de almacenamiento
  - Habilitar cifrado por defecto para S3, EBS, RDS, DynamoDB
  - Usar CMKs (Customer Managed Keys) para datos sensibles
  - Configurar políticas de acceso restrictivas

- Restricciones de acceso de red:
  - Ningún puerto de alto impacto debe estar expuesto a 0.0.0.0/0
  - Limitar el acceso a rangos de IP específicos y necesarios
  - Puertos sensibles (SSH, RDP, bases de datos) nunca deben estar abiertos a internet
  - No crear bastion hosts con acceso público directo
  - Implementar AWS Systems Manager Session Manager para acceso administrativo seguro
  - Cuando sea necesario un bastion host, debe configurarse con acceso a través de SSM sin exponer puertos SSH
  - Usar Security Groups con reglas de entrada y salida restrictivas

- Implementar rotación automática de credenciales:
  - Rotación de secretos en Secrets Manager cada 30 días
  - Rotación de claves de acceso IAM cada 90 días
  - Configurar AWS WAF con reglas OWASP Top 10 para todas las APIs y aplicaciones web
  - Habilitar GuardDuty en todas las cuentas con notificaciones centralizadas
  - Implementar Security Hub con estándares CIS AWS Foundations Benchmark
## 6. Monitoreo y Observabilidad

### 6.1 Principios Generales
- Todos los recursos deben implementar monitoreo y observabilidad adecuados
- Configurar dashboards por proyecto y por cliente
- Establecer umbrales de alerta basados en patrones de uso normales
- Configurar notificaciones a través de SNS para eventos críticos
- Implementar X-Ray para servicios que requieran trazabilidad
- Utilizar métricas personalizadas para KPIs específicos del negocio

### 6.2 Logs para Servicios con Capacidades Nativas de Logging
Para servicios AWS que soportan logging nativo (como Lambda, API Gateway, ECS, etc.):

- **Habilitar logs obligatoriamente** para todos los recursos
- Configurar la retención de logs según la criticidad:
  ```hcl
  variable "log_retention_days" {
    description = "Días de retención para los logs de CloudWatch"
    type        = number
    default     = 30  # Valor predeterminado
  }
  
  resource "aws_cloudwatch_log_group" "example" {
    name              = "/aws/lambda/${aws_lambda_function.example.function_name}"
    retention_in_days = var.log_retention_days
  }
  ```
- Implementar niveles de log apropiados (INFO, ERROR, DEBUG) según el entorno
- Logs operacionales: 30 días mínimo
- Logs de seguridad: 90 días mínimo
- Logs de auditoría: 1 año mínimo

### 6.3 Monitoreo para Servicios sin Capacidades Nativas de Logging
Para servicios que no tienen capacidades nativas de logging (como SQS, SNS, etc.):

- **Implementar CloudWatch Alarms** para métricas críticas:
  ```hcl
  variable "enable_alarms" {
    description = "Habilitar alarmas de CloudWatch"
    type        = bool
    default     = true
  }
  
  resource "aws_cloudwatch_metric_alarm" "example" {
    count = var.enable_alarms ? 1 : 0
    
    alarm_name          = "${var.client}-${var.functionality}-${var.environment}-resource-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    metric_name         = "MetricName"
    namespace           = "AWS/Service"
    period              = 300
    statistic           = "Maximum"
    threshold           = var.alarm_threshold
    alarm_description   = "Alarma para monitorear recurso"
    
    dimensions = {
      ResourceId = aws_resource.example.id
    }
    
    alarm_actions = [aws_sns_topic.alarm_topic[0].arn]
  }
  ```

- **Configurar CloudTrail para auditoría** (opcional):
  ```hcl
  variable "enable_cloudtrail" {
    description = "Habilitar CloudTrail para auditoría"
    type        = bool
    default     = false
  }
  ```

### 6.4 Centralización de Logs
- Implementar una solución de logs centralizados para todos los servicios
- Configurar filtros de métricas para generar alarmas basadas en patrones en los logs
- Considerar soluciones como OpenSearch (ElasticSearch) para análisis avanzado de logs
## 7. Política de Etiquetado

### 7.1 Etiquetas Obligatorias
- Implementar etiquetado a través de `default_tags` en el proveedor AWS:
  ```hcl
  provider "aws" {
    default_tags {
      tags = {
        environment = "dev"
        project     = "payments"
        owner       = "cloudops"
        client      = "pragma"
        area        = "infrastructure"
        provisioned = "terraform"
        datatype    = "operational"
      }
    }
  }
  ```
- Todos los recursos deben incluir al menos las siguientes etiquetas en `default_tags`:
  - `owner`: nombre del responsable, equipo o área (ejemplo: `cloudops`, `nombre.apellido`, `team-name`)
  - `environment`: entorno de despliegue (`dev`, `qa`, `pdn`)
  - `project`: nombre del proyecto al que pertenece el recurso
  - `client`: nombre del cliente para el que se crea el recurso
  - `area`: área funcional (ejemplo: `infrastructure`, `security`, `data`)
  - `provisioned`: método de aprovisionamiento (ejemplo: `terraform`, `cloudformation`, `manual`)
  - `datatype`: tipo de datos que maneja el recurso (ejemplo: `operational`, `sensitive`, `public`)

### 7.2 Etiquetas Específicas de Recursos
- La etiqueta `Name` debe generarse automáticamente siguiendo la convención de nomenclatura estándar.
- Implementar soporte para etiquetas adicionales específicas por recurso mediante el patrón `additional_tags`:

#### Implementación en Variables del Módulo:
```hcl
variable "sqs_config" {
  description = "Configuración de colas SQS"
  type = map(object({
    # Otras propiedades del recurso...
    additional_tags = optional(map(string), {})
  }))
}
```

#### Aplicación en los Recursos:
```hcl
resource "aws_sqs_queue" "sqs" {
  # Otras configuraciones...
  
  # Etiquetas - Combinar Name y etiquetas adicionales específicas
  tags = merge(
    {
      Name = "${var.client}-${var.functionality}-${var.environment}-${resource_type}-${resource_name}"
    },
    each.value["additional_tags"]
  )
}
```

#### Ejemplo de Uso:
```hcl
sqs_config = {
  "orders" = {
    # Otras configuraciones...
    additional_tags = {
      service-tier = "standard"
      backup-policy = "none"
      data-classification = "internal"
    }
  }
}
```

### 7.3 Jerarquía de Etiquetas
1. Las etiquetas definidas en `default_tags` se aplican a todos los recursos.
2. Las etiquetas específicas definidas en `tags` a nivel de recurso tienen prioridad sobre las de `default_tags`.
3. La etiqueta `Name` debe generarse siempre según la convención de nomenclatura estándar.
## 8. Infraestructura como Código (IaC)
- Usar Terraform como herramienta principal para todos los despliegues
- Organizar el código en módulos altamente escalables y reutilizables:
  - Crear módulos independientes para cada tipo de recurso o conjunto de recursos relacionados
  - Implementar estructura jerárquica de módulos (módulos que llaman a otros módulos)
  - Seguir el patrón de composición para combinar módulos en soluciones completas
  - Versionar los módulos para garantizar la estabilidad

### 8.1 Prácticas de Terraform
- **Utilizar mapas de objetos para configuraciones de recursos**:
  ```hcl
  # RECOMENDADO: Usar mapas de objetos para recursos
  variable "sqs_config" {
    description = "Configuración de colas SQS"
    type = map(object({
      delay_seconds = number
      max_message_size = number
      # Otras propiedades...
      additional_tags = optional(map(string), {})
    }))
  }
  
  # Implementación con for_each
  resource "aws_sqs_queue" "sqs" {
    for_each = var.sqs_config
    
    name = "${var.client}-${var.functionality}-${var.environment}-sqs-${each.key}"
    delay_seconds = each.value["delay_seconds"]
    # Otras configuraciones...
  }
  
  # NO RECOMENDADO: Usar listas de objetos
  variable "sqs_queues" {
    description = "Lista de colas SQS"
    type = list(object({
      name = string
      delay_seconds = number
      # Otras propiedades...
    }))
  }
  ```

- **Ventajas de usar mapas de objetos**:
  - Facilita la referencia a recursos específicos por clave
  - Previene problemas con el índice cuando se eliminan elementos del medio de una lista
  - Permite actualizaciones y modificaciones más seguras
  - Mejora la legibilidad y mantenibilidad del código
  - Facilita la adición o eliminación de recursos sin afectar a otros

- Implementar `locals` para transformaciones y cálculos internos:
  ```hcl
  locals {
    queue_names = {
      for k, v in var.sqs_config : k => {
        standard_name = "${var.client}-${var.functionality}-${var.environment}-${v["dead_letter_queue"] ? "dlq" : "sqs"}-${k}"
        fifo_name = "${var.client}-${var.functionality}-${var.environment}-${v["dead_letter_queue"] ? "dlq" : "sqs"}-${k}.fifo"
        final_name = v["fifo_queue"] ? "${var.client}-${var.functionality}-${var.environment}-${v["dead_letter_queue"] ? "dlq" : "sqs"}-${k}.fifo" : "${var.client}-${var.functionality}-${var.environment}-${v["dead_letter_queue"] ? "dlq" : "sqs"}-${k}"
      }
    }
  }
  ```

- **Usar `for_each` en lugar de `count` para recursos con claves únicas**
- Implementar validación de variables con reglas de validación:
  ```hcl
  variable "environment" {
    description = "Entorno de despliegue (dev, qa, pdn)"
    type        = string
    validation {
      condition     = contains(["dev", "qa", "pdn"], var.environment)
      error_message = "El entorno debe ser uno de: dev, qa, pdn."
    }
  }
  ```
- Utilizar outputs para exponer información relevante entre módulos
- Aplicar el principio DRY (Don't Repeat Yourself) en todas las configuraciones

### 8.2 Documentación y mantenimiento:
- Documentar todas las variables, outputs y recursos en cada módulo
- Incluir ejemplos completos de uso para cada módulo
- Mantener un README actualizado con instrucciones de implementación
- Incluir diagramas de arquitectura cuando sea apropiado

### 8.3 Control de versiones y CI/CD:
- Implementar flujos de trabajo de CI/CD para validación y despliegue
- Utilizar remote state con bloqueo para prevenir conflictos
- Implementar workspaces para separar entornos cuando sea apropiado
## 9. Estructura de Directorios Terraform
Todos los proyectos deben seguir esta estructura:
```
project-root/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   ├── qa/
│   └── pdn/
├── modules/
│   ├── networking/
│   ├── compute/
│   ├── database/
│   └── security/
├── scripts/
├── .gitignore
└── README.md
```

## 10. Ubicación y Organización de Módulos
- Todos los módulos de IaC deben almacenarse en la ruta base: `/Users/cristian.noguera/Pragma/CloudOps/amazonq/`
- La estructura de directorios debe organizarse por proveedor de nube y tipo de módulo:
  ```
  /Users/cristian.noguera/Pragma/CloudOps/amazonq/
  ├── aws/
  │   ├── compute/
  │   │   ├── ec2/
  │   │   ├── lambda/
  │   │   └── ecs/
  │   ├── storage/
  │   │   ├── s3/
  │   │   ├── ebs/
  │   │   └── efs/
  │   ├── database/
  │   │   ├── rds/
  │   │   ├── dynamodb/
  │   │   └── elasticache/
  │   ├── networking/
  │   │   ├── vpc/
  │   │   ├── security-groups/
  │   │   └── load-balancers/
  │   └── security/
  │       ├── iam/
  │       ├── kms/
  │       └── waf/
  ├── azure/
  │   ├── compute/
  │   ├── storage/
  │   ├── database/
  │   ├── networking/
  │   └── security/
  ├── gcp/
  │   ├── compute/
  │   ├── storage/
  │   ├── database/
  │   ├── networking/
  │   └── security/
  └── common/
      ├── templates/
      ├── scripts/
      └── policies/
  ```
- Cada módulo debe seguir la estructura interna definida en la sección 9
- Los proyectos que implementen estos módulos deben referenciarlos usando rutas relativas o remotas según corresponda
- Mantener un archivo `README.md` en cada directorio de nube con un índice de los módulos disponibles
- Implementar un sistema de versionado para cada módulo siguiendo el formato semántico (MAJOR.MINOR.PATCH)
## 11. Gestión de Costos
- Implementar etiquetas de asignación de costos en todos los recursos
- Configurar presupuestos por proyecto y alertas de umbral
- Implementar políticas de lifecycle para almacenamiento
- Utilizar instancias reservadas o Savings Plans para cargas de trabajo predecibles
- Configurar AWS Cost Explorer para análisis mensual de gastos
- Implementar AWS Budgets con alertas al 80% y 100% del presupuesto

## 12. Proceso de Revisión y Aprobación
- Todo código IaC debe pasar por revisión de pares antes del despliegue
- Implementar proceso de aprobación formal para cambios en entornos de producción
- Requisitos mínimos para aprobación:
  - Validación de seguridad (terraform plan con checkov o similar)
  - Revisión de costos estimados
  - Verificación de cumplimiento con estándares de nomenclatura y etiquetado
  - Pruebas en entorno no productivo

## 13. Recuperación ante Desastres
- Definir RTO (Recovery Time Objective) y RPO (Recovery Point Objective) para cada aplicación (Pedir al usuario si se tienen estos datos)
- Implementar estrategias de backup automatizadas con AWS Backup
- Configurar replicación cross-region para servicios críticos (Solo hacerlo a manera de recomendación y mostrarlo como sugerencia, no se debe hacer en la solicitud inicial)
- Documentar y probar procedimientos de recuperación trimestralmente
- Implementar arquitecturas multi-región para aplicaciones de alta disponibilidad (Solo hacerlo a manera de recomendación y mostrarlo como sugerencia, no se debe hacer en la solicitud inicial)

## 14. Mejores Prácticas Generales
- Implementar principio de privilegio mínimo para todos los roles IAM
- Configurar monitoreo y alertas para todos los recursos críticos
- Implementar estrategias de respaldo y recuperación
- Usar Auto Scaling para servicios que lo requieran
- Implementar arquitecturas multi-AZ para alta disponibilidad
- Seguir el Well-Architected Framework de AWS

## 15. Redes
- Usar subredes privadas para recursos que no requieran acceso directo desde internet
- Implementar NACLs y Security Groups restrictivos
- No crear los security groups por defecto
- Configurar VPC Flow Logs para auditoría
- Usar Transit Gateway para conexiones entre múltiples VPCs cuando sea necesario

## 16. Cumplimiento y Gobernanza
- Implementar AWS Config para evaluación continua de conformidad (Solo hacer la recomendación al finalizar)
- Usar AWS CloudTrail para auditoría de actividades 
- Configurar políticas de retención de logs según requisitos regulatorios
- Implementar controles preventivos con Service Control Policies (SCPs)
## 17. Lista de Verificación para Despliegues
- [ ] Nomenclatura de recursos conforme al estándar
- [ ] Etiquetas obligatorias aplicadas a todos los recursos
- [ ] Cifrado en tránsito y en reposo implementado
- [ ] Logs habilitados con retención configurada
- [ ] Alertas de monitoreo configuradas
- [ ] Acceso de red restringido según principio de mínimo privilegio
- [ ] Documentación actualizada
- [ ] Pruebas de validación completadas
- [ ] Estrategia de backup configurada
- [ ] Revisión de seguridad completada

## 18. Mensaje de Cierre Estándar
- Al finalizar la generación de cualquier módulo de infraestructura como código, se debe incluir el siguiente mensaje estándar:
  
  > "Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción."

- Este mensaje debe aparecer después de la lista de verificación de cumplimiento y antes de cualquier recomendación adicional o sugerencia de mejora.
- El mensaje no debe ser modificado sin autorización explícita.

## 19. Configuración de Proveedores con Alias

### 19.1 Definición de Proveedores con Alias
- Los módulos que requieran configuraciones específicas de proveedores deben utilizar alias:
  ```hcl
  # En el módulo
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">=4.31.0"
        configuration_aliases = [aws.project]
      }
    }
  }
  
  # Uso del proveedor con alias en recursos
  resource "aws_sqs_queue" "sqs" {
    provider = aws.project
    # Resto de la configuración...
  }
  ```

### 19.2 Mapeo de Proveedores al Llamar al Módulo
- Al llamar a un módulo que requiere un proveedor con alias, se debe mapear explícitamente:
  ```hcl
  module "sqs_queues" {
    source = "/ruta/al/modulo/sqs"
    providers = {
      aws.project = aws.principal  # Mapeo del proveedor con alias
    }
    
    # Resto de la configuración...
  }
  ```

### 19.3 Configuración del Proveedor Principal
- El proveedor principal debe configurarse con todas las etiquetas comunes:
  ```hcl
  provider "aws" {
    alias   = "principal"
    region  = var.aws_region
    profile = var.profile
    
    default_tags {
      tags = var.common_tags
    }
  }
  ```

## 20. Configuración del Backend

### 20.1 Recomendaciones para Backend Remoto
- Para entornos de producción y colaboración en equipo, se recomienda configurar un backend remoto para almacenar el estado de Terraform (tfstate). Esto proporciona:
  - Bloqueo de estado para prevenir operaciones concurrentes
  - Respaldo y versionado del estado
  - Almacenamiento seguro de información sensible
  - Colaboración en equipo

### 20.2 Configuración con S3 y DynamoDB
```hcl
terraform {
  backend "s3" {
    bucket         = "pragma-terraform-states"
    key            = "sqs/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### 20.3 Requisitos de Seguridad
- El bucket S3 debe tener el versionado habilitado
- La tabla DynamoDB debe tener una clave primaria llamada `LockID`
- El bucket S3 debe tener cifrado en reposo habilitado
- Configurar políticas de acceso restrictivas para el bucket y la tabla
