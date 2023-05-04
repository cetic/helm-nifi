#!/bin/bash -x

# Install cmctl per https://cert-manager.io/docs/usage/cmctl/#installation

sudo apt-get update
sudo apt-get install -y golang-go

OS=$(go env GOOS)
ARCH=$(go env GOARCH)

/bin/rm -rf /tmp/cmctl-install
mkdir -p /tmp/cmctl-install

curl -L -o /tmp/cmctl-install/cmctl.tar.gz https://github.com/jetstack/cert-manager/releases/latest/download/cmctl-$OS-$ARCH.tar.gz
(cd /tmp/cmctl-install ; tar xvzf cmctl.tar.gz ; sudo mv cmctl /usr/local/bin)

cmctl experimental install
