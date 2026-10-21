# PAP Phoenix — Dimensionamiento y prerrequisitos (RC2)

> Estado: línea base propuesta, pendiente de pruebas de carga. Los valores no certifican 100 Jobs simultáneos. Aplica a la instalación Kubernetes/K3s con un Web, un Task, un PostgreSQL y un Control Plane EE por defecto.

## Capacidad del servidor / nodo

| Perfil | vCPU | RAM | Disco aprovisionado | Alcance |
| --- | ---: | ---: | ---: | --- |
| Laboratorio mínimo | 4 | 8 GiB | 60 GiB | Pruebas secuenciales, capacidad limitada |
| Laboratorio recomendado | 6 | 12 GiB | 80 GiB | Pruebas de concurrencia moderada |
| Producción inicial | 8 | 16 GiB | 100 GiB | Punto de partida; medir antes de habilitar cargas |
| Producción de alta concurrencia | Por pruebas de carga | Por pruebas de carga | Según datos/retención | Varios nodos y capacidad EE se dimensionan aparte |

Considerar CPU/RAM **allocatable** de Kubernetes (después de reservas del SO/K3s), no solo la memoria total del equipo. Estos perfiles son orientativos: otros servicios en el nodo reducen la capacidad disponible. Para el objetivo de cientos de servidores y hasta 100 Jobs concurrentes, validar número de Pods, ejecución real de EEs, conexiones, tiempos, servicios de base de datos y políticas de distribución entre nodos; el perfil inicial no garantiza tal capacidad.

**Prerrequisitos:** Linux compatible y mantenido, K3s/Kubernetes validado, arquitectura x86_64, SELinux y firewall habilitados con reglas CNI justificadas, DNS/resolución del clúster y acceso permitido a los registros de imágenes del modo online. Verificar capacidad de CPU/RAM, espacio y PVC antes de instalar; separar almacenamiento y respaldos de PostgreSQL. No exponer PAP públicamente sin controles adicionales. La versión exacta del SO/cluster debe validarse contra la matriz de pruebas de la distribución.

## Recursos Kubernetes de base (manifiesto `k8s/awx.yaml`)

| Componente | CPU request / limit | Memoria request / limit |
| --- | --- | --- |
| Task | 200m / 550m | 1024Mi / 2Gi |
| Control Plane EE / Receptor | 250m / 1000m | 256Mi / 1Gi |
| Web | 100m / 450m | 768Mi / 1536Mi |
| PostgreSQL | 100m / 400m | 256Mi / 512Mi |
| Redis | 25m / 100m | 32Mi / 128Mi |
| Rsyslog | 100m / 300m | 192Mi / 512Mi |
| Init container (solo durante arranque) | 100m / 300m | 192Mi / 384Mi |

Estos son los valores del CR actual, **no recomendaciones definitivas** para cada servicio. PostgreSQL y Task requerirán mediciones de carga y podrían necesitar incrementos. Los límites se aplican **por contenedor**; no representan el tamaño del servidor.

## ResourceQuota del namespace (`k8s/resource-policies.yaml`)

- `limits.cpu: 8`, `limits.memory: 12Gi`
- `requests.cpu: 5`, `requests.memory: 8Gi`
- `pods: 20`; PVC: 3; requests.storage: 10Gi

La cuota es el **máximo acumulado admitido en el namespace**, no es una asignación de recursos físicos ni un objetivo obligatorio de uso. Kubernetes admite sobreaprovisionar límites, pero solo planificar Jobs cuando la capacidad real, las solicitudes y el espacio lo permitan. Se elevó CPU tras observar que con `limits.cpu=4` y `used=3700m` no podía crearse un nuevo Pod EE que solicitaba `500m`; el Job quedaba esperando y volvía a preparar el proyecto.

**Ojo:** el instalador utiliza `LimitRange` con CPU limit por defecto de 500m y memoria limit de 1Gi para contenedores sin recursos declarados. Esto puede afectar Jobs EE; un perfil real de Job debe medirse por plantilla. Para despliegues con más de un Task/Web o varios Jobs concurrentes, cuotas y recursos totales deben recalcularse antes de escalar.

## Capacidad para actualizaciones y rollouts

El Deployment puede necesitar temporalmente **dos Pods** durante RollingUpdate, por lo que debe reservarse margen adicional. Si el nodo o las cuotas no permiten la segunda réplica, considerar estrategia de despliegue y ventana de mantenimiento; nunca cambiarla de forma permanente sin validar disponibilidad. El aumento de cuota no resuelve por sí solo la falta de RAM/CPU del nodo.

## Checklist de aceptación

1. `kubectl get nodes -o wide` y `kubectl describe node` (Allocatable y Allocated resources).
2. `kubectl describe resourcequota -n <namespace>` y `kubectl get limitrange -n <namespace>`.
3. `kubectl top nodes` y `kubectl top pods --containers -n <namespace>` durante sincronización y ejecución de Jobs.
4. Validar dos sincronizaciones SCM simultáneas y Jobs con EE, sin Pod Forbidden/ExceededQuota ni OOMKilled.
5. Verificar Receptor, Task, PostgreSQL, ejecución de playbooks y persistencia tras recrear Pods.
6. Pruebas de carga antes de declarar el perfil de producción apto para el nivel de concurrencia objetivo.

**Política de cambios:** primero en `dev`; promover a `prd` solo tras pruebas y aprobación. No almacenar identificadores de hosts/IP del laboratorio en los manifiestos.
