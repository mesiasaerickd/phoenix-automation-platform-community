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

## Prueba por IP y puerto, sin NGINX ni certificados

El usuario puede decidir posteriormente cómo publicar PAP con dominio, reverse proxy o TLS. Para una prueba temporal desde otro equipo en una red aislada y de confianza:

```bash
k3s kubectl -n pap-acceptance port-forward svc/pap-security-service 18080:80 --address=172.16.205.131
```

Desde el navegador de ese equipo abrir `http://172.16.205.131:18080`, ingresar con el administrador y validar la interfaz. Sustituir la IP por la IP real del servidor; mantener la terminal abierta. `Ctrl+C` detiene la publicación y evita dejar un servicio expuesto permanentemente. El administrador debe autorizar acceso TCP/18080 **solo desde clientes de prueba permitidos** cuando el firewall lo requiera; el instalador no altera reglas automáticamente. No publicar HTTP sin cifrar en redes no confiables ni transmitir credenciales reales por Internet. Si existe riesgo de interceptación, usar el túnel SSH descrito anteriormente.

Prueba mínima: pods Web 3/3 y Task 4/4, PostgreSQL 1/1, migración Complete, interfaz de login accesible, autenticación y endpoints API HTTP 200. La ejecución de un Job Template real es un control posterior necesario para aceptación funcional.

## Procedimiento completo de comprobación para un usuario nuevo

### 1. Identificar el servidor y verificar el despliegue

Desde el servidor que tiene acceso administrativo a K3s:

```bash
hostname
hostname -I
k3s kubectl get nodes -o wide
k3s kubectl get pods -n pap-acceptance
k3s kubectl get jobs -n pap-acceptance
k3s kubectl get svc pap-security-service -n pap-acceptance
```

El ejemplo de este laboratorio es hostname `SVLNX02`, IP `172.16.205.131`. En cualquier otra instalación, sustituir namespace (`pap-acceptance`), recurso (`pap-security`) e IP por los reales. Esperamos Operator `1/1`, PostgreSQL `1/1`, Web `3/3`, Task `4/4`, Job de migración `Complete`.

### 2. Recuperar la contraseña inicial

El usuario predeterminado es `admin`. El Operator conserva la contraseña inicial en el Secret `<nombre-recurso>-admin-password`. Verificar su presencia:

```bash
k3s kubectl get secret pap-security-admin-password -n pap-acceptance -o name
```

Obtener la contraseña **solo en una terminal privada**:

```bash
k3s kubectl get secret pap-security-admin-password -n pap-acceptance -o jsonpath='{.data.password}' | base64 --decode
printf '\n'
```

El valor es secreto; no pegarlo en chats, tickets ni logs, ni utilizar `set -x`. Proteger el acceso RBAC de lectura de Secrets y cambiar la credencial después del primer ingreso.

### 3. Publicar el acceso temporal por IP y puerto

En una terminal del servidor K3s, ejecutar:

```bash
k3s kubectl -n pap-acceptance port-forward svc/pap-security-service 18080:80 --address=172.16.205.131
```

En el navegador de un cliente de la **red de laboratorio controlada**, abrir `http://172.16.205.131:18080`. Iniciar sesión con `admin`. El comando permanece ejecutándose y se detiene con `Ctrl+C`. De ser necesario, permitir TCP/18080 en el firewall únicamente desde IPs autorizadas; no exponer HTTP a Internet. Para redes no confiables, preferir túnel SSH sobre 127.0.0.1 o HTTPS configurado por el administrador.

### 4. Comprobar HTTP/API y ejecución

Desde el host con acceso a la dirección de prueba:

```bash
curl -s -o /dev/null -w 'WEB_HTTP=%{http_code}\n' http://172.16.205.131:18080/
curl -s -o /dev/null -w 'API_HTTP=%{http_code}\n' http://172.16.205.131:18080/api/v2/
```

En el laboratorio ambos fueron `HTTP 200`; después verificar inicio de sesión real y ejecutar un Job Template Ansible de prueba. Finalmente revisar `bash scripts/preflight.sh pap-acceptance post`. Que devuelva 200 no comprueba por sí solo el procesamiento de Jobs.

**Los pasos anteriores no configuran certificados, dominios ni NGINX:** esas opciones de exposición permanente corresponden al administrador del sitio.

## Seguridad y aceptación pendientes

Un `HTTP 200` no valida por sí solo autenticación ni ejecución Ansible. Probar inicio de sesión, API autenticada, Job Template real y comprobación `bash scripts/preflight.sh pap-acceptance post`; registrar resultados. Para la instalación medida, `cni0` se asignó **temporalmente** a zona `trusted` como diagnóstico de bloqueo de Metrics Server. No considerarlo configuración permanente ni solución endurecida; consultar `docs/K3S-METRICS-FIREWALLD-TROUBLESHOOTING.md` cuando se fusione. Disco provisionado de 47 GiB, inferior a los 60 GiB recomendados para laboratorio: capacidad pendiente de aceptación.
