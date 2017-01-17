#!/bin/bash
#
# Compare the number of expected replicas in the deployment against the number
# of available replicas.
#
# Arguments:
#   timeout     Seconds. How long should we wait for the replicas to be available.
#   app         The value of metadata.labels.app from the deployment config. E.g. prod-products or qa-products.
#   namespace   Default: default. Namespace where the deployment lives. E.g. prod or default.
#
# Usage:
#
#    - gentux/validate-replicas:
#        timeout: 120
#        app: staging-products
#        namespace: staging

if [ $(which kubectl 2>/dev/null | grep -v "not found" | wc -l) -eq 0 ] ; then
    echo "kubectl is not installed" &&
    exit 1
fi

TIMEOUT_FLAG=0

while : ; do
    sleep .5

    if [ $TIMEOUT_FLAG -eq $WERCKER_VALIDATE_REPLICAS_TIMEOUT ] ; then
        echo "Kubernetes replica check failed."
        echo "Expected replicas: $REPLICAS, Available replicas: $AVAILABLE_REPLICAS"
        exit 1
    fi

    REPLICAS="$(kubectl get -o jsonpath='{.items[0].status.replicas}' deployments --selector=app=$WERCKER_VALIDATE_REPLICAS_APP --namespace=${WERCKER_VALIDATE_REPLICAS_NAMESPACE:-default})"
    AVAILABLE_REPLICAS="$(kubectl get -o jsonpath='{.items[0].status.availableReplicas}' deployments --selector=app=$WERCKER_VALIDATE_REPLICAS_APP --namespace=${WERCKER_VALIDATE_REPLICAS_NAMESPACE:-default})"

    ((TIMEOUT_FLAG++))

    echo "Expected replicas: $REPLICAS, Available replicas: $AVAILABLE_REPLICAS"
    echo "Timeout $TIMEOUT_FLAG"

    [[ $REPLICAS -ne $AVAILABLE_REPLICAS ]] || break
done

echo "Expected replicas: $REPLICAS, Available replicas: $AVAILABLE_REPLICAS"
exit 0
