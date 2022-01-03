#!/bin/bash -x

# Install cmctl per https://cert-manager.io/docs/usage/cmctl/#installation

OS=$(docker run --rm golang:1.16-alpine go env GOOS)
ARCH=$(docker run --rm golang:1.16-alpine go env GOARCH)

/bin/rm -rf /tmp/cmctl-install
mkdir -p /tmp/cmctl-install

curl -L -o /tmp/cmctl-install/cmctl.tar.gz https://github.com/jetstack/cert-manager/releases/latest/download/cmctl-$OS-$ARCH.tar.gz
(cd /tmp/cmctl-install ; tar xvzf cmctl.tar.gz ; sudo mv cmctl /usr/local/bin)

cmctl experimental install
kubectl wait deployment/cert-manager --for=condition=Available --timeout=5m
kubectl wait deployment/cert-manager-cainjector --for=condition=Available --timeout=5m
kubectl wait deployment/cert-manager-webhook --for=condition=Available --timeout=5m
