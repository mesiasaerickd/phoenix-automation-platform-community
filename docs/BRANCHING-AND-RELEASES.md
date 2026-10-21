# Phoenix Automation Platform — Branching and Releases

## Branches

- `contrib`: default branch for community collaboration and proposals.
- `dev`: integration, development, security fixes and testing.
- `prd`: approved and supported release source.

All three branches are protected.

## Contribution process

External contributors should fork the repository and submit
pull requests against `contrib`.

Maintainers review contributions and promote approved changes
to `dev` through pull requests.

Validated changes are promoted from `dev` to `prd` through
reviewed pull requests.

Do not push directly to protected branches.

## Documentation

Architecture, installation, security and operational documentation
must be consistent with the code and release version.

The `prd` branch contains documentation for approved releases.
Development-only instructions must be clearly identified.

## Container images

Release images must be published under:

`ghcr.io/phoenix-automation-platform/`

Images intended for public installation must support anonymous pull.

Do not publish personal registry credentials or internal secrets.

Use immutable image digests for reproducible releases.

## Release requirements

A production release requires:

1. Source and license review.
2. Secret scanning.
3. Dependency vulnerability assessment.
4. Successful CI builds.
5. Public image availability.
6. Installation verification in a clean environment.
7. Web, Task and job execution validation.
8. Published release notes.

Unvalidated builds must be labeled as development candidates.
