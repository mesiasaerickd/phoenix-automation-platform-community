# PAP v0.1.0 RC1 — Estado de auditoría de redistribución

**Estado:** revisión técnica parcial; redistribución y cumplimiento de licencias **no certificados**. Este registro se basa en inventarios ejecutados sobre seis imágenes locales con etiqueta `dev-20261020`; no equivale a una SBOM completa ni a asesoría legal.

## Contexto y objetivo

Phoenix Automation Platform es una iniciativa comunitaria independiente basada en AWX. El software se publica gratuitamente; ello no sustituye las obligaciones de licencias y avisos originales. No existe afiliación, certificación ni patrocinio oficial de Red Hat, AWX o Ansible.

## Evidencia recopilada en SVLNX01

| Imagen | Base observada | RPM | APK | Paquetes Python detectados | Metadatos Python sin licencia declarada |
| --- | --- | ---: | ---: | ---: | ---: |
| pap-operator | AlmaLinux 9.8 | 239 | — | 35 | 5 |
| pap-web-task | AlmaLinux 9.8 | 214 | — | 18 | 3 |
| pap-postgres | AlmaLinux 9.8 | 225 | — | 4 | 0 |
| pap-redis | Alpine 3.24.2 | — | 20 | 0 | 0 |
| pap-ee-control | AlmaLinux 9.8 | 241 | — | 34 | 4 |
| pap-ee-core | AlmaLinux 9.8 | 241 | — | 34 | 4 |

Los totales incluyen paquetes repetidos entre imágenes. La ausencia de licencia en metadatos de Python no implica necesariamente una licencia ausente del proyecto. Los datos proceden de inventarios locales bajo `/opt/pap-license-audit` y requieren evaluación de integridad.

## Pendientes verificables

1. **Redis 8.10.2:** ejecutable `/usr/local/bin/redis-server` copiado durante la construcción, no registrado como APK. No se encontró aviso de licencia de Redis en las ubicaciones comprobadas. Redis 8 está disponible bajo elección entre AGPLv3, SSPLv1 o RSALv2; para el objetivo open source de PAP debe evaluarse la opción AGPLv3, retener sus avisos y cumplir las obligaciones aplicables. Ver [política oficial de Redis](https://redis.io/legal/licenses/). **Pendiente:** comprobar el origen exacto del binario, proporcionar atribución, licencia correspondiente y acceso al código fuente adecuado.
2. **pap-event-bridge 0.1.0:** dentro de la imagen `pap-operator` se identificaron `pap_event_bridge/__init__.py` y `plugin.py`, pero no metadatos de autor ni licencia declarada. **Pendiente:** localizar repositorio/autor y documentar licencia original o de contribución autorizada.
3. **Frontend compilado:** se localizaron múltiples archivos `/var/lib/awx/public/static/awx/*.js.LICENSE.txt`. **Pendiente:** comprobar cobertura, integridad y correspondencia con la distribución del frontend y sus fuentes.
4. **Dependencias Python:** revisar avisos originales de Jinja2, lockfile, ptyprocess, setuptools, dumb-init y packaging cuando los metadatos son incompletos.
5. **Componentes Linux (RPM/APK):** completar inventario por licencia y obligaciones de redistribución, en especial paquetes GPL/LGPL.
6. **Fuentes de construcción:** verificar que las modificaciones y archivos fuente necesarios para reproducir las imágenes públicas estén accesibles con las atribuciones upstream.
7. **Homologación externa:** instalación completa desde el Release público en una VM Linux limpia pendiente.

## Criterio de publicación

La versión **v0.1.0-rc1** sigue siendo un **pre-release**. No presentarla como verificada legalmente, certificada, exenta de vulnerabilidades ni homologada para producción. Mantener licencias y avisos originales. Resolver los puntos anteriores antes de declarar completa la auditoría.

Este documento es un registro técnico para revisión comunitaria y no constituye dictamen jurídico.


## Evidencia complementaria: identidad del binario Redis

Comparación ejecutada en SVLNX01 entre `ghcr.io/phoenix-automation-platform/pap-redis:dev-20261020` y `docker.io/library/redis:8.10.2-alpine`:

- Ambas imágenes ejecutan Redis **8.10.2**.
- SHA256 del archivo `/usr/local/bin/redis-server` en ambas: `df1291685ab15c4708c5556298146a93f498387aa6265aa0988da88d9952e41d`.
- Resultado **REDIS_BINARY_MATCH=PASS**: los dos ejecutables comparados tienen contenido idéntico.
- La imagen oficial inspeccionada utiliza Alpine 3.23.6; la imagen PAP utiliza Alpine 3.24.2.
- No se encontraron archivos LICENSE/COPYING/NOTICE de Redis en `/usr/local`, `/usr/share` o `/opt` de la imagen oficial durante la comprobación. **Ausencia de avisos en esas rutas no exime de obligaciones de redistribución.**
- No se ha demostrado todavía la procedencia exacta del paso de copia en el proceso de construcción de PAP, aunque la identidad del binario con el oficial queda confirmada.

### Acciones de cumplimiento pendientes para Redis

1. Identificar el commit/tag de fuente Redis 8.10.2 y conservar su licencia auténtica y avisos de copyright, obtenidos de fuente oficial, sin editar el texto legal.
2. Documentar la elección de licencia redistributiva (p. ej., AGPLv3 si procede), verificar sus obligaciones con un especialista y facilitar el código fuente correspondiente y las instrucciones/oferta aplicables.
3. Añadir una receta pública reproducible del contenedor Redis, indicando base Alpine y origen verificado del binario.
4. Incorporar avisos/atribuciones a la distribución futura; los digests de RC1 **no cambian** por este documento.

### Estado

La comprobación de hashes resuelve la **identidad del ejecutable**, no completa la auditoría de licencias. No atribuir certificación legal o reproducibilidad al RC1 por este resultado.


## Actualización: PAP Event Bridge — fuente publicada

El responsable del proyecto confirmó que `pap-event-bridge 0.1.0` fue desarrollado íntegramente para Phoenix y no proviene de AWX ni de otro componente externo. Se publicaron los dos archivos Python obtenidos de la imagen `pap-operator:dev-20261020`, junto con un `pyproject.toml` declarando Apache-2.0 y una explicación en `components/pap-event-bridge/README.md`.

**Pendiente técnico:** reconstruir en una versión futura el paquete/imagen con estos metadatos y verificar que la declaración Apache-2.0 aparezca efectivamente en la distribución binaria. Esta documentación no modifica los digests de RC1.
