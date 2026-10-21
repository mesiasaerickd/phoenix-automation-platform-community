# PAP Event Bridge 0.1.0

Código desarrollado específicamente para Phoenix Automation Platform, bajo Apache License 2.0.

Los dos archivos Python se recuperaron de la imagen pública `pap-operator:dev-20261020` y se transcribieron sin modificaciones de lógica. El módulo publica los hooks `event_handler` y `status_handler` para transportar eventos de Ansible Runner a un socket Unix y receptor HTTP local.

La autoría como componente original de Phoenix fue confirmada por el responsable del proyecto. No es código tomado de AWX.

Esta publicación de fuente y metadatos no altera la imagen ya distribuida; una próxima compilación deberá incorporar estos metadatos y verificar que el paquete instalado declare Apache-2.0.
