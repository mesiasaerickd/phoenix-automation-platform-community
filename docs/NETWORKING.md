# PAP — Requisitos de red y firewall (K3s/Kubernetes)

> Estado: rama `dev`, requisitos y preflight de instalaciones online. Este documento NO autoriza cambios automáticos en el firewall del host. Los CIDR, puertos, zonas y topología deben obtenerse del clúster real y aprobarse antes de aplicar reglas.

## Responsabilidades

- **Administrador de infraestructura**: proporcionar red, DNS, salida al registro OCI (o imágenes locales en modo offline), acceso a la interfaz, rutas entre nodos, requisitos de almacenamiento y aprobación de reglas del firewall del host.
- **Instalador PAP**: detectar y reportar estado de K3s/Kubernetes, CNI, CIDR de pods y servicios, SELinux, firewalld, forwarding, NetworkPolicies y conectividad relevante; instalar recursos Kubernetes propios de PAP y sus NetworkPolicies.
- **Nunca** instalar, habilitar, detener, deshabilitar ni reconfigurar firewalld o SELinux de manera silenciosa. Ante bloqueo, detenerse con diagnóstico, regla propuesta, alcance y reversión; aplicar solo después de autorización explícita.
- Si firewalld está deshabilitado o ausente, no instalarlo ni activarlo. Validar de todas formas controles de red existentes.

## Matriz de conectividad (ajustar por topología)

| Flujo | Transporte | Puerto | Necesidad / alcance |
|---|---|---|---|
| Administrador -> API Kubernetes | TCP | 6443 | Si administra K3s remotamente; acceso restringido a administradores/nodos autorizados |
| Nodo K3s -> kubelet / componentes que lo consultan | TCP | 10250 | Según topología y monitorización; no publicar indiscriminadamente |
| Nodo K3s <-> nodo K3s (Flannel VXLAN) | UDP | 8472 | **Solo multi-nodo con Flannel VXLAN**; únicamente entre IP de nodos, nunca Internet |
| Nodos de control K3s HA con etcd embebido | TCP | 2379-2380 | Solo cuando se despliega HA con etcd; restringir a nodos de control |
| Pods -> DNS del clúster | UDP/TCP | 53 | DNS interno, NetworkPolicies deben autorizarlo |
| PAP Task -> PAP Web, por IP del pod | TCP | 8052 | Tráfico interno pod a pod; no exponer directamente al exterior |
| PAP Web/Task -> PostgreSQL | TCP | 5432 | Tráfico interno y solo consumidores autorizados |
| Cliente -> interfaz PAP | TCP | 443 recomendado | Terminado en ingress/reverse proxy; 80 solo según diseño/redirección |
| Nodo/instalador -> GHCR y fuentes online | TCP | 443 | Solo modo online; autenticación independiente para imágenes privadas |

Los puertos anteriores describen flujos, no una instrucción de abrir todos ellos. Para un clúster de nodo único no es necesario abrir UDP/8472 hacia otros equipos. Los puertos pueden variar por CNI, versión y diseño del clúster; validar documentación del proveedor y configuración real.

## Preflight obligatorio antes de instalar

1. Validar `kubectl get --raw=/readyz`, nodos `Ready`, CNI y DNS.
2. Detectar Pod CIDR y Service CIDR sin copiarlos del laboratorio; en multi-nodo contemplar múltiples Pod CIDR, no asumir uno único.
3. Detectar `firewalld` (activo/inactivo/ausente), zonas de `cni0` / `flannel.1` cuando existan, políticas de forwarding y reglas nftables efectivas. Verificar `net.ipv4.ip_forward=1` cuando corresponda al CNI.
4. Comprobar SELinux y mantener `Enforcing` si así lo exige la plataforma.
5. Validar NetworkPolicies de entrada/salida en PAP, especialmente Task -> Web TCP/8052, Web/Task -> PostgreSQL TCP/5432 y acceso a DNS.
6. Verificar conectividad **directa entre IP de pods** además de conectividad mediante ClusterIP: el Service puede funcionar mientras la conexión directa falla.
7. Verificar permisos y acceso al registro para descargar imágenes sin registrar PAT/contraseñas en logs.
8. Después del despliegue, ejecutar una prueba real de Job Template, observar errores de Receptor y wsrelay y repetir verificaciones tras reinicio controlado.

## Incidencia reproducida — NODO de prueba (18 oct 2026)

Laboratorio: RHEL 9.8, K3s v1.36.5+k3s1, nodo único `IP privada del nodo`, `cni0` `CIDR de pods detectado`, firewalld activo, NetworkPolicies con default-deny y excepciones Task/Web.

- Task (`IP del pod Task`) -> Web (`IP del pod Web:8052`): `No route to host`; conexión Task -> Service `pap-security-service:80` sí funcionaba.
- La política firewalld existente `pap-k3s-postgres` solo autorizaba TCP/5432 entre pods.
- Se comprobó causalidad práctica: al permitir temporalmente `IP del pod Task -> IP del pod Web:8052`, conectividad `PASS`; tras retirar regla, se implementó **solo en el laboratorio** una autorización persistente `CIDR de pods detectado -> CIDR de pods detectado`. Posteriormente Task -> Web pasó y no aparecieron nuevos errores wsrelay durante una ventana de 60 segundos.
- **Deuda de endurecimiento:** la autorización amplia permite tráfico entre todos los pods de esa subred a nivel del firewall del host. No copiar esta regla a producción ni asumir que será correcta en otras instalaciones. Diseñar permisos mínimos y reversión para la topología real; las NetworkPolicies son una capa adicional, no sustituyen el firewall del host.
- La prueba no valida por sí sola una instalación completa: sigue pendiente Job Template integrado, reproducibilidad desde cero y verificación tras reinicio.

## Criterio de fallo seguro

Si falla un flujo obligatorio: emitir `BLOCKED: NETWORK`, indicar origen, destino, puerto, evidencia, administrador responsable, recomendación mínima y comandos de reversión específicos **sin ejecutar el cambio**. No desactivar el firewall, SELinux ni NetworkPolicies como atajo.
