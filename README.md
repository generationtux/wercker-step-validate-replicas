# Kubernetes Deployment Replica Validation

Compare the number of expected Kubernetes replicas in the deployment against the number of available replicas.

## Usage

```
- gentux/validate-replicas:
	timeout: [TIMEOUT IN SECONDS]
	app: [metadata.name.labels.app]
	namespace: [KUBERNETES NAMESPACE]
```

## Example

```
- gentux/validate-replicas:
	timeout: 60
	app: qa-products
	namespace: default
```
