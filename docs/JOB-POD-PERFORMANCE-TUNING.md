# Optimización opcional de recursos para Jobs (laboratorio)

Esta guía es **opcional**. No modifica el instalador, las imágenes ni los valores por defecto de Phoenix. Requiere permisos de administración y revisión de capacidad del clúster.

## Cuándo considerar esta optimización

Si un Job permanece mucho tiempo en `Pending`, tarda en arrancar o se ejecuta lentamente, revisar primero eventos del Job, disponibilidad de recursos, estados de los pods y cuotas de Kubernetes. **No asumir que aumentar CPU/RAM resolverá todo retraso.**

## Desde la consola Phoenix

1. Ingresar con una cuenta administradora.
2. Abrir **Infraestructura → Grupos de instancias → default → Editar**.
3. Ubicar **Customize Pod Spec / Personalizar especificación de Pod**.
4. **Conservar el YAML existente** (namespace, imagen, nombre del contenedor, service account, seguridad, affinity, etc.). Cambiar exclusivamente la sección `resources` del contenedor `worker` para un perfil de ejemplo:

```yaml
resources:
  requests:
    cpu: 1000m
    memory: 1Gi
  limits:
    cpu: 3000m
    memory: 3Gi
```

5. Guardar y lanzar un Job de prueba. Revisar su estado, duración y el Pod creado. Si aumenta la espera en `Pending`, volver a los valores anteriores y revisar `ResourceQuota` y capacidad de nodos.

**Advertencias:** `requests` reserva capacidad al programar; `limits` restringe consumo. Las cuotas `requests.cpu`, `requests.memory`, `limits.cpu` y `limits.memory` pueden impedir arrancar varios Jobs concurrentes. Un límite de CPU puede provocar throttling; la memoria puede disparar OOMKilled al excederse. Revisar siempre el total del clúster y otros servicios. No es una recomendación universal para producción.

## Diagnóstico (solo lectura)

```bash
k3s kubectl get pods -n pap-acceptance -o wide
k3s kubectl get resourcequota,limitrange -n pap-acceptance
k3s kubectl get events -n pap-acceptance --sort-by=.lastTimestamp | tail -40
k3s kubectl top pods -n pap-acceptance
```

El nombre `pap-acceptance` es un **ejemplo**; usar el namespace real de la instalación. No almacenar credenciales ni datos de trabajos en incidencias públicas.

## Referencias

- AWX 24.6.1: https://docs.ansible.com/projects/awx/en/24.6.1/administration/containers_instance_groups.html
- Configuración de sesión: https://docs.ansible.com/projects/awx/en/24.6.1/administration/authentication_timeout.html
