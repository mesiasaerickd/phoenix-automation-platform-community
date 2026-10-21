# PAP — primer acceso después de instalar (RC1)

Guía para un **usuario nuevo** con una instalación online en K3s/Kubernetes. Requiere acceso administrativo local al clúster. Ninguno de estos pasos crea credenciales o abre un puerto externo.

## Resultado medido en instalación limpia SVLNX02 (20 oct 2026, Perú)

RHEL 9.8, K3s v1.36.5+k3s1, namespace `pap-acceptance`, recurso AWX `pap-security`, imágenes GHCR públicas `dev-20261020`. Instalador devolvió `0`; Operator `1/1`, PostgreSQL `1/1`, migración 24.6.1 `Complete 1/1` (3 min 46 s), Web `3/3`, Task `4/4`, `/api/` y `/api/v2/` HTTP 200. Sin eventos Warning al final.

K3s inició a las 22:30:21 y API se verificó aproximadamente a las 22:50, lo que equivale a **unos 20 minutos de inicio de K3s a API funcional**. Es una medición de un laboratorio, no garantía de duración, e incluye esperas de arranque e interacción humana. El tiempo de corrección de firewall y preparación previa no queda medido integralmente.

## Estado y credencial inicial

Desde el checkout público:

```bash
bash scripts/post-install.sh pap-acceptance pap-security
```

El script **no imprime contraseñas**, únicamente verifica pods, servicio y que exista el Secret `pap-security-admin-password` (nombre convencional del operador AWX). El nombre del usuario administrador predeterminado es `admin` salvo personalización. Si el Secret no existe, investigar el estado del Operator; no asumir ni fabricar una contraseña.

Para revelar la contraseña **únicamente en una terminal local interactiva y privada**:

```bash
bash scripts/show-admin-password.sh pap-acceptance pap-security
```

Se necesita RBAC para leer Secrets. La contraseña se muestra únicamente por petición expresa del administrador; no pegar el valor en chats, incidencias, pipelines ni archivos de logs. Cambiarla tras el primer acceso según la política de la organización.

## Acceder al panel sin exponer servicios

La instalación crea `pap-security-service` como `ClusterIP`, **no** una URL pública. Iniciar en una terminal del nodo:

```bash
k3s kubectl -n pap-acceptance port-forward svc/pap-security-service 18080:80 --address=127.0.0.1
```

Desde un navegador en el mismo nodo: `http://127.0.0.1:18080`. Si el navegador está en otra máquina, mantener `port-forward` activo en el nodo y establecer desde el cliente un túnel SSH `ssh -L 18080:127.0.0.1:18080 usuario@servidor`. Abrir entonces `http://127.0.0.1:18080` en el equipo cliente. No cambiar `--address` a `0.0.0.0` por conveniencia. El túnel es temporal; para producción usar un reverse proxy/Ingress con HTTPS, autenticación y controles de acceso aprobados. Si NGINX del host ya usa 80/443 no modificarlo sin planificación.

## Seguridad y aceptación pendientes

Un `HTTP 200` no valida por sí solo autenticación ni ejecución Ansible. Probar inicio de sesión, API autenticada, Job Template real y comprobación `bash scripts/preflight.sh pap-acceptance post`; registrar resultados. Para la instalación medida, `cni0` se asignó **temporalmente** a zona `trusted` como diagnóstico de bloqueo de Metrics Server. No considerarlo configuración permanente ni solución endurecida; consultar `docs/K3S-METRICS-FIREWALLD-TROUBLESHOOTING.md` cuando se fusione. Disco provisionado de 47 GiB, inferior a los 60 GiB recomendados para laboratorio: capacidad pendiente de aceptación.
