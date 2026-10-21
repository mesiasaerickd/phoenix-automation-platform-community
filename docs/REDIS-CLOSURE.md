# Redis — cierre de validación técnica PAP

**Estado: CERRADO en identidad binaria, selección de licencia y comprobaciones básicas reportadas.** Revisión: 20 de octubre de 2026.

## Resultado consolidado

| Control | Resultado | Evidencia / alcance |
| --- | --- | --- |
| Versión Redis | 8.10.2 | Inspección de imagen publicada, documentada en `fix/redis-source-and-notices` |
| `redis-server` | PASS | SHA256 `df1291685ab15c4708c5556298146a93f498387aa6265aa0988da88d9952e41d`, idéntico al binario oficial `redis:8.10.2-alpine` |
| `redis-cli` | PASS | SHA256 `b3b11461c9b2e376bea58d43afdefa46d1336c3b2a0cd6738feb1fbe735add19`, idéntico al binario oficial `redis:8.10.2-alpine` |
| Licencia Redis | Identificada | Redis 8.10.2 admite la opción AGPLv3 elegida para este componente; fuentes y materiales legales de Redis constan entre los adjuntos de RC1 según el inventario de auditoría |
| Imagen pública RC1 | Registrada | `ghcr.io/phoenix-automation-platform/pap-redis@sha256:000ff14e526f1d693d7206f6df83dfd5beebbef1ee5e31bc723ea0fe3d9b6e5c` |
| Conectividad | Reportada satisfactoria | `PONG` en pruebas previas; sin nueva ejecución en esta revisión documental |
| Escaneo de seguridad | Reportado sin hallazgos | Resultado Trivy previo; no equivale a garantía de ausencia de vulnerabilidades futuras |

**Conclusión técnica:** no hay motivo identificado para repetir las verificaciones de versión, identidad de ejecutables o selección de licencia de Redis. Este componente deja de figurar como incidencia técnica abierta por esos conceptos.

## Límites expresos del cierre

Esta decisión **no** constituye una certificación jurídica de toda la imagen ni una homologación de producción del producto completo. Los detalles de redistribución de paquetes Alpine, texto de avisos que deba acompañar el binario, procedencia de todos los pasos de build y reproducibilidad general se gestionan **una sola vez** en el control transversal de licencias y publicación de PAP: [matriz de release](RELEASE-CLOSURE.md) y [NOTICE](../NOTICE.md). No reabrir Redis como defecto técnico por ese trabajo transversal.

La rama `fix/redis-source-and-notices` describe expresamente su `Containerfile.candidate` como reconstrucción y no como receta original verificada; se conserva esa limitación sin invalidar la identidad de los dos binarios.

## Operación segura

Redis debe permanecer accesible solo por los componentes autorizados del clúster; no exponerlo directamente a Internet. Las políticas de red, configuración y recuperación deben seguir las decisiones generales de instalación Kubernetes. El flujo integral Web → Task → Receptor → EE pertenece a la validación de la plataforma/release, no a una nueva auditoría de identidad de Redis.

## Fuentes internas de evidencia

- Rama `fix/redis-source-and-notices`, archivo `components/pap-redis/README.md`.
- Rama `audit/rc1-redis-provenance`, archivo `docs/RC1-REDISTRIBUTION-AUDIT.md`.
- Rama `prd`, archivo `releases/ghcr-digests-v0.1.0-rc1.txt`.

No modificar la imagen RC1, sus digests o el clúster en ejecución como consecuencia de este cierre documental.
