# Guía de contribución / Contributing Guide

PAP acepta propuestas mediante Issues y Pull Requests. Utiliza un Fork, crea una rama de trabajo y solicita revisión hacia `contrib`. La rama `prd` publica únicamente versiones aprobadas. `contrib` presenta el proyecto y sus reglas. No incluyas secretos, datos empresariales ni material sin licencia compatible.

---

# Contributing Guide (English)

Thank you for contributing to Phoenix Automation Platform (PAP).

## Contribution workflow

1. Check existing Issues before opening a new one.
2. Open an Issue for significant changes and describe the intended behavior.
3. Fork this repository and create a focused branch (for example, `fix/description` or `docs/topic`).
4. Submit a Pull Request **targeting `contrib`**. Do not target `dev`, `prd`, or `main` directly.
5. Explain the change, motivation, compatibility, risks, tests, and documentation updates.
6. Wait for maintainer review and required CI checks. Maintainers promote approved changes from `contrib` to `dev`, and validated changes from `dev` to `prd`.

## Rules

- Never commit credentials, tokens, private keys, personal records, customer inventories, or internal infrastructure details.
- Retain applicable upstream licenses, copyright notices and attribution. Declare third-party sources.
- Do not introduce undocumented host-level changes (SELinux, firewall, storage, networking).
- Include reproducible tests for behavior changes and redact logs.
- Security, authentication, operator, installer, and permission changes need special maintainer review.
- By submitting a contribution, you affirm that you have the right to submit it under the applicable license.

Read [SECURITY.md](SECURITY.md) for vulnerability reporting; do not disclose exploitable issues in public Issues.

## Autoría y DCO (Español)

Seguimos un mecanismo equivalente al de contribuciones de AWX: cada commit debe incluir la firma de conformidad con el Developer Certificate of Origin (DCO 1.1). Utiliza `git commit -s -m "descripción"`. La firma DCO confirma el derecho a enviar la contribución, pero no sustituye el análisis de licencias de terceros. Los Pull Requests deben dirigirse a `dev`, sin commits de merge ni secretos.

---

## Developer Certificate of Origin (English)

PAP follows the upstream AWX contribution model: contributors must sign off each commit under Developer Certificate of Origin (DCO) 1.1. Use `git commit -s -m "description"` and submit a Pull Request to `contrib`. A DCO sign-off asserts the right to submit the work, but does not replace third-party license and provenance checks. Keep PR history clean and free of secrets and merge commits.

See https://developercertificate.org/ for the DCO text.
