# Control Plane EE UID 1001 (candidato, no desplegado)

SVLNX02 verificó `uid=1001 gid=0` y `getent passwd 1001` devolvió código 2 en `pap-ee-control`, con fallo `No user exists for uid 1001` al usarlo en un Job.

Este Dockerfile deriva de la imagen exacta actual (digest SHA256 fijo), agrega una entrada NSS de usuario y conserva `USER 1001:0`. **No reutilizar el nombre `pap-ee-core`** ni actualizar el CR automáticamente.

Acción manual: workflow **PAP Control Plane UID 1001** de GitHub Actions sobre `dev`. Valida `getent` y el UID/GID dentro de un contenedor y publica un tag candidato. La publicación por sí sola no sustituye el digest en `releases/ghcr-digests-dev.txt`; esa promoción requiere prueba de SSH/Job, arranque de Receptor, seguridad y aceptación en una nueva VM.

El Dockerfile original de `pap-ee-control` debe recibir posteriormente el fix antes de preparar una release definitiva.

## Incidencia SCM pendiente
En SVLNX02, `Project.scm_update_on_launch=False` y `scm_update_cache_timeout=0`, pero Jobs 6/8/11/14/15 tienen ProjectUpdate con `launch_type=sync`. No concluye que el backend ignore la opción: examinar dependencias y `sync` en un despliegue limpio. No modificar el scheduler/dispatcher sin reproducir.
