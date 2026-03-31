#!/bin/bash
set -e

ENVIRONMENT=${1:-staging}

echo "Bootstrapping $ENVIRONMENT cluster..."

# Create namespaces
echo "Creating namespaces..."
kubectl create ns cert-manager   --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns external-dns   --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns external-secrets --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns istio-system   --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns tailscale      --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns argocd         --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns monitoring     --dry-run=client -o yaml | kubectl apply -f -

echo "Namespaces ready."

# First apply - installs CRDs and base resources
echo "Apply 1/3 - Installing CRDs and base resources..."
kubectl apply -k environments/$ENVIRONMENT/ --server-side --force-conflicts || true

echo "Waiting 30s for CRDs and webhooks to be ready..."
sleep 30

# Second apply - creates resources that depend on CRDs
echo "Apply 2/3 - Creating dependent resources..."
kubectl apply -k environments/$ENVIRONMENT/ --server-side --force-conflicts || true

echo "Waiting 30s for prometheus-operator CRDs..."
sleep 30

# Third apply - final pass
echo "Apply 3/3 - Final pass..."
kubectl apply -k environments/$ENVIRONMENT/ --server-side --force-conflicts

echo "Bootstrap complete for $ENVIRONMENT!"
echo ""
echo "Next steps:"
echo "  1. Create aws-sm-credentials secret in external-secrets namespace"
echo "  2. Restart external-secrets: kubectl rollout restart deploy external-secrets -n external-secrets"
echo "  3. Watch pods: kubectl get pods -A -w"
