# Preparación del repositorio de comunidad (sin crear ramas aún)

## Estado

Este archivo documenta la configuración propuesta. La creación de ramas y la publicación de fuentes requieren una fase posterior y aprobación del responsable.

## Modelo previsto

| Rama | Propósito | Entrada |
| --- | --- | --- |
| `dev` | Integración comunitaria, pruebas y revisión | Pull Requests aprobados desde Forks |
| `prd` | Código estable publicado | Promoción revisada `dev → prd` |

El repositorio público es independiente del repositorio interno de compilación y aceptación; **no debe recibir credenciales, imágenes privadas ni parámetros de infraestructura interna**.

## Secuencia cuando se autoricen ramas

1. Validar licencia, copyright, referencias a marcas, dependencias y secretos de todo el material a publicar.
2. Crear `dev` a partir de una base revisada.
3. Crear `prd` desde la misma base aprobada.
4. Definir `prd` como rama predeterminada para que visitantes vean documentación y código estable.
5. Configurar protección de `prd` y `dev` antes de invitar colaboradores.
6. Habilitar el flujo de Issues, Forks y PRs a `dev`.
7. Preparar CI de análisis estático, tests y control de secretos **antes de exigir checks por nombre**.

## Configuración recomendada de GitHub

En `Settings → Rules → Rulesets` o `Branches` (según el plan y la interfaz):

- Proteger `prd`: solicitar Pull Request, revisión, bloqueo de force-push y eliminación; requerir checks definidos y disponibles.
- Proteger `dev`: solicitar Pull Request de terceros, revisión de propietario y tests; bloquear eliminación y force-push.
- Habilitar **Require review from Code Owners** donde el plan lo permita.
- Usar `CODEOWNERS` para solicitar revisión al propietario.
- Usar **Squash merge** para aportes pequeños y trazables.
- Limitar las credenciales de workflows (`permissions: contents: read` por defecto).
- Evitar ejecución de scripts de PR externos con secretos o permisos de escritura.

## Protecciones y matices de GitHub

La aplicación de ciertas rulesets o protecciones en repositorios públicos personales puede variar según plan y permisos; comprobar que la regla esté **active** y aplicándose, no solo creada. Los administradores con bypass pueden mantener capacidad de emergencia, pero usarla excepcionalmente.

## Checklist previo a publicar fuentes

- [ ] Revisión de secretos y configuraciones internas.
- [ ] Licencias y atribuciones de fuentes, imágenes y assets.
- [ ] Rama base y release definido.
- [ ] CI en entorno aislado y sin credenciales expuestas.
- [ ] Guías de instalación y dependencias reproducibles.
- [ ] Avisos de cambios respecto a AWX.
- [ ] Política de reportes de seguridad publicada y habilitada.
