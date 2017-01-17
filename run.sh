#!/bin/bash

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

    [[ $REPLICAS -ne $AVAILABLE_REPLICAS ]] || break
done

success "Expected replicas: $REPLICAS, Available replicas: $AVAILABLE_REPLICAS"
