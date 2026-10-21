# K3s Metrics Server + firewalld — caso real de diagnóstico (RHEL 9.8)

**Estado:** diagnóstico confirmado en laboratorio; **NO** es una solución endurecida o lista para producción.

## Entorno observado (2026-10-20)

- Host de instalación limpia: SVLNX02, RHEL 9.8, K3s v1.36.5+k3s1, un nodo `Ready`.
- SELinux `Enforcing`, firewalld activo, NGINX activo en 80/443, Traefik y ServiceLB de K3s deshabilitados.
- Nodo `172.16.205.131`; `cni0=10.42.0.1/24`; pod Metrics Server `10.42.0.4` al momento de la prueba (**direcciones del laboratorio; no reutilizar**).
- `ens160` estaba en la zona `public`; `cni0` y `flannel.1` no tenían zona explícita.

## Síntomas y evidencias

- `metrics-server` `0/1 Running`, `v1beta1.metrics.k8s.io=False (MissingEndpoints)`, `kubectl top nodes` no disponible.
- Los logs repetían `Failed to scrape node ... https://172.16.205.131:10250/metrics/resource: ... no route to host`.
- Kubelet escuchaba en TCP/10250. El pod no obtenía métricas, por lo que readiness fallaba con `no metrics to serve`.
- El preflight de PAP devolvía `PAP_PREFLIGHT=BLOCKED` y salida 1; el problema de Metrics API se detectó antes de instalar PAP.

## Pruebas realizadas

1. Una **rich rule de ejecución únicamente**, en zona `public`, que admitía origen `10.42.0.4/32`, destino `172.16.205.131/32`, TCP/10250 **NO** recuperó Metrics Server. El motivo exacto por el que la regla no funcionó no se demostró; se observó que `cni0` carecía de zona asignada.
2. En un **laboratorio de un único nodo**, el administrador asignó **temporalmente** la interfaz `cni0` a `trusted`:

   ```bash
   firewall-cmd --zone=trusted --add-interface=cni0
   ```

   Tras unos 30 segundos, `metrics-server` pasó a `1/1 Running`, `v1beta1.metrics.k8s.io` quedó en `True`, y `k3s kubectl top nodes` mostró CPU y memoria. **Esta prueba demuestra causalidad de filtrado/clasificación de tráfico firewalld, no valida la configuración como política segura.**

3. La regla de prueba quedó **solo en runtime**. `ens160` se mantuvo en `public`, SELinux en `Enforcing` y NGINX activo.

## Cómo verificar (sin modificar)

```bash
k3s kubectl get nodes
k3s kubectl get pods -n kube-system -l k8s-app=metrics-server
k3s kubectl get apiservice v1beta1.metrics.k8s.io
k3s kubectl top nodes
firewall-cmd --get-active-zones
firewall-cmd --get-zone-of-interface=cni0
```

## Reversión de las pruebas en el laboratorio

**Antes de revertir**, registra la política activa y verifica que no dependa de otras cargas. No eliminar reglas administradas por otros equipos.

```bash
firewall-cmd --zone=trusted --remove-interface=cni0
```

La rich rule temporal usada en `public` también debe retirarse por el administrador; su formato exacto depende de la IP que tenía el pod al momento de la prueba. Usar `firewall-cmd --zone=public --list-rich-rules` para encontrarla antes de suprimirla. **No copiar valores IP de este documento a otros entornos.**

## Requisitos para una corrección permanente

- Determinar CIDR real por nodo, interfaces, dirección de tráfico y zonas; registrar reglas efectivas de nftables/firewalld, reglas/NetworkPolicies del CNI y posibles cambios por reinicio de pods.
- Diseñar y probar autorizaciones de **mínimo privilegio** para pod → kubelet TCP/10250, API de Kubernetes, DNS y los flujos pod ↔ pod de PAP. Probar tráfico a IP de pod además de Service; validar cambios después de un reinicio.
- Mantener firewalld y SELinux; no conceder toda la interfaz `cni0` a `trusted` de manera permanente sin análisis de riesgo explícito y aprobación.
- El instalador **no** cambia firewalld automáticamente. Ante `REVIEW_REQUIRED` (código 3), el administrador debe revisar y aprobar la red antes de usar `PAP_NETWORK_APPROVED=yes`. Esa variable no concede permisos ni crea reglas.
- El host de esta prueba tenía 47 GiB provisionados, frente a la recomendación de 60 GiB para laboratorio; capacidad de disco debe evaluarse por separado antes de homologación final.

## Estado final de esta incidencia

Con la **regla temporal**, el preflight avanzó a `PAP_PREFLIGHT=REVIEW_REQUIRED` (`PAP_PREFLIGHT_FAILURES=0`, `PAP_PREFLIGHT_REVIEWS=1`), **no** `PASS`, porque firewalld seguía activo. Esta es la conducta esperada: la conectividad técnica y la aprobación administrativa son controles distintos.

**No tratar esta prueba como receta automática ni como cumplimiento de seguridad de producción.**
