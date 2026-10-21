# Redis — cierre técnico y criterios de aceptación (PAP)

Estado: **identidad de Redis 8.10.2 verificada en ambos binarios (2/2); conformidad global de imagen y release pendientes**. Fecha de revisión: 2026-10-20.

## Alcance
Redis es un servicio auxiliar utilizado por los componentes de ejecución de PAP/AWX. Su disponibilidad no sustituye la de PostgreSQL, Receptor ni los Execution Environments. La relación exacta Redis/Task y sus opciones de persistencia deben verificarse contra los manifiestos y la configuración de la versión desplegada. No activar persistencia, exposición de puertos ni cambios de seguridad sin comprobar su necesidad y su compatibilidad.

## Control de versión y procedencia
Para cada publicación registrar: repositorio y commit de fuente, Containerfile/Dockerfile, base OCI fijada por digest, versión efectiva de Redis, digest de imagen resultante, SBOM, licencias/NOTICE de dependencias y resultado del análisis de vulnerabilidades. No considerar una etiqueta mutable —como `dev-20261020`— prueba suficiente de identidad o procedencia. La revisión de redistribución se aplica también a las imágenes base y artefactos incluidos.

## Comprobaciones mínimas
Estas consultas son de solo lectura; sustituir `<namespace>`, `<pod-redis>` y `<pod-task>` por nombres observados en el clúster.

```sh
kubectl -n <namespace> get pods,svc,pvc
kubectl -n <namespace> describe pod <pod-redis>
kubectl -n <namespace> logs <pod-redis> --tail=100
kubectl -n <namespace> logs <pod-task> --tail=100
```

Verificar mediante el cliente configurado que Redis responde `PONG` **sin publicar credenciales**. Comprobar también conectividad desde Task, ausencia de errores de autenticación/red, reinicios y límites de recursos. Un `PONG` aislado solo confirma conectividad básica: **no acredita** que la cola, el despacho ni los Jobs funcionen.

## Criterio de cierre funcional
- Imagen inmutable referenciada por digest, procedencia, licencia y SBOM archivados.
- Trivy u otro escáner ejecutado contra el digest publicado, con fecha y políticas de severidad documentadas; hallazgos evaluados, no simplemente ignorados.
- Servicios y pods sanos; conectividad Redis ↔ Task probada sin exponer Redis fuera de los límites aprobados.
- Job real: solicitud mediante Web/API, despacho por Task, ejecución mediante Receptor/EE y resultado visible en UI/API con eventos completos.
- Prueba de recuperación/rollback acorde con el modo de despliegue; sin impacto a entornos ajenos.
- Evidencias reproducibles adjuntas a release o PR: versiones, hashes, logs depurados, identificación del Job, salida, fecha, responsable y estado.

## Estado conocido vs pendiente
**Evidencia histórica conservada en la rama `fix/redis-source-and-notices`:** Redis 8.10.2 comparado contra `docker.io/library/redis:8.10.2-alpine`:
- `redis-server`: SHA256 `df1291685ab15c4708c5556298146a93f498387aa6265aa0988da88d9952e41d` — PASS.
- `redis-cli`: SHA256 `b3b11461c9b2e376bea58d43afdefa46d1336c3b2a0cd6738feb1fbe735add19` — PASS.
- Digest público RC1 registrado en `prd`: `sha256:000ff14e526f1d693d7206f6df83dfd5beebbef1ee5e31bc723ea0fe3d9b6e5c`.
- Fuentes y materiales de Redis y GPL/LGPL Alpine figuran en activos RC1 según el registro de auditoría. El Containerfile disponible es una **reconstrucción**, no la receta original probada.
- `PONG` y Trivy sin hallazgos: resultados previos comunicados sin informes completos adjuntos a este cambio.

**Cierre parcial:** identidad binaria PASS. La revisión de avisos y licencias de todos los paquetes, entradas de compilación, reconstrucción y aceptación integral del release no está completada.

## Seguridad
No exponer Redis públicamente. Aplicar segmentación/red de Kubernetes según arquitectura, acceso mínimo, secretos administrados por el entorno y seguimiento de parches. No incorporar contraseñas ni tokens en repositorios, capturas o logs. Los parámetros de persistencia, autenticación y TLS dependen de la configuración real y deben decidirse tras inspeccionarla.
