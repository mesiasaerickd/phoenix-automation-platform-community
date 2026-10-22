# Instalación online pública de PAP (RC1)

La distribución de PAP utiliza Kubernetes/K3s y seis imágenes OCI **públicas** alojadas en `ghcr.io/phoenix-automation-platform/`. Sus referencias verificadas por digest se encuentran en [`releases/ghcr-digests-v0.1.0-rc1.txt`](../releases/ghcr-digests-v0.1.0-rc1.txt).

**No se requiere PAT, inicio de sesión en GHCR ni registro privado** para el flujo estándar de instalación RC1. Las configuraciones privadas mencionadas en notas de desarrollo previas son históricas y no se deben aplicar a usuarios nuevos.

## Inicio rápido

1. Clonar `prd`: `git clone --branch prd --single-branch https://github.com/phoenix-automation-platform/phoenix-automation-platform-community.git`.
2. Leer [requisitos](REQUIREMENTS.md), [red](NETWORKING.md) y la [guía de instalación](../INSTALLATION.md).
3. Ejecutar `bash scripts/preflight.sh <namespace> pre` desde un clúster preparado; revisar advertencias y bloqueos.
4. Con la red y los requisitos autorizados, ejecutar `PAP_NETWORK_APPROVED=yes bash scripts/install-online.sh <namespace>`.
5. Comprobar `bash scripts/preflight.sh <namespace> post`, estado de pods, interfaz, API y un Job Ansible real.

El instalador **no configura automáticamente** firewall, CNI, TLS ni SELinux. No instalar sobre recursos AWX existentes sin evaluar compatibilidad, respaldo y autorización.

Para preguntas consulta [FAQ](FAQ.md), [Soporte](../SUPPORT.md) y [GitHub Discussions](https://github.com/phoenix-automation-platform/phoenix-automation-platform-community/discussions).
