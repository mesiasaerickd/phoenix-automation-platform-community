> **INSTALACIÓN PÚBLICA RC1:** clona la rama `prd` o utiliza la versión publicada `v0.1.0-rc1`. Las **seis imágenes OCI de Phoenix son públicas** en `ghcr.io/phoenix-automation-platform/` y se verificó acceso sin autenticación. La instalación estándar **no necesita PAT, secretos de GHCR ni imágenes privadas**. Consulta [README](README.md), [FAQ](docs/FAQ.md) y [digests RC1](releases/ghcr-digests-v0.1.0-rc1.txt). Los siguientes apartados conservan observaciones técnicas históricas del desarrollo; no son pasos obligatorios para nuevos usuarios.

# PAP online — instalación pública RC1 y notas históricas de desarrollo

> **Alcance:** instalación online. Las imágenes RC1 están publicadas; el flujo actual no exige registro privado. Los apartados técnicos heredados de `dev` se conservan únicamente como historial, no como instrucciones vigentes para nuevas instalaciones.

## Renderizado y preflight de seguridad

```bash
python3 scripts/configure-installation.py pap-acceptance POD_CIDR /ruta/render
python3 scripts/configure-images.py online /ruta/render
python3 scripts/check-online.py /ruta/render
```

El POD_CIDR debe obtenerse del clúster real, no copiar el valor `CIDR de pods detectado` de NODO de prueba. El preflight verifica la separación de las credenciales de imágenes Kubernetes frente a credenciales AWX EE, así como el arranque del operador y su namespace. Informa el estado de firewalld si está disponible, pero **no abre puertos ni cambia reglas**.

Si firewalld está activo, deben probarse rutas y NetworkPolicies; las políticas de forwarding deben ser limitadas, aprobadas y reversibles. Si está inactivo o no instalado, el instalador no debe activarlo ni instalarlo. Mantener SELinux Enforcing.

**Nota histórica:** algunos entornos anteriores utilizaban credenciales de registro. Ese procedimiento no aplica a las seis imágenes públicas de RC1 y no debe configurarse en instalaciones estándar.

## Corrección Control Plane UID 1001

La imagen `pap-ee-control` previamente desplegada en NODO de prueba ejecutaba `uid=1001`, pero `getent passwd 1001` devolvía RC=2. El candidato en `images/control-plane-uid-fix/` añade una entrada NSS para UID 1001 y se prueba en GitHub Actions. **El digest corregido todavía no se ha promovido a los manifiestos del instalador**.

El historial de integración de Control Plane incluye incidencias anteriores de permisos GHCR; estas no representan un prerrequisito de autenticación para la distribución pública RC1.

## Criterios de aceptación online

1. El render y `check-online.py` terminan en PASS sin exponer credenciales.
2. PostgreSQL accesible desde Web/Task y NetworkPolicies activas; firewalld y SELinux mantienen sus estados esperados.
3. Migración AWX completa (en NODO de prueba tardó unos diez minutos; evitar timeout fijo de cinco minutos).
4. API /api/v2/ping/ y UI responden HTTP 200, login probado.
5. Operador AWX `Successful=True`, `Failure=False`, sin reconciliación fallida.
6. EE Control Plane y PAP EE Core registrados y con resolución UID 1001 donde corresponda.
7. Job Ansible SSH real ejecutado con PAP EE Core.
8. Repetir desde cero en una VM nueva y observar si el proyecto realiza sincronizaciones SCM con `scm_update_on_launch=False`. Mantener esta incidencia como pendiente de reproducción; no parchear el scheduler sin evidencia.

## Estado confirmado

NODO de prueba reportó `Successful=True`, `Failure=False`, dos EE registrados y Jobs correctos con PAP EE Core. La imagen Control Plane anterior presentaba problema NSS con UID 1001. La candidata corregida superó las pruebas aisladas de UID, Receptor y Ansible Runner; el Job Template JOB02 terminó Successful (ok=4, unreachable=0, failed=0). Pendiente integración del digest en los manifiestos y prueba de instalación limpia. El workflow del instalador es una prueba de manifiestos, **no equivale** a prueba end-to-end de instalación online.


## Matriz de red y validación de aceptación

Ver [docs/NETWORKING.md](docs/NETWORKING.md). El administrador autoriza reglas de firewall del host y conectividad entre nodos. El instalador debe ejecutar preflight y pruebas posteriores de conectividad Task -> Web (TCP/8052 directo entre pods y vía Service), Web/Task -> PostgreSQL (TCP/5432), DNS y Receptor/wsrelay, sin cambios silenciosos en firewalld o SELinux.

En NODO de prueba (18-oct-2026), el Service Web respondía pero el enlace directo Task -> Web devolvía `No route to host` hasta permitir tráfico con firewalld. Una regla amplia de pods `CIDR de pods detectado` está vigente **solo en ese laboratorio**, pendiente de endurecimiento. No se debe reproducir como configuración genérica ni dar la instalación por aprobada sin Job Template real y prueba de instalación limpia.


## Preflight automatizado (dev)

Antes de instalar online, ejecutar `bash scripts/preflight.sh <namespace> pre`: solo lectura, genera evidencia bajo `/tmp/pap-preflight/` con permisos de propietario. El instalador detiene el despliegue ante `PAP_PREFLIGHT=BLOCKED`; `REVIEW_REQUIRED` necesita revisión del administrador antes de instalar.

Tras desplegar, ejecutar `bash scripts/preflight.sh <namespace> post`: comprueba Task → Web por IP del pod TCP/8052 y Service TCP/80; ejecutar después un Job Template real. El preflight no modifica reglas del host. La verificación automatizada de todos los flujos DNS/DB y el ensayo integral de instalación siguen pendientes.


### Aprobación de revisión de red

El preflight de instalación devuelve código 3 cuando detecta condiciones que requieren revisión administrativa (por ejemplo firewalld activo). El instalador no prosigue hasta que el administrador valide la conectividad y autorice explícitamente ejecutar con `PAP_NETWORK_APPROVED=yes bash scripts/install-online.sh <namespace>`. Esta variable solamente reconoce la revisión: **no crea ni autoriza reglas de firewall por sí misma**. Ante `PAP_PREFLIGHT=BLOCKED` el instalador se detiene incluso con dicha variable.
