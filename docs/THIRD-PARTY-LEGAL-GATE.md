# Third-party license verification gate — PAP RC1

**Status: OPEN / NOT legally certified.** This checklist identifies specific blockers, not a statement of legal compliance.

## Redis image evidence (verified)

- PAP `redis-server` and `redis-cli` file SHA256 match `docker.io/library/redis:8.10.2-alpine`.
- Redis 8.10.2 upstream full source `redis-full.tar.gz`, its original `LICENSE.txt` and `REDISCONTRIBUTIONS.txt` are attached to RC1. PAP elects the AGPLv3 Redis licensing alternative. Publication of source does not remove the duty to provide complete corresponding source, copyright/other notices and any required build information.
- Alpine 3.24.2 includes 20 enumerated APK packages; 11 have GPL/LGPL in the package license metadata. Six aports source families and their local patches match package version and revision, sourced from `3.24-stable` commit `e78f5987166c6ffbe23f6472e2e8f040298fe2da`. Five third-party tarballs match SHA512 in the APKBUILD recipes.
- RC1 release assets include `PAP-REDIS-ALPINE-ATTRIBUTIONS.md` and `PAP-REDIS-ALPINE-SOURCES-RC1.tar.gz` alongside Redis sources.

## Explicit unresolved requirements

- [ ] Verify every package's full original license texts, copyright statements, and required attribution/NOTICE. Inventory SPDX metadata alone is insufficient. This includes ca-certificates, OpenSSL, musl, zlib and other non-GPL packages.
- [ ] Verify corresponding source, configuration/build/install instructions and license-specific redistribution requirements for the complete binary distribution, not just six source families.
- [ ] Determine exact source/revision/snapshot of base Alpine and any packages obtained by `apk upgrade`. Pin immutable OCI digests and package inputs; independently rebuild and compare.
- [ ] Verify original `COPY multi` stage and complete set of files it inserted; `Containerfile.candidate` is a reconstruction only.
- [ ] Include required license texts and notices in the **new image or accompanying distribution**, test their accessibility for recipients, and review remaining obligations of AGPLv3/GPL/LGPL/MPL and any relevant mixed-license cases.
- [ ] Review Redis source modifications (if any), documentation and network-service obligations against the exact released binaries; official executable matching narrows but does not fully eliminate these checks.
- [ ] Review separate operator, web-task, postgres and EE images (including the built frontend JS license bundles and patched upstream sources), not merely Redis.
- [ ] Obtain qualified legal review where licensing interpretations are consequential.

## Release decision

Until all relevant boxes above are substantiated, **DO NOT claim `LEGAL PASS`**, certified open-source redistribution, or that the released images are fully reproducible. Keep existing v0.1.0-rc1 immutable and record fixes for a subsequent version. The clean installation test on SVLNX02 is an independent operational test and does not remove any legal obligation.
