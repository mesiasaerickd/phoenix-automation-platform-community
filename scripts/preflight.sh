#!/usr/bin/env bash
# PAP network/security preflight. Read-only; no host firewall changes.
set -uo pipefail
NAMESPACE="${1:-pap-acceptance}"
MODE="${2:-pre}" # pre|post
[[ "$MODE" == pre || "$MODE" == post ]] || { echo "Usage: $0 [namespace] [pre|post]"; exit 2; }
command -v python3 >/dev/null || { echo "BLOCKED: python3 missing"; exit 2; }
if command -v k3s >/dev/null; then K=(k3s kubectl)
elif command -v kubectl >/dev/null; then K=(kubectl)
else echo "BLOCKED: Kubernetes CLI missing"; exit 2; fi
umask 077
REPORT_DIR="${PAP_EVIDENCE_DIR:-/tmp/pap-preflight}"
mkdir -p "$REPORT_DIR" || exit 2
REPORT="$REPORT_DIR/preflight-${MODE}-$(date -u +%Y%m%dT%H%M%SZ).log"
exec > >(tee "$REPORT") 2>&1
fails=0
warns=0
fail() { echo "BLOCKED: $*"; fails=$((fails+1)); }
warn() { echo "REVIEW: $*"; warns=$((warns+1)); }
pass() { echo "PASS: $*"; }
echo "PAP preflight mode=$MODE namespace=$NAMESPACE timestamp=$(date -u +%FT%TZ)"
echo "No commands in this check modify firewall, SELinux, Kubernetes or deployments."
if "${K[@]}" get --raw=/readyz >/dev/null 2>&1; then pass "Kubernetes API ready"; else fail "Kubernetes API not ready"; fi
nodes=$("${K[@]}" get nodes -o json 2>/dev/null) || nodes=""
if [[ -z "$nodes" ]]; then fail "Cannot read Kubernetes nodes"; else
  printf '%s' "$nodes" | python3 -c '
import json,sys
data=json.load(sys.stdin)
for n in data.get("items",[]):
  c={x["type"]:x["status"] for x in n.get("status",{}).get("conditions",[])}
  print("NODE status=%s podCIDRs=%s"%(c.get("Ready","unknown"),",".join(n.get("spec",{}).get("podCIDRs",[]) or [n.get("spec",{}).get("podCIDR","unknown")])))
' || fail "Cannot parse node topology"
  if printf '%s' "$nodes" | python3 -c 'import json,sys; d=json.load(sys.stdin)["items"]; assert d and all(any(c["type"]=="Ready" and c["status"]=="True" for c in n["status"]["conditions"]) for n in d)'; then pass "All nodes Ready"; else fail "One or more nodes NotReady"; fi
fi
# Capacity gate: read-only, single-node acceptance profile (4 vCPU, 8 GiB allocatable).
# Report all nodes because the control-plane can share the host with unrelated workloads.
echo "=== Kubernetes node allocatable capacity ==="
if [[ -n "${nodes:-}" ]]; then
  if printf '%s' "$nodes" | python3 -c '
import json, sys
from decimal import Decimal
nodes=json.load(sys.stdin).get("items", [])
for node in nodes:
    n=node.get("metadata",{}).get("name","unknown")
    a=node.get("status",{}).get("allocatable",{})
    cpu=str(a.get("cpu","0"))
    cpu_cores=Decimal(cpu[:-1])/1000 if cpu.endswith("m") else Decimal(cpu)
    mem=str(a.get("memory","0"))
    units={"Ki":1024,"Mi":1024**2,"Gi":1024**3,"Ti":1024**4}
    k=next((u for u in units if mem.endswith(u)),None)
    mem_bytes=Decimal(mem[:-len(k)])*units[k] if k else Decimal(mem)
    gib=mem_bytes/Decimal(1024**3)
    print("NODE_CAPACITY name=%s allocatable_cpu=%s allocatable_ram_gib=%.2f"%(n,cpu,gib))
    if cpu_cores<4 or gib<8:
        print("CAPACITY_REVIEW: below PAP laboratory minimum (4 allocatable vCPU / 8 GiB); production initial target is 8 vCPU / 16 GiB")
' ; then pass "Kubernetes node allocatable capacity inspected"; else warn "Cannot inspect allocatable CPU/RAM"; fi
else
  warn "Node capacity unavailable"
fi
if command -v df >/dev/null 2>&1; then
  echo "HOST_DISK_AVAILABLE:"
  df -h / /var/lib/rancher/k3s 2>/dev/null || df -h / || true
  echo "CAPACITY_NOTE=Lab minimum 60GiB provisioned; production initial 100GiB provisioned. Verify underlying volumes separately."
fi
# Optional Metrics API: if registered, it must be discoverable. An unhealthy
# aggregated API breaks Ansible Operator discovery, even for core Secret objects.
echo "=== Aggregated API discovery ==="
metrics_registered=$("${K[@]}" get apiservice v1beta1.metrics.k8s.io -o json 2>/dev/null) || metrics_registered=""
if [[ -z "$metrics_registered" ]]; then
  echo "METRICS_APISERVICE=NOT_REGISTERED (no requirement to install metrics-server)"
else
  if printf '%s' "$metrics_registered" | python3 -c '
import json,sys
obj=json.load(sys.stdin)
conditions=obj.get("status",{}).get("conditions",[])
healthy=any(c.get("type")=="Available" and c.get("status")=="True" for c in conditions)
print("METRICS_APISERVICE="+("AVAILABLE" if healthy else "UNAVAILABLE"))
sys.exit(0 if healthy else 1)
'; then
    if "${K[@]}" get --raw=/apis/metrics.k8s.io/v1beta1 >/dev/null 2>&1; then
      pass "Registered Metrics API discovery available"
    else
      fail "Registered metrics.k8s.io discovery unavailable; repair Kubernetes aggregation before installing PAP"
    fi
  else
    fail "Registered metrics.k8s.io APIService unhealthy; inspect metrics-server and kubelet routing (TCP/10250)"
  fi
fi
if "${K[@]}" get crd awxs.awx.ansible.com >/dev/null 2>&1 && [[ "$MODE" == pre ]]; then fail "Existing AWX CRD: installer would collide; assess compatibility"; fi
if "${K[@]}" get namespace "$NAMESPACE" >/dev/null 2>&1 && [[ "$MODE" == pre ]]; then fail "Namespace already exists; new install blocked"; fi
echo "=== Host security and network ==="
if command -v getenforce >/dev/null 2>&1; then
  se=$(getenforce 2>/dev/null || echo unknown); echo "SELinux=$se"
  [[ "$se" == Enforcing ]] || warn "SELinux not Enforcing; obtain platform security approval"
else warn "SELinux status unavailable"; fi
if command -v sysctl >/dev/null 2>&1; then
  fw=$(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo unknown); echo "IPv4 forwarding=$fw"
  [[ "$fw" == 1 ]] || fail "IPv4 forwarding disabled: review CNI prerequisites"
fi
if command -v firewall-cmd >/dev/null 2>&1; then
  if firewall-cmd --state >/dev/null 2>&1; then
    echo "firewalld=active"
    firewall-cmd --get-active-zones 2>/dev/null || true
    firewall-cmd --get-policies 2>/dev/null || true
    warn "firewalld active: verify forward-path permissions for Pod CIDRs, not just Service IPs; administrator must approve minimal rule"
  else echo "firewalld=inactive"; fi
else echo "firewalld=not-installed"; fi
for x in cni0 flannel.1; do
  if command -v ip >/dev/null && ip link show "$x" >/dev/null 2>&1; then
    echo "CNI_INTERFACE=$x present"
  fi
done
if [[ "$MODE" == pre ]]; then
  echo "POD_TO_POD=DEFERRED (pods not yet installed)"
  echo "POST_INSTALL_REQUIRED: rerun $0 $NAMESPACE post and launch real PAP Job Template"
else
  echo "=== PAP pod/Service probe ==="
  task=$("${K[@]}" get pods -n "$NAMESPACE" -o json 2>/dev/null | python3 -c '
import json,sys
d=json.load(sys.stdin)
a=[p for p in d.get("items",[]) if p["metadata"]["name"].startswith("pap-") and "-task-" in p["metadata"]["name"] and p.get("status",{}).get("phase")=="Running"]
print(a[0]["metadata"]["name"] if a else "")
' 2>/dev/null) || task=""
  web=$("${K[@]}" get pods -n "$NAMESPACE" -o json 2>/dev/null | python3 -c '
import json,sys
d=json.load(sys.stdin)
a=[p for p in d.get("items",[]) if p["metadata"]["name"].startswith("pap-") and "-web-" in p["metadata"]["name"] and p.get("status",{}).get("phase")=="Running"]
print(a[0].get("status",{}).get("podIP","") if a else "")
' 2>/dev/null) || web=""
  if [[ -z "$task" || -z "$web" ]]; then fail "PAP Task/Web pods unavailable for direct probe"; else
    echo "TASK=$task WEB_POD_IP=$web"
    if "${K[@]}" exec -n "$NAMESPACE" "$task" -c pap-security-task -- python3 -c '
import socket,sys
host=sys.argv[1]
tests=[(host,8052),("pap-security-service",80)]
failed=False
for h,p in tests:
 try:
  with socket.create_connection((h,p),timeout=5): print("PASS CONNECT %s:%s"%(h,p))
 except Exception as e:
  print("BLOCKED CONNECT %s:%s %s"%(h,p,e));failed=True
sys.exit(1 if failed else 0)
' "$web"; then pass "Pod IP and service connectivity"; else fail "Task -> Web TCP/8052 direct or Service/80 blocked. Review firewalld forwarding and NetworkPolicies; do not disable security controls."; fi
  fi
  echo "NETWORKPOLICIES:"
  "${K[@]}" get networkpolicy -n "$NAMESPACE" -o name 2>/dev/null || warn "NetworkPolicy listing unavailable"
fi
echo "=== Suggested remediation (NOT EXECUTED) ==="
echo "Review actual Pod CIDRs and firewalld forward chain; permit only approved internal Task->Web TCP/8052, DNS TCP/UDP 53 and Web/Task->DB TCP/5432 as needed."
echo "Document change ticket and rollback of each approved rule. Never copy test-node CIDR, disable firewalld/SELinux or open overlay ports publicly."
echo "EVIDENCE=$REPORT"
echo "PAP_PREFLIGHT_FAILURES=$fails PAP_PREFLIGHT_REVIEWS=$warns"
if (( fails > 0 )); then echo "PAP_PREFLIGHT=BLOCKED"; exit 1; fi
if (( warns > 0 )); then
  echo "PAP_PREFLIGHT=REVIEW_REQUIRED"
  if [[ "$MODE" == pre && "${PAP_NETWORK_APPROVED:-no}" != yes ]]; then
    echo "BLOCKED: administrator review required. After approval only, rerun with PAP_NETWORK_APPROVED=yes (no firewall rules will be changed)."
    exit 3
  fi
else echo "PAP_PREFLIGHT=PASS"; fi
