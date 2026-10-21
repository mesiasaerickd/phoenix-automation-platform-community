# Derived from the exact Control Plane image validated in SVLNX02.
# Do not replace the operand image until the workflow build and fresh-VM tests pass.
FROM ghcr.io/mesiasaerickd/pap-ee-control@sha256:776a5f0549461bf0767ca7ad52146d99120e6db4ed42c95f8c411acfc30736e3
USER 0
RUN set -eu; \
    if ! getent passwd 1001 >/dev/null; then \
      if grep -q '^pap:' /etc/passwd; then exit 1; fi; \
      printf 'pap:x:1001:0:PAP Execution User:/runner:/sbin/nologin\n' >> /etc/passwd; \
    fi; \
    getent passwd 1001; \
    git config --system --add safe.directory '/var/lib/awx/projects/*'; \
    git config --system --get-all safe.directory | grep -Fx '/var/lib/awx/projects/*'
USER 1001:0
