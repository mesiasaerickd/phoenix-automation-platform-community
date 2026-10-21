# PAP Redis — reconstructed build candidate (NOT approved for release)

This folder records the observed PAP Redis `dev-20261020` build layout. The original build recipe was not recovered. `Containerfile.candidate` is a **new reconstruction**, not an attestation of the original.

The published container runs Alpine 3.24.2, has 20 APK packages, and includes `redis-server`, `redis-cli`, and the project-owned 156-byte `pap-entrypoint.sh`. The latter was transcribed exactly from the published image. Redis binaries are copied from the official Redis 8.10.2 Alpine container, whose `redis-server` file SHA256 matches the PAP file (`df1291685ab15c4708c5556298146a93f498387aa6265aa0988da88d9952e41d`). The `redis-cli` origin still requires an independent hash comparison.

## Redis licensing / third-party notices

Redis 8.10.2 allows the AGPLv3 licensing option. PAP elects AGPLv3 for its separate Redis component; this does not relicense unrelated PAP components. Original Redis `LICENSE.txt`, `REDISCONTRIBUTIONS.txt`, the tagged source archive, and `redis-full.tar.gz` are in the `v0.1.0-rc1` release assets. The Redis full tarball was verified against upstream's declared SHA256.

Alpine 3.24.2 is a distinct distribution with 20 installed APK packages. The RC1 release also includes their APK license metadata and the recipe/patch/upstream-source bundle for six GPL/LGPL source families, based on aports `3.24-stable` commit `e78f5987166c6ffbe23f6472e2e8f040298fe2da`.

### Must be completed BEFORE publishing a new Redis image

1. Verify `redis-cli` file identity against the official image, and pin both base images to verified immutable digests.
2. Package applicable original license texts, copyright notices, source links and complete corresponding source/build instructions for **all** third-party components, including packages outside the GPL/LGPL subset. The absence of license files in the current container must be corrected. Confirm required notices are present in the shipped artifact and accessible with the distribution.
3. Verify upstream image stage content, Alpine package versions, script SHA256, runtime behavior, and package source correspondence. `apk upgrade` is not a reproducible lock: record exact package repository snapshot/pinning or equivalent controlled build inputs.
4. Determine the original `COPY multi:...` scope: the new recipe intentionally copies two known executables rather than claiming perfect original filesystem reproduction.
5. Review applicable AGPLv3, GPLv2, LGPL, MPL and other obligations, including sources/installation information where required, with a qualified reviewer. Do not declare legal compliance based only on URL lists or package metadata.

Do not replace the published release images or the running cluster during this audit.

## Verificación adicional — 20 de octubre de 2026

Se compararon con SHA256 **ambos** ejecutables presentes en la imagen PAP contra `docker.io/library/redis:8.10.2-alpine`, obteniendo coincidencia exacta:

- `redis-server`: `df1291685ab15c4708c5556298146a93f498387aa6265aa0988da88d9952e41d`
- `redis-cli`: `b3b11461c9b2e376bea58d43afdefa46d1336c3b2a0cd6738feb1fbe735add19`

**BINARY_IDENTITY=PASS (2/2).** No verifica por sí solo los avisos, todas las fuentes correspondientes o la reproducibilidad de la imagen.

### Bloqueadores para concluir cumplimiento

- El archivo de fuentes Redis completo y el paquete Alpine GPL/LGPL ya figuran adjuntos en el RC1; se verificó su integridad. Falta auditoría completa de textos de licencia, derechos de autor, fuentes y obligaciones de paquetes restantes (incluidos MPL/MIT/Apache y demás).
- Falta agregar los avisos exigibles y la información de fuentes en una nueva imagen y verificar su presencia.
- Falta fijar digests de imágenes base y resolver los parámetros de compilación / snapshot APK para asegurar reproducción.
- Falta ejecutar prueba de compilación y ejecución aislada, no en el clúster actual.

No presentar el RC1 como certificado ni el PR candidato como completo hasta satisfacer estos controles.
