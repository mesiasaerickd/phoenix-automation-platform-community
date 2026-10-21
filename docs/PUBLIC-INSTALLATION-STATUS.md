# Phoenix Automation Platform - Public Installation

## Release status

The source code and installation automation are being prepared
for public community distribution.

The production installer must use container images from:

ghcr.io/phoenix-automation-platform/

## Requirements

- Compatible Kubernetes cluster.
- Required storage and networking.
- Container registry connectivity.
- Published PAP images.
- Approved versioned release manifest.

## Authentication

Public container images must support anonymous pulls.

Personal GitHub credentials must not be required.

## Validation

Before announcing a public release:

1. Publish all required images.
2. Verify anonymous image pulls.
3. Verify the image architecture.
4. Pin tested image versions or digests.
5. Test installation in an isolated Kubernetes cluster.
6. Validate Web, Task, database, Redis and job execution.

Until those checks pass, public installation is not certified.
