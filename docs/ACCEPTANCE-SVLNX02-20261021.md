# PAP — aceptación de instalación limpia en SVLNX02 (2026-10-21)

## Alcance y evidencia

- Entorno: SVLNX02, RHEL 9.8, K3s v1.36.5+k3s1, SELinux Enforcing, firewalld activo, namespace `pap-acceptance`.
- Instalación: `scripts/install-online.sh pap-acceptance`, usando una modificación **local** del inventario `releases/ghcr-digests-dev.txt` para seleccionar `ghcr.io/phoenix-automation-platform/pap-web-task:recovery-20261021`.
- Imagen Web/Task publicada: digest de manifiesto `sha256:be9eef40e6fa6462d109a04a8163724bff80478477764c3152b0be11eb76d40e`; configuración OCI `sha256:59a0174ceb1b96ccf78c10c5950e2e4ceb847fe974e7adf8b69dd4b9e4238c37`.
- Resultado Kubernetes: Operator 1/1, PostgreSQL 1/1, Web 3/3, Task 4/4; migración AWX 24.6.1 `Complete` en 3m55s; reinicios 0 en la muestra.
- Evidencia funcional aportada por el tester: pantalla de login personalizada PAP Phoenix; logotipo fénix; selector English/Español; modal «Acerca de» con PAP 1.0.1-RC1; ejecuciones de playbooks exitosas (incluida respuesta Ansible `ping: pong`), proyectos y trabajos `Correcto`. Se reportaron fallos anteriores por falta de contraseña de sudo en pruebas, no por la imagen.

## Estado de publicación

La aceptación funcional de laboratorio **no** implica aceptación final de seguridad, licencias ni endurecimiento de red. Se utilizó una excepción **runtime** `cni0` en zona `trusted` para restablecer Metrics Server al acceder al kubelet TCP/10250; requiere revisión de mínimo privilegio antes de producción y no debe persistirse automáticamente.

Las otras cinco imágenes del inventario usan `dev-20261020` y deben auditarse independientemente. No eliminar etiquetas antiguas hasta comprobar consumidores y reversión.

## Pendientes para instalador de usuario final

1. Promover a `prd` la referencia de imagen validada mediante PR aprobado.
2. Publicar imagen equivalente con nomenclatura definitiva (`dev-YYYYMMDD` o release semántico), **verificando digest/contenido** antes de sustituir la referencia temporal.
3. Mejorar el instalador y la guía para aprovisionar/verificar dependencias y explicar aprobaciones de red sin automatizar aperturas excesivas de firewall.
4. Verificar desde un clon nuevo de `prd` sin ninguna edición manual, y ejecutar prueba real de Job Template.
5. Resolver controles pendientes de auditoría de vulnerabilidades, SBOM, atribuciones y licencias antes de declararlo liberación productiva.

No se modificó el clúster productivo SVLNX01 durante esta prueba.
