> **¿Quieres instalar PAP?** Utiliza la [rama `prd`](https://github.com/phoenix-automation-platform/phoenix-automation-platform-community/tree/prd), que contiene el software y la [guía de instalación](https://github.com/phoenix-automation-platform/phoenix-automation-platform-community/blob/prd/README.md). Ejecuta `git clone --branch prd --single-branch https://github.com/phoenix-automation-platform/phoenix-automation-platform-community.git`. **`contrib` no es una rama instalable.**

> **Proyecto comunitario independiente:** Phoenix Automation Platform es una contribución gratuita y de código abierto basada en AWX. No está afiliada, certificada ni respaldada oficialmente por Red Hat, Ansible o AWX. Última versión publicada: [v0.1.0-rc1](https://github.com/phoenix-automation-platform/phoenix-automation-platform-community/releases/tag/v0.1.0-rc1) (candidata pública; instalación y pruebas funcionales de laboratorio completadas y aceptadas).

<div align="center">

<img src="docs/images/pap-banner.svg" alt="PAP — Phoenix Automation Platform" width="100%" />


# 🔥 Phoenix Automation Platform (PAP)
### Community Edition — Espacio para contribuciones

**[Español](README.md) · [English](README.en.md)**

**Ansible · Kubernetes / K3s · AlmaLinux · Execution Environments**

[Proyecto](#-sobre-el-proyecto) · [Arquitectura](#-arquitectura) · [Participar](#-cómo-contribuir) · [Documentos](#-documentación-de-la-comunidad)

</div>

---

> **Proyecto comunitario en preparación.** Este repositorio reúne las reglas, documentación y propuestas de la comunidad de PAP. La versión candidata pública [v0.1.0-rc1](https://github.com/phoenix-automation-platform/phoenix-automation-platform-community/releases/tag/v0.1.0-rc1) dispone de seis imágenes OCI públicas y una ruta de instalación online en las ramas de distribución. La instalación integral y las pruebas funcionales de laboratorio han finalizado satisfactoriamente, según confirmación del responsable. Esta aceptación no supone certificación externa ni homologación universal para producción.

## ✨ Sobre el proyecto

**Phoenix Automation Platform (PAP)** es una iniciativa independiente basada en componentes de **AWX** y otras tecnologías abiertas. Su propósito es conservar las capacidades de automatización Ansible —interfaz web, API REST, inventarios, proyectos, plantillas y Jobs— y evolucionar el empaquetado de contenedores, la trazabilidad de cambios y la experiencia operativa sobre Kubernetes/K3s.

El proyecto surgió de la necesidad de revisar dependencias e imágenes heredadas del release AWX 24.6.1, mediante una reconstrucción controlada con imágenes AlmaLinux y pruebas de integración.

### Áreas de colaboración

| Área | Ejemplos de aportes |
| --- | --- |
| **Contenedores** | Mejoras de construcción, compatibilidad de imágenes y dependencias |
| **Ansible** | Execution Environments, Runner, colecciones y pruebas de Jobs |
| **Kubernetes** | Manifiestos, operador, recursos y observabilidad de la aplicación |
| **Interfaz** | Accesibilidad, traducciones, documentación y experiencia |
| **Calidad** | CI, pruebas reproducibles y análisis de dependencias |
| **Documentación** | Guías, casos de uso, ejemplos y referencias |

## 🏗 Arquitectura

```mermaid
flowchart TB
    U["Operador"] --> W["PAP Web / API REST"]
    O["Operator"] -. concilia .-> W
    O -. concilia .-> T["PAP Task"]
    W <--> T
    W --> D["PostgreSQL"]
    T --> D
    T --> R["Control Plane EE / Receptor"]
    T <--> Q["Redis"]
    R --> E["Job Pod / Execution Environment"]
    E --> N["Destinos autorizados"]
    G["SCM / Git"] --> T
```

## ✅ Estado del proyecto

La versión candidata RC1 superó pruebas funcionales de laboratorio, incluyendo migración, interfaz/API y Jobs ejecutados desde dos Execution Environments personalizados. La instalación integral más reciente y sus pruebas funcionales se completaron satisfactoriamente. 

## 👤 Liderazgo y contacto técnico

**Erick David Mesias Arana** — **Fundador y líder técnico (Founder & Technical Lead)** de Phoenix Automation Platform (PAP).  
GitHub: [@mesiasaerickd](https://github.com/mesiasaerickd) · [Responsables y contacto](MAINTAINERS.md).

**Estructura de participación:** Core Maintainers, Development & QA y Community Contributors son áreas abiertas a colaboradores; no implican integrantes ya designados. Consulta los [roles del proyecto](MAINTAINERS.md).

Este reconocimiento corresponde a PAP como iniciativa independiente; se mantienen los créditos y las licencias originales de AWX, Ansible y otros componentes Open Source.

## 🤝 Cómo contribuir

1. Consulta [CONTRIBUTING.md](CONTRIBUTING.md) y revisa las incidencias existentes.
2. Propón una mejora mediante **Issue**, o crea un **Fork** para preparar código.
3. Trabaja en una rama de tu propio Fork y abre un **Pull Request** hacia `contrib`. Tras la revisión, los mantenedores promueven cambios de `contrib` a `dev` y posteriormente a `prd` mediante validaciones.
4. Describe los cambios, las pruebas y los posibles impactos.
5. El mantenimiento revisará y aceptará cada aporte antes de incluirlo.

La rama estable `prd` queda reservada para promociones revisadas; `contrib` alberga documentación y reglas. **Ramas comunitarias creadas:** `contrib`, `dev` y `prd`. La rama predeterminada es `contrib`. Consulta [la política de ramas](docs/COMMUNITY-SETUP.md) y confirma en GitHub la aplicación efectiva de las protecciones antes de cualquier promoción.

## 📚 Documentación de la comunidad

| Documento | Función |
| --- | --- |
| [README.en.md](README.en.md) | Presentación en inglés |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Proceso de contribución y calidad |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Normas de participación |
| [SECURITY.md](SECURITY.md) | Reporte responsable de fallos de seguridad |
| [SUPPORT.md](SUPPORT.md) | Dónde pedir ayuda y alcance |
| [NOTICE.md](NOTICE.md) | Procedencia y atribuciones |
| [LICENSE](LICENSE) | Condiciones de licencia |
| [docs/COMMUNITY-SETUP.md](docs/COMMUNITY-SETUP.md) | Preparación y protecciones previstas de `dev` y `prd` |

## Cierre técnico y de publicación


La instalación y las pruebas funcionales finales se cerraron satisfactoriamente en laboratorio, según confirmación del responsable. Los digests de RC1 se conservan como referencias históricas de esa publicación.


## ⚖️ Origen y licencias

PAP reconoce a [AWX](https://github.com/ansible/awx) como proyecto de referencia, publicado con licencia **Apache 2.0**. PAP es independiente y no debe confundirse con una distribución avalada oficialmente por los titulares de marcas de terceros. Consulta [NOTICE.md](NOTICE.md) y [LICENSE](LICENSE) para más información.

<div align="center"><sub>Build reproducible · Execute with control · Improve with community</sub></div>
