# PAP Requirements

Full deployment requires Kubernetes or K3s. Docker and Podman are image tools, not supported PAP deployment orchestrators. Cluster isolation, storage, networking, CPU and RAM must be validated. No general production sizing certified. Do not use existing AWX CRDs without assessing compatibility.


## Red y firewall — requisito previo obligatorio

Consultar [NETWORKING.md](NETWORKING.md) para la matriz de flujos, responsabilidades del administrador y del instalador, requisitos de K3s/CNI, autorización de firewalld, pruebas directas pod a pod, DNS, SELinux y criterios de bloqueo seguro. **El instalador debe diagnosticar y detenerse ante bloqueos, no aplicar cambios de host silenciosamente.** Los CIDR y las reglas del laboratorio NODO de prueba no son valores por defecto para nuevas instalaciones.
