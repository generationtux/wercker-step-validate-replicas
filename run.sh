#!/bin/bash
#
# Compare the number of expected replicas in the deployment against the number
# of available replicas.
#
# Arguments:
#   app         The value of metadata.labels.app from the deployment config. E.g. prod-products or qa-products.
#   namespace   Default: default. Namespace where the deployment lives. E.g. prod or default.
#
# Usage:
#   ./deploy/lib/scripts/kubectl-replica-check.sh qa-products
#   ./deploy/lib/scripts/kubectl-replica-check.sh prod-products prod



if [ $(which kubectl 2>/dev/null | grep -v "not found" | wc -l) -eq 0 ] ; then
    echo "kubectl is not installed" &&
    exit 1
fi

info "kubectl is installed"

TIMEOUT_FLAG=0

while : ; do
    if [ TIMEOUT_FLAG -eq $WERCKER_VALIDATE_REPLICAS_TIMEOUT ] ; then
        break
    fi

    REPLICAS="$(kubectl get -o jsonpath='{.items[0].status.replicas}' deployments --selector=app=$WERCKER_VALIDATE_REPLICAS_APP --namespace=$WERCKER_VALIDATE_REPLICAS_NAMESPACE:-default)"
    AVAILABLE_REPLICAS="$(kubectl get -o jsonpath='{.items[0].status.availableReplicas}' deployments --selector=app=$WERCKER_VALIDATE_REPLICAS_APP --namespace=$WERCKER_VALIDATE_REPLICAS_NAMESPACE:-default)"

    echo "Expected replicas: $REPLICAS, Available replicas: $AVAILABLE_REPLICAS"
    ((TIMEOUT_FLAG++))

    [[ $REPLICAS -ne $AVAILABLE_REPLICAS ]] || break
done

exit 0

