#!/bin/bash -x
kubectl apply -f https://github.com/spoditor/spoditor/releases/download/v0.1.1/bundle.yaml
kubectl -n spoditor-system wait deployment/spoditor-controller-manager --for=condition=Available --timeout=5m