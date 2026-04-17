#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="tekton-lab"
REGISTRY_NAME="kind-registry"
REGISTRY_PORT="5001"

if ! command -v kind >/dev/null 2>&1; then
  echo "kind is required but not installed."
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required but not installed."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required but not installed."
  exit 1
fi

running="$(docker inspect -f '{{.State.Running}}' "${REGISTRY_NAME}" 2>/dev/null || true)"
if [[ "${running}" != "true" ]]; then
  docker run -d --restart=always -p "127.0.0.1:${REGISTRY_PORT}:5000" --name "${REGISTRY_NAME}" registry:2
fi

if kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "KIND cluster '${CLUSTER_NAME}' already exists. Skipping creation."
else
  kind create cluster --name "${CLUSTER_NAME}" --config kind/cluster-config.yaml
fi

docker network connect "kind" "${REGISTRY_NAME}" 2>/dev/null || true

kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${REGISTRY_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

echo "KIND cluster '${CLUSTER_NAME}' is ready."
echo "Local registry is available at localhost:${REGISTRY_PORT}."
