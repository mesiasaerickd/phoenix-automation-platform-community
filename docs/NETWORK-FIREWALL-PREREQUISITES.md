# PAP Phoenix RC2 — Red, firewalld y NetworkPolicy

> Estado: guía para administradores; **no** es una receta universal ni una aprobación de seguridad. La red debe validarse para cada versión de sistema operativo, CNI y topología Kubernetes. No usar reglas copiadas de otros clústeres.

## Responsabilidades

- **Instalador PAP:** realizar comprobaciones de solo lectura y mostrar claramente los bloqueos; nunca deshabilitar firewalld o SELinux, abrir puertos externos o alterar reglas de red sin autorización.
- **Administrador de infraestructura:** aprobar y aplicar los cambios de red persistentes de acuerdo con las políticas locales, registrar el alcance, verificar la conectividad y documentar el rollback.
- **Operador de PAP:** ejecutar el preflight antes y después de la instalación, comprobar API, base de datos, Task, Web y un Job real.

La variable `PAP_NETWORK_APPROVED=yes` representa una aprobación administrativa del entorno; **no** repara la conectividad ni certifica la seguridad.

## Flujos que deben comprobarse

| Origen | Destino | Protocolo | Necesidad | Notas |
| --- | --- | --- | --- | --- |
| Metrics Server (Pod) | Kubelet del nodo | TCP/10250 | Métricas de Kubernetes | Restringir al origen interno autorizado; no abrir a Internet |
| Task/Web (Pods) | PostgreSQL (Pod/Service) | TCP/5432 | Acceso a la base de datos | Solo los componentes autorizados por NetworkPolicy |
| Pods autorizados | CoreDNS | UDP/TCP 53 | Resolución DNS | Validar resolución y Service IP |
| Task | Web/API interna | TCP/8052, según manifiesto | Operación interna | Verificar puertos y selectores de la versión desplegada |
| Nodos K3s | API/control plane y red CNI | Según topología | Kubernetes | Puertos adicionales varían con backend CNI y número de nodos |

El tráfico puede atravesar reglas de **firewalld**, nftables y **Kubernetes NetworkPolicy**. Un contenedor `Running` o un Service existente no prueban conectividad efectiva. Las políticas de denegación predeterminada requieren permitir explícitamente los flujos indispensables.

## Diagnóstico de solo lectura

```bash
kubectl get nodes -o wide
kubectl get pods,svc,endpointslices,networkpolicy -n <namespace>
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl get events -n <namespace> --sort-by=.lastTimestamp
firewall-cmd --get-active-zones
firewall-cmd --get-policies
firewall-cmd --list-all-policies
ip -br addr
ip route
```

Complementar con logs del contenedor Web/Task y un test de conectividad desde el **Pod origen** hacia el servicio/IP destino, con el puerto efectivo. Revisar selectores de `NetworkPolicy` y contadores de rechazo antes de atribuir el fallo a firewalld.

## Hallazgos de aceptación RC2 — laboratorio SVLNX01 (2026-10-19)

**Resultado funcional comprobado:** con firewalld detenido, el test TCP desde Control Plane EE hacia PostgreSQL cambió de `No route to host` a conexión exitosa y se recuperaron Task 4/4, Web 3/3 y API HTTP 200. Esta comparación confirma que firewalld impedía el tráfico interno en ese laboratorio; los mecanismos precisos de evaluación por cadena no se validaron mediante nft trace.

**Configuración de laboratorio aplicada:** se creó una zona permanente `k3s-internal`, se asociaron las interfaces `cni0` y `flannel.1` y se configuró `target=ACCEPT`. La zona externa `public` permaneció asociada a `ens160`. Tras reactivar firewalld, se verificaron TCP 5432 Pod → Pod, API HTTP 200 y servicios Task/Web/operador en estado Ready; firewalld quedó `active` y `enabled`.

**Advertencia de seguridad:** `target=ACCEPT` sobre interfaces CNI es una **excepción amplia del laboratorio**, no una aprobación para producción. Los cinco objetos `NetworkPolicy` estaban presentes, pero **no se realizaron pruebas negativas de aislamiento**, ni se certificó mínimo privilegio. Antes de promover la configuración de red a producción, revisar alcance, tráfico permitido, enforcement de NetworkPolicy, firewalld, reglas nftables y rollback. No copiar sin validar topología, CIDR ni interfaces.

**SELinux:** en el laboratorio se observó `Permissive`; todavía **no está validado Enforcing**. No documentar la plataforma como endurecida o aceptada en seguridad de producción hasta completar esa validación.

**Aplicación y Jobs:** migración 24.6.1 Complete 1/1; API HTTP 200; Control Plane EE UID 1001; Receptor con proceso y socket disponibles; el operador reconoció los EE Control Plane y PAP EE Core. El operador del laboratorio reportó dos Jobs exitosos utilizando EE personalizados, incluido uno externo basado en AlmaLinux y construido con Podman. La ejecución de EE locales desde K3s requirió importar imágenes a containerd y seleccionar una política de extracción que no intente descargarlas del registro. Esta comprobación no reemplaza pruebas de instalación multinodo, carga ni seguridad.

## Criterios de aceptación de red

1. K3s/Kubernetes Ready; CoreDNS y métricas disponibles.
2. Task y Web conectan a PostgreSQL con reglas de mínimo privilegio verificadas.
3. La API PAP responde y los Jobs terminan con los Execution Environments previstos.
4. Firewalld sigue activo; SELinux Enforcing se valida antes de producción y se revisan AVC.
5. Cada excepción tiene justificación, alcance (origen/destino/puerto), aprobación, persistencia probada y rollback.

**No recomendado:** `systemctl stop firewalld`, `setenforce 0` como solución permanente, asignar toda la red de Pods a una zona `trusted` sin revisión, abrir PostgreSQL a la LAN, o usar IPs de Pods efímeras en reglas persistentes.

## Referencias del proyecto

- `scripts/preflight.sh`
- `docs/CAPACITY-PREREQUISITES.md`
- Manifiestos `k8s/` y NetworkPolicies generadas por el operador

Los nombres e IP concretos del laboratorio se omiten intencionalmente para mantener esta guía portable.
