# Scripts de PAP

Instalación **online** exclusivamente: `install-online.sh` llama a `install-common.sh`, que verifica el clúster, genera manifiestos, configura referencias GHCR y despliega componentes de PAP. `preflight.sh` informa requisitos y hallazgos sin modificar firewall, SELinux ni infraestructura del host. `configure-installation.py`, `configure-images.py` y `check-online.py` preparan y comprueban el render. `configure-ghcr.sh` facilita el acceso autorizado a imágenes privadas. Las credenciales y los artefactos grandes no se almacenan en Git.
