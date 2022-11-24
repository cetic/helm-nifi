# User Authentication

This helm chart provides four types of authentication: Single User, Client Certificate, LDAP, and OIDC. These four authentication types can be managed essentialy from the `values.yaml` file.

The parameter `admin` will set the initial admin username. If used in conjunction with an enabled LDAP configuration, this value will get used instead of the LDAP Bind DN for the admin username.

## 1. Single User

The Single User authentication is the default authentication in this helm chart. To login like a single user, the values below must be set in `values.yaml` file:

```
singleUser:
    username: username
    password: changemechangeme
```

## 2. Client Certificate

Client Certificate authentication assumes a central Certificate Authority (CA) will issue a Client PKI Certificate and Server Certificate for the Nifi server.

Add keystore files to a Kubernetes secret:

```
kubectl create secret generic mysecrets \
--from-file=keystore.jks=/path/to/keystore.jks \
--from-file=truststore.jks=/path/to/truststore.jks
```

Make the Kubernetes secret available to the Nifi server. Update `values.yaml`:

```
secrets:
- name: mysecrets
  keys:
    - keystore.jks
    - truststore.jks
  mountPath: /opt/nifi/nifi-current/config-data/certs/
```

Enable the Nifi server to prompt for client certificates:

```
properties:
   needClientAuth: true
```

Indicate Client Authentication mode configurations should be applied and set SSL values:

```
auth:
   SSL:
     keystorePasswd: <passwd>
     truststorePasswd: <passwd>
   clientAuth:
     enabled: true
```

For cluster deployments, the example below illustrates how to create a 3 replica cluster with unique keystores.

Create the secret:

```
kubectl create secret generic mysecrets \
--from-file=<nifi-0 fqdn>.jks=/path/to/<nifi-0 fqdn>.jks \
--from-file=<nifi-1 fqdn>.jks=/path/to/<nifi-1 fqdn>.jks \
--from-file=<nifi-2 fqdn>.jks=/path/to/<nifi-2 fqdn>.jks \
--from-file=truststore.jks=/path/to/truststore.jks
```

Make the secret available to the replicas:

```
secrets:
- name: mysecrets
  keys:
    - <nifi-0 fqdn>.jks
    - <nifi-1 fqdn>.jks
    - <nifi-2 fqdn>.jks
    - truststore.jks
  mountPath: /opt/nifi/nifi-current/config-data/certs/
```

Add a safetyValve entry to align the container with the associated keystore:

```
properties:
  safetyValve:
    nifi.security.keystore: ${NIFI_HOME}/config-data/certs/${FQDN}.jks
```

## 3. OIDC

OpenID Connect (OIDC) is an open authentication protocol that profiles and extends OAuth 2.0 to add an identity layer. It can be used by an external identity provider to make authentication.

To enable OIDC user authentication, the values below must be set in `values.yaml` file:

```
oidc:
    enabled: true
    discoveryUrl: http://<oidc_provider_address>:<oidc_provider_port>/auth/realms/<client_realm>/.well-known/openid-configuration
    clientId: <client_name_in_oidc_provider>
    clientSecret: <client_secret_in_oidc_provider>
    claimIdentifyingUser: email
    admin: nifi@example.com
```

There are a lot of ID providers that can be used to perform an OIDC authentication. In our case, we have tested that with Keycloak. You will find an example of Keycloak config on this [page](doc/KEYCLOAK.md).

## 4. LDAP

Like OIDC, LDAP (Lightweight Directory Access Protocol) provide an external authentication. If you have your own LDAP, you can use it. If not, set `openldap.enabled` to `true` in `values.yaml` file to deploy a local instance of OpenLDAP.

To enable authentication through LDAP, set the values below in `values.yaml` file:

```
ldap:
    enabled: true
    host: ldap://<hostname>:<port>
    searchBase: CN=Users,DC=example,DC=com
    admin: cn=admin,dc=example,dc=be
    pass: changeMe
```
