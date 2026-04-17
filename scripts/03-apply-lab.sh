#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f tekton/00-namespace.yaml
kubectl apply -f tekton/01-rbac.yaml
kubectl apply -f tekton/02-pvc.yaml
kubectl apply -f tekton/10-tasks.yaml
kubectl apply -f tekton/20-pipeline.yaml

echo "Tekton lab resources have been applied."
