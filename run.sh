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
    fail "kubectl is not installed"
fi

TIMEOUT_FLAG=0

while : ; do
    sleep .5

    if [ $TIMEOUT_FLAG -eq $WERCKER_VALIDATE_REPLICAS_TIMEOUT ] ; then
        info "Kubernetes replica check failed."
        fail "Expected replicas: $REPLICAS, Available replicas: $AVAILABLE_REPLICAS"
    fi

    REPLICAS="$(kubectl get -o jsonpath='{.items[0].status.replicas}' deployments --selector=app=$WERCKER_VALIDATE_REPLICAS_APP --namespace=${WERCKER_VALIDATE_REPLICAS_NAMESPACE:-default})"
    AVAILABLE_REPLICAS="$(kubectl get -o jsonpath='{.items[0].status.availableReplicas}' deployments --selector=app=$WERCKER_VALIDATE_REPLICAS_APP --namespace=${WERCKER_VALIDATE_REPLICAS_NAMESPACE:-default})"

    ((TIMEOUT_FLAG++))

    info "Expected replicas: $REPLICAS, Available replicas: $AVAILABLE_REPLICAS"
    info "Timeout $TIMEOUT_FLAG"

    [[ $REPLICAS -ne $AVAILABLE_REPLICAS ]] || break
done

success "Expected replicas: $REPLICAS, Available replicas: $AVAILABLE_REPLICAS"
