# Phoenix Automation Platform v0.1.0 RC1

## Estado

Primera versión candidata pública de Phoenix Automation Platform.

Código fuente:
https://github.com/phoenix-automation-platform/phoenix-automation-platform-community

Release:
https://github.com/phoenix-automation-platform/phoenix-automation-platform-community/releases/tag/v0.1.0-rc1

## Componentes

- PAP Web/Task, basado en AWX
- PAP Operator
- PostgreSQL 15.19
- Redis 8.10.2
- PAP EE Control
- PAP EE Core

## Imágenes públicas

Registro: `ghcr.io/phoenix-automation-platform/`

Los seis manifiestos OCI fueron comprobados sin autenticación.

Las referencias inmutables se encuentran en:

`releases/ghcr-digests-v0.1.0-rc1.txt`

El instalador RC1 utiliza actualmente la etiqueta
`dev-20261020`. El manifiesto de digests es un registro
de integridad; todavía no sustituye automáticamente
las referencias utilizadas por el instalador.

## Preparar una instalación nueva

1. Disponer de un clúster Kubernetes/K3s compatible.
2. Revisar `docs/REQUIREMENTS.md` y `docs/NETWORKING.md`.
3. Revisar las políticas de seguridad y almacenamiento.
4. Utilizar el código correspondiente al Release RC1.
5. Ejecutar el preflight y revisar sus resultados.
6. Autorizar los requisitos de red aplicables al entorno.
7. Ejecutar el instalador online únicamente en un
   clúster preparado para una instalación nueva.
8. Verificar migraciones, servicios, API y Jobs Ansible.

El instalador puede modificar recursos Kubernetes.
No debe ejecutarse como prueba sobre un clúster productivo.

## Seguridad

Esta versión es una candidata pública.
Los resultados de seguridad y las vulnerabilidades
conocidas deben revisarse antes del uso productivo.

No se afirma ausencia total de vulnerabilidades.

## Validaciones realizadas

- Publicación de seis imágenes GHCR: PASS
- Acceso anónimo a seis manifiestos: PASS
- Renderizado de manifiestos: PASS
- GitHub Actions del instalador: PASS

La instalación externa completa desde el Release
no queda certificada por estas pruebas.
