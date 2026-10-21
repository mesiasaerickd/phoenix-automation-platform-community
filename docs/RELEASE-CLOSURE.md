# Matriz de cierre y publicación — PAP

Actualizado: 2026-10-20. Este documento distingue **documentación terminada** de **release homologado**.

## Etapas
1. `contrib`: entrada de aportes, política comunitaria y documentación; revisión de mantenedor.
2. `dev`: integración técnica, compilación, análisis de seguridad y pruebas.
3. `prd`: promoción aprobada y versionada; no editar directamente.
4. Release: publicar desde un commit aprobado con checksum, digests, procedencia, notas y artefactos verificados. `main` no participa.

## Matriz de aceptación
| Control | Evidencia requerida | Estado al 20/10/2026 |
| --- | --- | --- |
| README y flujo de contribuciones | Documentos coherentes en español/inglés | Integrado en `contrib` mediante PR #18 |
| Licencia y atribución | LICENSE, NOTICE, inventario de terceros y SBOM | LICENSE y NOTICE presentes; auditoría de terceros pendiente |
| Instalador online desde cero | Comandos reproducibles en entorno limpio, registro de versión, resultado | Pendiente de evidencia externa |
| Web y API | Disponibilidad HTTPS y respuesta de API sobre instalación candidata | RC2: prueba de laboratorio comunicada; no prueba RC1 externa |
| Operator, PostgreSQL y migración | CR reconciliado, pods, migraciones, persistencia | RC2: evidencia de laboratorio comunicada; revalidar release |
| Redis — verificación propia | Versión, hashes de ambos ejecutables, licencia identificada, digest y pruebas básicas reportadas | **CERRADO** (identidad y licencia seleccionada); ver [REDIS-CLOSURE.md](REDIS-CLOSURE.md) |
| Execution Environments | UID, Receptor, job/events, stdout y permisos | RC2: resultados parciales previos; revalidar sobre candidato público |
| Seguridad | SBOM, escaneo por digest, análisis de hallazgos, secretos y network access | Pendiente de evidencia versionada |
| Operación | Backup/restore, actualización, rollback, recursos y recuperación | Pendiente de pruebas documentadas |
| Licencias y avisos de la distribución completa | Inventario de todos los componentes y obligaciones de redistribución, incluidos paquetes de terceros | Control transversal de release; revisión final pendiente |

## Publicación responsable
No describir el producto como *Production Ready*, ni un escaneo como libre de vulnerabilidades, sin pruebas de la imagen exacta y del sistema desplegado. Los resultados de laboratorio RC2 no equivalen a homologación de la etiqueta pública `v0.1.0-rc1`.

La documentación de esta rama puede cerrarse en revisión. **La aceptación técnica y el release general quedan condicionados a las evidencias de la matriz.**

## Registro de evidencias para cada control
Fecha UTC, ambiente, commit, versión, digest OCI, comandos de validación, resultado esperado/real, logs depurados, riesgos y responsable. Nunca registrar claves ni direcciones internas sensibles.
