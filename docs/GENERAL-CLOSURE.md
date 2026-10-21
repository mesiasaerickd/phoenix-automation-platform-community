# Acta de cierre general — Phoenix Automation Platform (PAP)

**Corte de información:** 20 de octubre de 2026 (hora de Perú).  
**Estado:** cierre documental realizado; cierre de compilación del siguiente candidato **sujeto a confirmación**; homologación de instalación externa **no declarada**.

## 1. Alcance del cierre
Esta acta consolida el trabajo técnico y documental existente, evitando abrir nuevamente controles ya verificados. Abarca la distribución comunitaria PAP basada en AWX 24.6.1, Kubernetes/K3s, Operator, Web/Task, PostgreSQL, Redis y Execution Environments. No sustituye las pruebas de cada versión específica ni implica certificación por el proyecto upstream.

## 2. Resultado por dominio

| Dominio | Estado y evidencia |
| --- | --- |
| Arquitectura y documentación | Documentadas en los README y guías técnicas de ramas de distribución |
| Flujo de contribución | **CERRADO:** ramas `contrib`, `dev`, `prd`; cambios README/CONTRIBUTING integrados mediante PR #18 |
| Redis | **CERRADO técnicamente:** Redis 8.10.2, hashes de ambos ejecutables iguales al upstream, AGPLv3 identificada y pruebas básicas reportadas; PR #19 |
| Operator, Web, Task, PostgreSQL y EE | RC2 **funcional en laboratorio**, según evidencias ya registradas; no extrapolar automáticamente a RC1 o a futuras imágenes |
| RC1 pública | Seis manifiestos GHCR accesibles anónimamente y digests inmutables documentados en `prd/releases/ghcr-digests-v0.1.0-rc1.txt` |
| Instalador online | Scripts, preflight y renderizado documentados; ensayos de manifiestos **no sustituyen** una instalación externa completa |
| Seguridad y terceros | Políticas LICENSE/NOTICE/SECURITY publicadas; conservar evaluación de vulnerabilidades y obligaciones por paquete como parte del control general de cada release |
| Candidato de imágenes posterior | **PENDIENTE CONFIRMACIÓN EXTERNA** desde el flujo de construcción y validación que está ejecutándose en paralelo |

## Tiempo observado de instalación

**Última instalación completa de laboratorio: 20 minutos en total**, desde el inicio hasta la finalización del proceso, según la medición reportada por el responsable de la prueba.

Este dato es una **medición histórica de una ejecución**, no un SLA, promedio estadístico ni garantía de duración. Puede variar por CPU, RAM, almacenamiento, conectividad, descarga de imágenes, desempeño de Kubernetes y migraciones. No extrapolar este tiempo a una instalación nueva sin medición.

## 3. Única entrada para cerrar el paquete de imágenes nuevo
Registrar, una vez confirmado en el flujo de construcción: etiqueta/versionado del candidato, commit Git, resultado CI, nombres de las seis imágenes, digests OCI publicados, accesibilidad anónima, resultado de escaneo y problemas bloqueantes (si los hay). Si se decide reutilizar digests RC1, registrar explícitamente que son los mismos; no asumirlo.

La confirmación podrá incorporarse al siguiente PR/release sin reabrir la verificación de identidad de Redis, ya concluida.

## 4. Puerta independiente: homologación del instalador
Para anunciar la nueva versión como **instalable y probada de extremo a extremo**, se necesita un reporte de instalación desde cero en un clúster aislado, utilizando exactamente los digests del candidato, que cubra:
- Preflight y preparación de recursos autorizados;
- Operator y migración de PostgreSQL;
- Web/API, inicio de sesión y Task;
- Red interna (Task ↔ Web, base de datos y Redis);
- Job Ansible real con un EE publicado, resultado y eventos en UI/API.

Estas comprobaciones pueden reutilizarse **si ya están documentadas para los mismos digests y manifiestos**. No exigir duplicarlas sin justificación. No probar sobre producción.

## 5. Condiciones de publicación y responsables
- `contrib`: documentación y participación; `dev`: integración; `prd`: promoción aprobada por Pull Request. `main` no forma parte del flujo.
- Un release debe referenciar commit, artefactos, hashes/digests, instrucciones, notas y limitaciones conocidas.
- La revisión de licencias de terceros y la trazabilidad de compilación se mantienen en el proceso transversal de distribución; no presentarlas como falla de Redis.
- No declarar *Production Ready* exclusivamente por una compilación, un `PONG`, el estado `Running` o un escaneo aislado.

## 6. Decisión de cierre

**Aprobado para archivo documental:** arquitectura, contribución, Redis y el estado conocido de RC1/RC2.

**A la espera de confirmación:** imágenes del nuevo candidato (en validación paralela). La generación y publicación son un hito; la aceptación de instalación, otro.

**No se autorizan cambios en servidores, imágenes existentes o la rama `prd` mediante esta acta.** El cierre final de la versión se documentará mediante la confirmación de CI y, en su caso, la aceptación del instalador. Esto evita tareas nuevas innecesarias y conserva los límites de lo realmente verificado.

## Referencias

- [Matriz de release](RELEASE-CLOSURE.md)
- [Cierre técnico de Redis](REDIS-CLOSURE.md)
- [README principal](../README.md)
- [RC1 publicada](https://github.com/phoenix-automation-platform/phoenix-automation-platform-community/releases/tag/v0.1.0-rc1)
- [Registro de digests RC1 (`prd`)](https://github.com/phoenix-automation-platform/phoenix-automation-platform-community/blob/prd/releases/ghcr-digests-v0.1.0-rc1.txt)
- [Cierre de README y contribución: PR #18](https://github.com/phoenix-automation-platform/phoenix-automation-platform-community/pull/18)
- [Cierre Redis: PR #19](https://github.com/phoenix-automation-platform/phoenix-automation-platform-community/pull/19)
