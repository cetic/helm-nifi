#!/bin/bash -x

# Create a pair of namespaces and secure NiFi instances

for ns in alpha bravo; 
do 
  sed -e 's/^    //' << ENDOFYAML | kubectl apply -f -
    ---
    apiVersion: v1
    kind: Namespace
    metadata:
      name: $ns
    ---
ENDOFYAML
  kubectl -n $ns create --dry-run=client configmap flow-xml --from-file=tests/06-$ns.flow.xml -o yaml | kubectl apply -f -
done

# Install NiFi expecting secrets:

helm -n alpha install nifi . \
  --set zookeeper.enabled=false \
  --set properties.isNode=false \
  --set properties.webProxyHost=nifi.alpha.svc.cluster.local:8443 \
  --set replicaCount=1 \
  --set registry.enabled=false \
  --set certManager.enabled=true \
  --set configmaps[0].name=flow-xml \
  --set configmaps[0].mountPath=/opt/nifi/flow-xml \
  --set customFlow=/opt/nifi/flow-xml/06-alpha.flow.xml \
  --set certManager.caDuration=1h \
  --set certManager.refreshSeconds=30 \
  --set 'certManager.caSecrets[0]=bravo-ca'

helm -n bravo install nifi . \
  --set zookeeper.enabled=false \
  --set properties.isNode=false \
  --set properties.webProxyHost=nifi.bravo.svc.cluster.local:8443 \
  --set replicaCount=1 \
  --set registry.enabled=false \
  --set certManager.enabled=true \
  --set configmaps[0].name=flow-xml \
  --set configmaps[0].mountPath=/opt/nifi/flow-xml \
  --set customFlow=/opt/nifi/flow-xml/06-bravo.flow.xml \
  --set certManager.caDuration=1h \
  --set certManager.refreshSeconds=30 \
  --set 'certManager.caSecrets[0]=alpha-ca'

# Copy certificate authorities from one namespace to the other

kubectl -n alpha wait --for=condition=Ready=true certificate/nifi-ca --timeout=60s
kubectl -n alpha get secret nifi-ca -o json | \
  jq 'del(.metadata)|del(.data."tls.crt")|del(.data."tls.key") + { metadata: { name: "alpha-ca" } } + { type: "kubernetes.io/generic" }' | \
  kubectl -n bravo apply -f -

kubectl -n bravo wait --for=condition=Ready=true certificate/nifi-ca --timeout=60s
kubectl -n bravo get secret nifi-ca -o json | \
  jq 'del(.metadata)|del(.data."tls.crt")|del(.data."tls.key") + { metadata: { name: "bravo-ca" } } + { type: "kubernetes.io/generic" }' | \
  kubectl -n alpha apply -f -
  
