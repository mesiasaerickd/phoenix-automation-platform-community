# Redis 8.10.2 — cierre definitivo de validación técnica PAP

**Estado: CERRADO.** Fecha: 21 de octubre de 2026.

## Pruebas y evidencia

| Verificación | Resultado |
| --- | --- |
| Versión redis | **PASS — 8.10.2** |
| SHA256 de `redis-server` | **PASS** — `df1291685ab15c4708c5556298146a93f498387aa6265aa0988da88d9952e41d` |
| SHA256 de `redis-cli` | **PASS** — `b3b11461c9b2e376bea58d43afdefa46d1336c3b2a0cd6738feb1fbe735add19` |
| Identidad de binarios | **PASS (2/2)** — coincidencia con `docker.io/library/redis:8.10.2-alpine` |
| Licencia Redis | **IDENTIFICADA** — opción AGPLv3 seleccionada para el componente; fuente y materiales asociados registrados en RC1 |
| Digest histórico público RC1 | `ghcr.io/phoenix-automation-platform/pap-redis@sha256:000ff14e526f1d693d7206f6df83dfd5beebbef1ee5e31bc723ea0fe3d9b6e5c` |
| Conectividad `PONG` | **PASS**, reportado en las pruebas realizadas |
| Escaneo Trivy | **PASS**, sin hallazgos en el análisis previamente reportado |
| Pruebas finales de instalación y funcionamiento de PAP | **PASS**, confirmadas por el responsable de la instalación |

## Conclusión

**Redis queda cerrado técnicamente como componente de Phoenix Automation Platform.** Su identidad, versión, modalidad de licencia y funcionamiento fueron comprobados y aceptados. No se registran incidencias técnicas abiertas para Redis en la aceptación del laboratorio. No corresponde repetir pruebas ya cerradas.

El análisis técnico histórico reside en `fix/redis-source-and-notices/components/pap-redis/README.md` y `audit/rc1-redis-provenance/docs/RC1-REDISTRIBUTION-AUDIT.md`. El hecho de disponer de una opción de licencia no debe confundirse con un dictamen legal sobre todos los componentes de terceros; esa aclaración de alcance no representa una incidencia pendiente de Redis.

Redis se mantiene como servicio interno de Kubernetes, sin exposición pública directa. Este registro no altera la imagen, sus digests ni el clúster.
