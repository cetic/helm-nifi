User Authentication
=============

This helm chart provides three types of authentication: Single User, LDAP and OIDC. These three authtications can be managed essentialy from the `values.yaml` file. 


## 1. Single User

The Single User authentication is the default authentication in this helm chart. To login like a single user, the values below must be setted in `values.yaml` file:

````
singleUser:
    username: username
    password: changemechangeme
````

## 2. OIDC

OpenID Connect (OIDC) is an open authentication protocol that profiles and extends OAuth 2.0 to add an identity layer. It can be used by an external identity provider to make authentication. 

To enable OIDC user authentication, the values below must be setted in `values.yaml` file:

````
oidc:
    enabled: true
    discoveryUrl: http://<oidc_provider_address>:<oidc_provider_port>/auth/realms/<client_realm>/.well-known/openid-configuration
    clientId: <client_name_in_oidc_provider>
    clientSecret: <client_secret_in_oidc_provider>
    claimIdentifyingUser: email
    admin: nifi@example.com
````

There are a lot of ID providers that can be used to perform an OIDC authentication. In our case, we have tested that with Keycloak. You will find an example of Keycloak config on this [page](https://github.com/cetic/helm-nifi/tree/feature/nifi_1.14.0/doc/KEYCLOAK.md).


## 3. LDAP

Like OIDC, LDAP (Lightweight Directory Access Protocol) provide an external authentication. If you have your own LDAP, you can use it. If not, set `openldap.enabled` to `true` in `values.yaml` file to deploy a local instance of OpenLDAP.

To enable authentication through LDAP, set the values below in `values.yaml` file:

````
ldap:
    enabled: true
    host: ldap://<hostname>:<port>
    searchBase: CN=Users,DC=example,DC=com
    admin: cn=admin,dc=example,dc=be
    pass: changeMe
````
