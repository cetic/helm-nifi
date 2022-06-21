#!/bin/bash -x
#
# Create a realm and user to verify NiFi OIDC support works correctly

# Find the SOCKS5 Proxy into the cluster

S5IP=$(kubectl get node -o json | jq -r '.items[0].status.addresses[] | select(.type=="InternalIP") | .address')
S5PORT=$(kubectl get service socks5 -o json | jq -r '.spec.ports[0].nodePort')

CURL="curl -s --socks5-hostname $S5IP:$S5PORT"

# NOTE: Strictly speaking the SOCKS5 cluster could be removed from the test harness
#       by running curl through a kubectl exec in (say) the NiFi server container or
#       directly through a kubectl run using the hub.docker.io/curlimages/curl image.
#       Either way curl would be able to use the fully qualified domain name (FQDN).
#
#       But doing it this way also allows someone debugging OIDC to set their
#       workstation browser to use the SOCKS5 proxy (using the IP address and port
#       discovered through the above kubectl commands, and with remote DNS resolution)
#       to access the NiFi UI as https://nifi.default.svc.cluster.local:8843/nifi/ and
#       confirm it all works--including the FQDN-based redirects from NiFi to Keycloak and 
#       back again.  And it's very useful if (when, really) it doesn't work to have the full 
#       desktop browser debugging and tracing capabilities available.
#
#       Also, while writing the tests it was sure nice having the full browser available 
#       to spelunk through the DOM of the Keycloak and NiFi pages to zero in on what
#       to have puppeteer interact with, both in terms of sending text/clicks and
#       scraping results.

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
                   "enabled":"true",
                   "ssoSessionIdleTimeout":7200,
                   "accessTokenLifespan":3600 
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
                   "redirectUris": [ "https://nifi.default.svc.cluster.local:8443/*", "https://ingress-nginx-controller.ingress-nginx.svc.cluster.local:443/*" ],
                   "publicClient": "false",
                   "secret":"CZhA1IOePlXHz3PWqVwYoVAcYIUHTcDK"
                 }'