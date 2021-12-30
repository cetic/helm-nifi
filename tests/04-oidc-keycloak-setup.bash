#!/bin/bash -x
#
# Create a realm and user to verify NiFi OIDC support works correctly

# Find the SOCKS5 Proxy into the cluster

S5IP=$(kubectl get node -o json | jq -r '.items[0].status.addresses[] | select(.type=="InternalIP") | .address')
S5PORT=$(kubectl get service socks5 -o json | jq -r '.spec.ports[0].nodePort')

CURL="curl -s --socks5-hostname $S5IP:$S5PORT"

KCURL=http://keycloak.default.svc.cluster.local:8080/auth

# Get a KeyCloak admin token

KCAT=$($CURL \
            -d username=admin \
            -d password=admin \
            -d client_id=admin-cli \
            -d grant_type=password \
            $KCURL/realms/master/protocol/openid-connect/token | \
        jq --raw-output .access_token )

# Create the NiFi Realm

$CURL \
     --request POST $KCURL/admin/realms/ \
     --header "Authorization: Bearer $KCAT" \
     --header "Content-Type: application/json" \
     --data-raw '{ 
                   "realm":"nifi", 
                   "displayName":"NiFi",
                   "enabled":"true" 
                 }'

# Create the NiFi User

$CURL \
     --request POST $KCURL/admin/realms/nifi/users \
     --header "Authorization: Bearer $KCAT" \
     --header "Content-Type: application/json" \
     --data-raw '{ 
                   "firstName":"NiFi",
                   "lastName":"User",
                   "username":"nifi", 
                   "enabled":"true", 
                   "email":"nifi@example.com", 
                   "credentials":[
                                   {
                                      "type":"password",
                                      "value":"reallychangeme",
                                      "temporary":"false"
                                   }
                                 ]
                 }'

$CURL \
     --request POST $KCURL/admin/realms/nifi/clients \
     --header "Authorization: Bearer $KCAT" \
     --header "Content-Type: application/json" \
     --data-raw '{ 
                   "clientId":"nifi", 
                   "enabled":"true", 
                   "redirectUris": [ "https://nifi.default.svc.cluster.local:8443/*" ],
                   "publicClient": "false",
                   "secret":"CZhA1IOePlXHz3PWqVwYoVAcYIUHTcDK"
                 }'