# Helm Chart for Apache NiFi

[![CircleCI](https://circleci.com/gh/cetic/helm-nifi.svg?style=svg)](https://circleci.com/gh/cetic/helm-nifi/tree/master) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![version](https://img.shields.io/github/tag/cetic/helm-nifi.svg?label=release) ![test](https://github.com/cetic/helm-nifi/actions/workflows/test.yml/badge.svg)


## Introduction

This [Helm](https://helm.sh/) chart installs [Apache NiFi](https://nifi.apache.org/) 1.16.3 in a [Kubernetes](https://kubernetes.io/) cluster.

## Prerequisites

- Kubernetes cluster 1.10+
- Helm 3.0.0+
- [Persistent Volumes (PV)](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) provisioner support in the underlying infrastructure.

## Installation

### Add Helm repository

```bash
helm repo add cetic https://cetic.github.io/helm-charts
helm repo update
```

### Configure the chart

The following items can be set via `--set` flag during installation or configured by editing the [`values.yaml`](values.yaml) file directly (need to download the chart first).

#### Configure how to expose nifi service

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster.
- **NodePort**: Exposes the service on each Node’s IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting `NodeIP:NodePort`.
- **LoadBalancer**: Exposes the service externally using a cloud provider’s load balancer.

#### Configure how to persist data

- **Disable(default)**: The data does not survive the termination of a pod.
- **Persistent Volume Claim**: Enable persistence so that data survives termination of the pod.  There is the choice of using one large persistent volume (using subPath) or seven separate persistent volumes for config, data, logs, repos, etc.  
  A default `StorageClass` is needed in the Kubernetes cluster to dynamically provision the volumes. Specify another StorageClass in the `persistence.storageClass` setting.

#### Configure authentication

- By default, the authentication is a `Single-User` authentication. You can optionally enable `ldap` or `oidc` to provide an external authentication. See the [configuration section](README.md#configuration) or [doc](doc/) folder for more details.

#### Use custom processors

To add [custom processors](https://cwiki.apache.org/confluence/display/NIFI/Maven+Projects+for+Extensions#MavenProjectsforExtensions-MavenProcessorArchetype), the `values.yaml` file `nifi` section should contain the following options, where `CUSTOM_LIB_FOLDER` should be replaced by the path where the libs are:

```yaml
  extraVolumeMounts:
    - name: mycustomlibs
      mountPath: /opt/configuration_resources/custom_lib
  extraVolumes: # this will create the volume from the directory
    - name: mycustomlibs
      hostPath:
        path: "CUSTOM_LIB_FOLDER"
  properties:
    customLibPath: "/opt/configuration_resources/custom_lib"
```

#### Configure prometheus monitoring

- You first need monitoring to be enabled which can be accomplished by enabling the appropriate metrics flag (`metrics.prometheus.enabled` to true).
To enable the creation of prometheus metrics within Nifi we need to create a *Reporting Task*. Login to the Nifi UI and go to the Hamburger menu on the top right corner, click *Controller Settings* --> *Reporting Tasks* After that use the + icon to add a task. Click on the *Reporting* in the wordcloud on the left and select *PrometheusReportingTask* --> change *Send JVM metrics* to `true` and click on the play button to enable this task.

If you plan to use Grafana for the visualization of the metrics data [the following dashboard](https://grafana.com/grafana/dashboards/12314) is compatible with the exposed metrics.

### Install the chart

Install the nifi helm chart with a release name `my-release`:

```bash
helm install my-release cetic/nifi
```

### Install from local clone

You will find how to perform an installation from a local clone on this [page](doc/INSTALLATION.md).

## Uninstallation

To uninstall/delete the `my-release` deployment:

```bash
helm uninstall my-release
```

## Configuration

The following table lists the configurable parameters of the nifi chart and the default values.

| Parameter                                                                   | Description                                                                                                        | Default                         |
| --------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------| ------------------------------- |
| **ReplicaCount**                                                            |
| `replicaCount`                                                              | Number of nifi nodes                                                                                               | `1`                             |
| **Image**                                                                   |
| `image.repository`                                                          | nifi Image name                                                                                                    | `apache/nifi`                   |
| `image.tag`                                                                 | nifi Image tag                                                                                                     | `1.16.3`                        |
| `image.pullPolicy`                                                          | nifi Image pull policy                                                                                             | `IfNotPresent`                  |
| `image.pullSecret`                                                          | nifi Image pull secret                                                                                             | `nil`                           |
| **SecurityContext**                                                         |
| `securityContext.runAsUser`                                                 | nifi Docker User                                                                                                   | `1000`                          |
| `securityContext.fsGroup`                                                   | nifi Docker Group                                                                                                  | `1000`                          |
| **sts**                                                                     |
| `sts.useHostNetwork`                                                            | If true, use the host's network                                                                                    | `nil`                         |
| `sts.serviceAccount.create`    | If true, a service account will be created and used by the statefulset | `false` |
| `sts.serviceAccount.name`       | When set, the set name will be used as the service account name. If a value is not provided a name will be generated based on Chart options | `nil` |
| `sts.serviceAccount.annotations`                                                       | Service account annotations                                                                                                | `{}`                            |
| `sts.podManagementPolicy`                                                   | Parallel podManagementPolicy                                                                                       | `Parallel`                      |
| `sts.AntiAffinity`                                                          | Affinity for pod assignment                                                                                        | `soft`                          |
| `sts.pod.annotations`                                                       | Pod template annotations                                                                                           | `security.alpha.kubernetes.io/sysctls: net.ipv4.ip_local_port_range=10000 65000`                          |
| `sts.hostAliases    `                                                       | Add entries to Pod /etc/hosts                                                                                      | `[]`                            |
| `sts.startupProbe.enabled`                                                  | enable [Startup Probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes) on Nifi server container                                                                      | `false`                            |
| `sts.startupProbe.failureThreshold`                                         | sets Startup Probe failureThreshold field value                                                                    | `60`                            |
| `sts.startupProbe.periodSeconds`                                            | sets Startup Probe periodSeconds field value                                                                       | `10`                            |
| **secrets**
| `secrets`                                                                   | Pass any secrets to the nifi pods. The secret can also be mounted to a specific path if required.                  | `nil`                           |
| **configmaps**
| `configmaps`                                                                | Pass any configmaps to the nifi pods. The configmap can also be mounted to a specific path if required.            | `nil`                           |
| **nifi properties**                                                         |
| `properties.algorithm`                                                 | [Encryption method](https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html#nifi_sensitive_props_key)                                                                                | `NIFI_PBKDF2_AES_GCM_256`                         |
| `properties.sensitiveKey`                                                 | [Encryption password](https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html#nifi_sensitive_props_key) (at least 12 characters)                                                                                | `changeMechangeMe`                         |
| `properties.sensitiveKeySetFile`                                            | [Update Sensitive Properties Key](https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html#updating-the-sensitive-properties-key) if this file does not exist, and then create it. | `nil`                           |
| `properties.sensitiveKeyPrior`                                              | Prior `sensitiveKey` when updating via `sensitiveKeySetFile` mechanism                                             | `nil`                           |
| `properties.externalSecure`                                                 | externalSecure for when inbound SSL                                                                                | `false`                         |
| `properties.isNode`                                                         | cluster node properties (only configure for cluster nodes)                                                         | `false`                          |
| `properties.httpPort`                                                       | web properties HTTP port                                                                                           | `8080`                          |
| `properties.httpsPort`                                                      | web properties HTTPS port                                                                                          | `null`                          |
| `properties.clusterPort`                                                    | cluster node port                                                                                                  | `6007`                          |
| `properties.provenanceStorage`                                              | nifi provenance repository max storage size                                                                        | `8 GB`                          |
| `properties.provenanceMaxStorageTime`                                       | nifi provenance repository max storage time                                                                        | `10 days`                          |
| `properties.siteToSite.secure`                                              | Site to Site properties Secure mode                                                                                | `false`                         |
| `properties.siteToSite.port`                                                | Site to Site properties Secure port                                                                                | `10000`                         |
| `properties.safetyValve`                                                    | Map of explicit 'property: value' pairs that overwrite other configuration                                         | `nil`                           |
| `properties.customLibPath`                                                  | Path of the custom libraries folder                                                                                | `nil`                           |
| `properties.webProxyHost`                               | Proxy to access to Nifi through the cluster ip address    | `Port:30236`
| **[Authentication](/doc/USERMANAGEMENT.md)**                                                |
| **Single-user authentication**                                                | Automatically disabled if Client Certificate, OIDC, or LDAP enabled
| `auth.     admin`                                                           | Default admin identity. It will overwrite the LDAP Bind DN for this purpose, when both is filled                   | ` CN=admin, OU=NIFI`            |
| `auth.singleUser.username`                                                                | Single user identity                                                                                             | `username`            |
| `auth.singleUser.password`                                                         | Single user password                                                                                          | `changemechangeme`                         |
| **Client Certificate authentication**       |
| `auth.clientAuth.enabled`       |     Enable User auth via Client Certificates       |     `false`
| **Ldap authentication**                                                |
| `auth.ldap.admin`                                                           | Default admin identity and LDAP Bind DN                                                                            |                                 |
| `auth.ldap.enabled`                                                         | Enable User auth via ldap                                                                                          | `false`                         |
| `auth.ldap.host`                                                            | ldap hostname                                                                                                      | `ldap://<hostname>:<port>`      |
| `auth.ldap.searchBase`                                                      | ldap searchBase                                                                                                    | `CN=Users,DC=example,DC=com`    |
| `auth.ldap.searchFilter`                                                    | ldap searchFilter                                                                                                  | `CN=john`                       |
| `auth.ldap.userSearchScope`                                                 | ldap userSearchScope                                                                                               | `ONE_LEVEL`                     |
| `auth.ldap.groupSearchScope`                                                | ldap groupSearchScope                                                                                              | `ONE_LEVEL`                     |
| **Oidc authentication**
| `auth.oidc.enabled`                                                         | Enable User auth via oidc                                                                                          | `false`                         |
| `auth.oidc.discoveryUrl`                                                    | oidc discover url                                                                                                  | `https://<provider>/.well-known/openid-configuration`      |
| `auth.oidc.clientId`                                                        | oidc clientId                                                                                                      | `nil`                           |
| `auth.oidc.clientSecret`                                                    | oidc clientSecret                                                                                                  | `nil`                           |
| `auth.oidc.claimIdentifyingUser`                                            | oidc claimIdentifyingUser                                                                                          | `email`                         |
| `auth.oidc.preferredJwsAlgorithm`                                            | The preferred algorithm for validating identity tokens. If this value is blank, it will default to RS256 which is required to be supported by the OpenID Connect Provider according to the specification. If this value is HS256, HS384, or HS512, NiFi will attempt to validate HMAC protected tokens using the specified client secret. If this value is none, NiFi will attempt to validate unsecured/plain tokens.                                                                                           | `nil`                         |
| `auth.oidc.admin`                                                           | Default OIDC admin identity                                                                                        | `nifi@example.com`              |
| Note that OIDC authentication to a multi-NiFi-node cluster requires Ingress sticky sessions | See [background](https://community.cloudera.com/t5/Support-Questions/OIDC-With-Azure-AD/m-p/232324#M194163)      | Also [how](https://kubernetes.github.io/ingress-nginx/examples/affinity/cookie/) |
| **postStart**                                                               |
| `postStart`                                                                 | Include additional libraries in the Nifi containers by using the postStart handler                                 | `nil`                           |
| **Headless Service**                                                        |
| `headless.type`                                                             | Type of the headless service for nifi                                                                              | `ClusterIP`                     |
| `headless.annotations`                                                      | Headless Service annotations                                                                                       | `service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"`|
| **UI Service**                                                              |
| `service.type`                                                              | Type of the UI service for nifi                                                                                    | `NodePort`                  |
| `service.httpPort`                                                          | Port to expose service                                                                                             | `8080`                            |
| `service.httpsPort`                                                         | Port to expose service in tls                                                                                      | `443`                           |
| `service.annotations`                                                       | Service annotations                                                                                                | `{}`                            |
| `service.loadBalancerIP`                                                    | LoadBalancerIP if service type is `LoadBalancer`                                                                   | `nil`                           |
| `service.loadBalancerSourceRanges`                                          | Address that are allowed when svc is `LoadBalancer`                                                                | `[]`                            |
| `service.processors.enabled`                                                | Enables additional port/ports to nifi service for internal processors                                              | `false`                         |
| `service.processors.ports`                                                  | Specify "name/port/targetPort/nodePort" for processors  sockets                                                    | `[]`                            |
| **ContainerPorts**       |                                                  |
| `containerPorts`                                                            | Additional containerPorts for the nifi-container. Example is given in values.yaml  | `[]` 
| **Ingress**                                                                 |
| `ingress.enabled`                                                           | Enables Ingress                                                                                                    | `false`                         |
| `ingress.className`      | Ingress controller Class                                                                                   | `nginx`                                  |
| `ingress.annotations`                                                       | Ingress annotations                                                                                                | `{}`                            |
| `ingress.path`                                                              | Path to access frontend (See issue [#22](https://github.com/cetic/helm-nifi/issues/22))                            | `/`                             |
| `ingress.hosts`                                                             | Ingress hosts                                                                                                      | `[]`                            |
| `ingress.tls`                                                               | Ingress TLS configuration                                                                                          | `[]`                            |
| **Persistence**                                                             |
| `persistence.enabled`                                                       | Use persistent volume to store data                                                                                | `false`                         |
| `persistence.storageClass`                                                  | Storage class name of PVCs (use the default type if unset)                                                         | `nil`                           |
| `persistence.accessMode`                                                    | ReadWriteOnce or ReadOnly                                                                                          | `[ReadWriteOnce]`               |
| `persistence.subPath.enabled`                                               | Use only one persistent volume with subPath instead of seven separate persistent volumes                           | `false`                           |
| `persistence.subPath.name`                                                  | Name of the one persistent volume claim when using subPath                                                         | `data`                          |
| `persistence.subPath.size`                                                  | Size of the one persistent volume claim when using subPath                                                         | `36Gi`                          |
| `persistence.configStorage.size`                                            | Size of persistent volume claim                                                                                    | `100Mi`                         |
| `persistence.authconfStorage.size`                                          | Size of persistent volume claim                                                                                    | `100Mi`                         |
| `persistence.dataStorage.size`                                              | Size of persistent volume claim                                                                                    | `1Gi`                           |
| `persistence.flowfileRepoStorage.size`                                      | Size of persistent volume claim                                                                                    | `10Gi`                          |
| `persistence.contentRepoStorage.size`                                       | Size of persistent volume claim                                                                                    | `10Gi`                          |
| `persistence.provenanceRepoStorage.size`                                    | Size of persistent volume claim                                                                                    | `10Gi`                          |
| `persistence.logStorage.size`                                               | Size of persistent volume claim                                                                                    | `5Gi`                           |
| **jvmMemory**                                                               |
| `jvmMemory`                                                                 | bootstrap jvm size                                                                                                 | `2g`                            |
| **SideCar**                                                                 |
| `sidecar.image`                                                             | Separate image for tailing each log separately and checking zookeeper connectivity                                 | `busybox`                       |
| `sidecar.tag`                                                               | Image tag                                                                                                          | `1.32.0`                        |
| `sidecar.imagePullPolicy`                                                   | Image imagePullPolicy                                                                                              | `IfNotPresent`                  |
| **Resources**                                                               |
| `resources`                                                                 | Pod resource requests and limits for logs                                                                          | `{}`                            |
| **logResources**                                                            |
| `logresources.`                                                             | Pod resource requests and limits                                                                                   | `{}`                            |
| **affinity**                                                                |
| `affinity`                                                                  | Pod affinity scheduling rules                                                                                      | `{}`                            |
| **nodeSelector**                                                            |
| `nodeSelector`                                                              | Node labels for pod assignment                                                                                     | `{}`                            |
| **terminationGracePeriodSeconds**                                           |
| `terminationGracePeriodSeconds`                                             | Number of seconds the pod needs to terminate gracefully. For clean scale down of the nifi-cluster the default is set to 60, opposed to k8s-default 30. | `60`                            |
| **tolerations**                                                             |
| `tolerations`                                                               | Tolerations for pod assignment                                                                                     | `[]`                            |
| **initContainers**                                                          |
| `initContainers`                                                            | Container definition that will be added to the pod as [initContainers](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#container-v1-core) | `[]`                            |
| **extraVolumes**                                                            |
| `extraVolumes`                                                              | Additional Volumes available within the pod (see [spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volume-v1-core) for format)       | `[]`                            |
| **extraVolumeMounts**                                                       |
| `extraVolumeMounts`                                                         | VolumeMounts for the nifi-server container (see [spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volumemount-v1-core) for details)  | `[]`                            |
| **env**                                                                     |
| `env`                                                                       | Additional environment variables for the nifi-container (see [spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#envvar-v1-core) for details)  | `[]`                            |
| `envFrom`                                                                       | Additional environment variables for the nifi-container from config-maps or secrets (see [spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#envfromsource-v1-core) for details)  | `[]`                            |
| **extraOptions**                                                           |
| `extraOptions`                                                              | Additional bootstrap.conf properties (see [properties](https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html#bootstrap_properties) for details)  | `[]`                          |
| **extraContainers**                                                         |
| `extraContainers`                                                           | Additional container-specifications that should run within the pod (see [spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#container-v1-core) for details)  | `[]`                            |
| **extraLabels**                                                         |
| `extraLabels`                                                           | Additional labels for the nifi pod | `nil`                                 |
| **openshift**                                                                     |
| `openshift.scc.enabled`                                                     | If true, a openshift security context will be created permitting to run the statefulset as AnyUID | `false` |
| `openshift.route.enabled`                                                   | If true, a openshift route will be created. This option cannot be used together with Ingress as a route object replaces the Ingress. The property `properties.externalSecure` will configure the route in edge termination mode, the default is passthrough. The property `properties.httpsPort` has to be set if the cluster is intended to work with SSL termination | `false` |
| `openshift.route.host`                                                      | The hostname intended to be used in order to access NiFi web interface | `nil` |
| `openshift.route.path`                                                      | Path to access frontend, works the same way as the ingress path option | `nil` |
| **zookeeper**                                                               |
| `zookeeper.enabled`                                                         | If true, deploy Zookeeper                                                                                          | `true`                          |
| `zookeeper.url`                                                             | If the Zookeeper Chart is disabled a URL and port are required to connect                                          | `nil`                           |
| `zookeeper.port`                                                            | If the Zookeeper Chart is disabled a URL and port are required to connect                                          | `2181`                          |
| **registry**                                                                |
| `registry.enabled`                                                          | If true, deploy [Nifi Registry](https://nifi.apache.org/registry.html)                                                                                          | `false`                          |
| `registry.url`                                                              | If the Nifi Registry Chart is disabled a URL and port are required to connect                                          | `nil`                           |
| `registry.port`                                                             | If the Nifi Registry Chart is disabled a URL and port are required to connect                                          | `80`                            |
| **ca**                                                                      |
| `ca.enabled`                                                                | If true, deploy Nifi Toolkit as CA                                                                                          | `false`                          |
| `ca.server`                                                                 | CA server dns name                                          | `nil`                           |
| `ca.port`                                                                   | CA server port number                                          | `9090`                            |
| `ca.token`                                                                  | The token to use to prevent MITM                                          | `80`                            |
| `ca.admin.cn`                                                               | CN for admin certificate                                          | `admin`                            |
| `ca.serviceAccount.create`                                                 | If true, a service account will be created and used by the deployment                                         | `false`                            |
| `ca.serviceAccount.name`                                                 |When set, the set name will be used as the service account name. If a value is not provided a name will be generated based on Chart options | `nil` |
| `ca.openshift.scc.enabled`                                                     | If true, an openshift security context will be created permitting to run the deployment as AnyUID | `false` |
| **certManager**                                                             |
| `certManager.enabled`                                                       | If true, use [cert-manager](https://cert-manager.io/) to create and rotate intra-NiFi-cluster TLS keys (note that cert-manager is a Kubernetes cluster-wide resource, so is not installed automatically by this chart) | `false`                         |
| `certManager.clusterDomain`                                                 | Kubernetes cluster top level domain, to generate fully qualified domain names for certificate Common Names         | `cluster.local`                 |
| `certManager.keystorePasswd`                                                | Java Key Store password for NiFi keystore                                                                          | `changeme`                      |
| `certManager.truststorePasswd`                                              | Java Key Store password for NiFi truststore                                                                        | `changeme`                      |
| `certManager.additionalDnsNames`                                            | Additional DNS names to incorporate into TLS certificates (e.g. where users point browsers to access the NiFi UI)  | `[ localhost ]`                 |
| `certManager.caSecrets`                                                     | Names of Kubernetes secrets containing `ca.crt` keys to add to the NiFi truststore                                 | `[ ]`                           |
| `certManager.refreshSeconds`                                                | How often the sidecar refreshes the NiFi keystore (not truststore) from the cert-manager Kubernetes secrets        | `300`                           |
| `certManager.resources`                                                     | Memory and CPU resources for the node certificate refresh sidecar                                                  | 100m CPU, 128MiB RAM            |
| `certManager.replaceDefaultTrustStore`                                      | Use the certManager truststore, not the default Java trusted CA collection (for [e.g.] private OIDC provider)      | `false`                         |
| `certManager.certDuration`                                                  | NiFi node certificate lifetime (90 days)                                                                           | `2160h`                         |
| `certManager.caDuration`                                                    | Certificate Authority certificate lifetime (10 years)                                                              | `87660h`                        |
| **metrics**                                                                     |
| `metrics.prometheus.enabled`            | Enable prometheus to access nifi metrics endpoint                                                                                    | `false`                                                      |
| `metrics.prometheus.port`              | Port where Nifi server will expose Prometheus metrics                                                                                  | `9092`                                                      |
| `metrics.prometheus.serviceMonitor.enabled`       | If `true`, creates a Prometheus Operator ServiceMonitor (also requires `metrics.prometheus.enabled` to be `true`)                       | `false`                                        |
| `metrics.prometheus.serviceMonitor.namespace`       | In which namespace the ServiceMonitor should be created                       |
| `metrics.prometheus.serviceMonitor.labels`       | Additional labels for the ServiceMonitor                       | `nil`                                        |
| **customFlow**                                                              |                                                                                                                    |                                 |
| `customFlow`                                                                | Use this file (uncompressed XML; [possibly from a configmap](tests/06-site-to-site.bash)) as the Flow definition   | `nil`                           |

## Troubleshooting

Before [filing a bug report](https://github.com/cetic/helm-nifi/issues/new/choose), you may want to:

* check the [FAQ](/doc/FAQ.md)
* check that [persistent storage](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) is configured on your cluster
* keep in mind that a first installation may take a significant amount of time on a home internet connection
* check if a pod is in error:
```bash
kubectl get pod
NAME                  READY   STATUS    RESTARTS   AGE
myrelease-nifi-0             3/4     Failed   1          56m
myrelease-nifi-registry-0    1/1     Running   0          56m
myrelease-nifi-zookeeper-0   1/1     Running   0          56m
myrelease-nifi-zookeeper-1   1/1     Running   0          56m
myrelease-nifi-zookeeper-2   1/1     Running   0          56m
```

Inspect the pod, check the "Events" section at the end for anything suspicious.

```bash
kubectl describe pod myrelease-nifi-0
```

Get logs on a failed container inside the pod (here the `server` one):

```bash
kubectl logs myrelease-nifi-0 server
```

## Credits

Initially inspired from https://github.com/YolandaMDavis/apache-nifi.

TLS work/inspiration from https://github.com/sushilkm/nifi-chart.git.

## Contributing

Feel free to contribute by making a [pull request](https://github.com/cetic/helm-nifi/pull/new/master).

Please read the official [Helm Contribution Guide](https://github.com/helm/charts/blob/master/CONTRIBUTING.md) from Helm for more information on how you can contribute to this Chart.

## License

[Apache License 2.0](/LICENSE)
