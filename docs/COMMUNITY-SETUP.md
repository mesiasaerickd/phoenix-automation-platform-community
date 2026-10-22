# Configuración de comunidad / Community Repository Setup

Ramas creadas: `contrib` (documentación y presentación), `dev` (integración de PR), `prd` (publicaciones estables). `main` no forma parte del flujo y no debe usarse. La rama predeterminada observada al 21/10/2026 es `contrib`. Se propone cambiarla a `prd` para que la distribución sea la entrada principal, conservando las reglas de protección existentes. Esta modificación se realiza desde Settings del repositorio.

---

# Community Repository Setup (English)

## Branch model

| Branch | Purpose | Contributions |
| --- | --- | --- |
| `contrib` | Public landing page, community policies, documentation | Maintainer-approved updates |
| `dev` | Reviewed community source integration | PRs from forks, with checks |
| `prd` | Stable reviewed releases, tagged for download | Maintainer promotion only |
| `main` | Not used; should not be created | No contributions |

The private development and production repository is **separate**. Never mirror private credentials, infrastructure configuration, unpublished images, or internal artifacts.

## Existing settings and future checklist

1. **Settings → General → Default branch:** cambiar de `contrib` a `prd` (no implica deshabilitar la protección de `prd`).
2. **Settings → Rules → Rulesets:** create an active rule for `prd`: require a pull request and maintainer approval, block deletions and force-pushes, and require passing checks once CI checks exist.
3. Add an active rule for `dev`: require pull requests, reviews, and passing tests where available; prevent deletion and force-push.
4. Protect `contrib` from deletion and force-push; require review for changes.
5. Add `.github/CODEOWNERS`, use least-privilege GitHub Actions tokens, and do not expose secrets to untrusted PR workflows.
6. Publish installation artifacts as **versioned GitHub Releases** from tested `prd` commits; branch protection does not itself provide installable software.
7. Verify rules are active/enforced for this repository and account plan.

**Important:** repository visibility and read access are separate from write permissions. Any visitor can read a public `prd`; write and merge permissions must remain restricted.

## Publication gate

Do not copy source or build artifacts from the private repository until secrets, licenses, upstream NOTICE obligations, code provenance, assets, dependencies, and reproducible build/test evidence have been audited. Document each release with commit, version, hashes, and installation instructions.
