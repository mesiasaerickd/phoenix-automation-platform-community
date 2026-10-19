# Guía de contribución / Contributing Guide

PAP acepta propuestas mediante Issues y Pull Requests. Utiliza un Fork, crea una rama de trabajo y solicita revisión hacia `dev`. La rama `prd` publica únicamente versiones aprobadas. `contrib` presenta el proyecto y sus reglas. No incluyas secretos, datos empresariales ni material sin licencia compatible.

---

# Contributing Guide (English)

Thank you for contributing to Phoenix Automation Platform (PAP).

## Contribution workflow

1. Check existing Issues before opening a new one.
2. Open an Issue for significant changes and describe the intended behavior.
3. Fork this repository and create a focused branch (for example, `fix/description` or `docs/topic`).
4. Submit a Pull Request **targeting `dev`**. Do not target `prd`, `contrib`, or `main`.
5. Explain the change, motivation, compatibility, risks, tests, and documentation updates.
6. Wait for maintainer review and required CI checks. Maintainers alone promote reviewed changes to `prd`.

## Rules

- Never commit credentials, tokens, private keys, personal records, customer inventories, or internal infrastructure details.
- Retain applicable upstream licenses, copyright notices and attribution. Declare third-party sources.
- Do not introduce undocumented host-level changes (SELinux, firewall, storage, networking).
- Include reproducible tests for behavior changes and redact logs.
- Security, authentication, operator, installer, and permission changes need special maintainer review.
- By submitting a contribution, you affirm that you have the right to submit it under the applicable license.

Read [SECURITY.md](SECURITY.md) for vulnerability reporting; do not disclose exploitable issues in public Issues.
