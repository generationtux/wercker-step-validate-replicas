# Validate Replicas 

A public step for use with Wercker CI that will validate that all replicas are available.

	- validate-replicas:
		timeout: [SECONDS_TO_TIMEOUT]
		app: [SERVICE_NAME]
		namespace: [KUBECTL_NAMESPACE]
		
### Description
```timeout:```

Default: default. Namespace where the deployment lives. E.g. prod or default.

```app:```

The value of metadata.labels.app from the deployment config. E.g. prod-products or qa-products.

```namespace:```

Default: default. Namespace where the deployment lives. E.g. prod or default.

### Example

Say the Hurdy service is using kubenetes replicas and you are in a deploy to production pipeline.


	- validate-replicas:
		timeout: 120
		app: prod-accounts
		namespace: prod
