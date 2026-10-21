# PAP Task derived from the pinned runtime image (no EE customizations).
# Trust only repositories under the managed AWX projects root.
FROM ghcr.io/mesiasaerickd/pap-web-task@sha256:3befd093a297edd140eec4bda2f102777d98c89f46dc8d85a978a3b645a294ee
USER 0
RUN set -eu; \
    git config --system --add safe.directory '/var/lib/awx/projects/*'; \
    git config --system --get-all safe.directory | grep -Fx '/var/lib/awx/projects/*'
USER 1000:0
