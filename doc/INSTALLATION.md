Installation
=============


### Install from local clone

1. **Clone the repo**

```bash
git clone https://github.com/cetic/helm-nifi.git
cd helm-nifi
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add dysnix https://dysnix.github.io/charts/
helm repo update
helm dep up
```
2. **Set a sensitiveKey**

In 1.23.2 version, Nifi needs a sensitiveKey to encrypt sensitive information. This key can be setted in the `values.yaml` file:

````
properties:
  sensitiveKey: changeMechangeMe
````

3. **Configure a user authentication**

This helm chart provides three types of authentication: Single User, LDAP and OIDC.

You can find how to configure these authentications on this [page](doc/USERMANAGER.md).

4. **Install Nifi**

To install Nifi, run this command:

```bash
helm install nifi .
```
5. **Access Nifi**

If you let the Nifi service in ClusterIP mode, you cannot reach Nifi from the outside of the cluster. To fix that, you have to make a port forwarding to access Nifi from the localhost. To do that, run the command below:

````
kubectl port-forward service/nifi 8443:8443
````

Now you can access to Nifi with a browser by typing the address: `https://localhost:8443`
