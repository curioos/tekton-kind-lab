# Tekton Practice Lab on KIND

This folder is a hands-on lab to practice Tekton implementation on a local KIND cluster.

## What you will practice

- Create a local Kubernetes cluster with KIND
- Create and use a local container registry with KIND
- Install Tekton Pipelines, Triggers, and Dashboard
- Define custom Tekton Tasks and a Pipeline
- Run a PipelineRun to clone code, run tests, and build an image with Kaniko

## Lab structure

- `kind/cluster-config.yaml`: KIND cluster config with local-registry mirror
- `scripts/01-create-kind.sh`: creates KIND cluster and local registry
- `scripts/02-install-tekton.sh`: installs Tekton components
- `scripts/03-apply-lab.sh`: applies namespace, pvc, tasks, and pipeline
- `tekton/`: Tekton manifests
- `app/`: sample Python app used by pipeline

## Prerequisites

- Docker
- kind
- kubectl
- Optional: `tkn` CLI for easier Tekton commands

## 1) Create KIND and local registry

From this folder (`k8s/prj-1`):

```bash
chmod +x scripts/*.sh
./scripts/01-create-kind.sh
kubectl cluster-info --context kind-tekton-lab
```

## 2) Install Tekton

```bash
./scripts/02-install-tekton.sh
kubectl get pods -n tekton-pipelines
kubectl get pods -n tekton-triggers
kubectl get pods -n tekton-dashboard
```

## 3) Apply Tekton lab resources

```bash
./scripts/03-apply-lab.sh
kubectl get task,pipeline -n tekton-lab
```

## 4) Push this repo to your GitHub (required for clone step)

The provided PipelineRun clones from GitHub. Update `tekton/30-pipelinerun.yaml`:

- Replace `repo-url` with your repo URL
- Keep `subdirectory` as `k8s/prj-1/app` if this layout is unchanged

Example:

```yaml
- name: repo-url
	value: https://github.com/<your-user>/devops.git
```

## 5) Start a pipeline run

```bash
kubectl apply -f tekton/30-pipelinerun.yaml
kubectl get pipelineruns -n tekton-lab
kubectl get taskruns -n tekton-lab
```

Follow logs (without `tkn`):

```bash
RUN_NAME=$(kubectl get pipelinerun -n tekton-lab -o jsonpath='{.items[-1:].metadata.name}')
kubectl describe pipelinerun "$RUN_NAME" -n tekton-lab
kubectl get taskrun -n tekton-lab
```

If you installed `tkn`:

```bash
tkn pipelinerun logs -f -n tekton-lab
```

## 6) Validate built image in local registry

```bash
curl -s http://localhost:5001/v2/_catalog | jq .
curl -s http://localhost:5001/v2/tekton-lab/python-app/tags/list | jq .
```

If `jq` is not installed, remove `| jq .`.

## Suggested practice exercises

1. Break tests intentionally in `app/test_main.py` and verify pipeline fails.
2. Add a lint Task before tests and enforce it with `runAfter`.
3. Add a second Pipeline parameter for image tag and use commit SHA.
4. Add a TriggerTemplate + EventListener to trigger pipeline by webhook.
5. Add retries/timeouts for Tasks and observe behavior.

## Troubleshooting

- Pipeline stuck in Pending:
	- Check PVC: `kubectl get pvc -n tekton-lab`
- Kaniko cannot push image:
	- Confirm local registry container is running: `docker ps | grep kind-registry`
	- Confirm KIND mirror settings in `kind/cluster-config.yaml`
- Git clone fails:
	- Verify `repo-url`, `revision`, and `subdirectory` values in `tekton/30-pipelinerun.yaml`

## Cleanup

```bash
kind delete cluster --name tekton-lab
docker rm -f kind-registry
```
