#!/usr/bin/env bash
set -euo pipefail

kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release-full.yaml

kubectl wait --for=condition=available --timeout=240s deployment -n tekton-pipelines --all
kubectl wait --for=condition=available --timeout=240s deployment -n tekton-triggers --all
kubectl wait --for=condition=available --timeout=240s deployment -n tekton-dashboard --all

echo "Tekton Pipelines, Triggers, and Dashboard are installed."
