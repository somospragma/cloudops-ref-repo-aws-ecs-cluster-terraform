# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-04-15

### Añadido
- Soporte para etiquetas adicionales en los clusters ECS
- Validaciones para nombres de entorno, cliente, proyecto y aplicación
- Documentación mejorada con ejemplos de uso

### Cambiado
- Convertida la variable `cluster_config` de lista a mapa para mayor flexibilidad y reutilización
- Simplificada la generación de nombres de clusters
- Mejorada la estructura del código para mayor legibilidad
- Actualizado el ejemplo de uso en el directorio sample

### Eliminado
- Eliminada la variable `application` del ejemplo, ahora se usa directamente el nombre en el mapa
- Eliminada la configuración de logs, que se manejará en el módulo de service y task

### Corregido
- Mejorada la validación de parámetros de configuración
