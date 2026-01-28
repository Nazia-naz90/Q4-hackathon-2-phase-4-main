#!/bin/bash
# Verification script for Todo Application Kubernetes deployment

echo "Verifying Todo Application deployment..."

# Check deployments
echo "Checking deployments..."
DEPLOYMENTS=$(kubectl get deployments --output=name)
if [ -z "$DEPLOYMENTS" ]; then
    echo "❌ No deployments found"
else
    echo "✅ Deployments found:"
    echo "$DEPLOYMENTS"

    # Check if all deployments are ready
    for deployment in $DEPLOYMENTS; do
        NAME=$(basename $deployment)
        READY_REPLICAS=$(kubectl get $deployment -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
        DESIRED_REPLICAS=$(kubectl get $deployment -o jsonpath='{.spec.replicas}' 2>/dev/null)

        if [ "$READY_REPLICAS" = "$DESIRED_REPLICAS" ] && [ "$READY_REPLICAS" != "0" ] 2>/dev/null; then
            echo "✅ $NAME: $READY_REPLICAS/$DESIRED_REPLICAS replicas ready"
        else
            echo "❌ $NAME: Only $READY_REPLICAS/$DESIRED_REPLICAS replicas ready (or error checking status)"
        fi
    done
fi

# Check services
echo "Checking services..."
SERVICES=$(kubectl get services --output=name)
if [ -z "$SERVICES" ]; then
    echo "❌ No services found"
else
    echo "✅ Services found:"
    echo "$SERVICES"
fi

# Check pods
echo "Checking pods..."
PODS=$(kubectl get pods --output=name)
if [ -z "$PODS" ]; then
    echo "❌ No pods found"
else
    echo "✅ Pods found:"
    echo "$PODS"

    # Check pod statuses
    for pod in $PODS; do
        STATUS=$(kubectl get $pod -o jsonpath='{.status.phase}' 2>/dev/null)
        if [ "$STATUS" = "Running" ] 2>/dev/null; then
            echo "✅ $pod: $STATUS"
        else
            echo "❌ $pod: $STATUS"
        fi
    done
fi

# Check logs for errors (only if pods exist)
if [ -n "$PODS" ]; then
    echo "Checking for errors in logs..."
    for pod in $PODS; do
        # Check for recent error messages in logs
        ERROR_LOGS=$(kubectl logs $pod --since=5m 2>/dev/null | grep -i -E "(error|exception|fail)" || true)
        if [ -n "$ERROR_LOGS" ]; then
            echo "⚠️  Potential errors found in $pod:"
            echo "$ERROR_LOGS"
        else
            echo "✅ No recent errors found in $pod"
        fi
    done
fi

echo ""
echo "Verification complete!"
echo ""
echo "To access the frontend service:"
echo "minikube service todo-frontend --url"
echo ""
echo "To check all resources:"
echo "kubectl get all"