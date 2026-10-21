# Instalación online PAP

La distribución online utiliza manifiestos Kubernetes/K3s y las seis imágenes OCI referenciadas por digest en `releases/ghcr-digests-dev.txt`.

Consulta `INSTALLATION.md` para el procedimiento, `docs/REQUIREMENTS.md` para los prerrequisitos y `scripts/preflight.sh` para la validación pre/post. Las configuraciones del clúster, red y seguridad del host corresponden a la administración de infraestructura.

La aceptación RC2 comprobó instalación en VM limpia, migración de base de datos, API y dos Jobs con entornos de ejecución personalizados.
