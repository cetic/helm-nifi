# Helm Chart for Apache NiFi

[![CircleCI](https://circleci.com/gh/cetic/helm-nifi.svg?style=svg)](https://circleci.com/gh/cetic/helm-nifi/tree/master) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![version](https://img.shields.io/github/tag/cetic/helm-nifi.svg?label=release)

## Introduction

This [Helm](https://helm.sh/) chart installs [Apache NiFi](https://nifi.apache.org/) in a [Kubernetes](https://kubernetes.io/) cluster.

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

- **Disable**: The data does not survive the termination of a pod.
- **Persistent Volume Claim(default)**: A default `StorageClass` is needed in the Kubernetes cluster to dynamically provision the volumes. Specify another StorageClass in the `storageClass` or set `existingClaim` if you have already existing persistent volumes to use.

#### Configure authentication

- You first need a secure cluster which can be accomplished by enabling the built-in CA nifi-toolkit container (`ca.enabled` to true). By default, a secure nifi cluster uses certificate based authentication but you can optionally enable `ldap` or `oidc`. See the configuration section for more details.

:warning: This feature is quite new. Please open an issue if you encounter a problem.
It seems that versions from 0.6.1 include some bugs for authentications. Please use version 0.6.0 of the chart until it is fixed. 

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

```bash
git clone https://github.com/cetic/helm-nifi.git nifi
cd nifi
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add dysnix https://dysnix.github.io/charts/
helm repo update
helm dep up
helm install nifi .
```

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
| `image.tag`                                                                 | nifi Image tag                                                                                                     | `1.12.1`                        |
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
| **secrets**
| `secrets`                                                                   | Pass any secrets to the nifi pods. The secret can also be mounted to a specific path if required.                  | `nil`                           |
| **configmaps**
| `configmaps`                                                                | Pass any configmaps to the nifi pods. The configmap can also be mounted to a specific path if required.            | `nil`                           |
| **nifi properties**                                                         |
| `properties.externalSecure`                                                 | externalSecure for when inbound SSL                                                                                | `false`                         |
| `properties.isNode`                                                         | cluster node properties (only configure for cluster nodes)                                                         | `true`                          |
| `properties.httpPort`                                                       | web properties HTTP port                                                                                           | `8080`                          |
| `properties.httpsPort`                                                      | web properties HTTPS port                                                                                          | `null`                          |
| `properties.clusterPort`                                                    | cluster node port                                                                                                  | `6007`                          |
| `properties.clusterSecure`                                                  | cluster nodes secure mode                                                                                          | `false`                         |
| `properties.needClientAuth`                                                 | nifi security client auth                                                                                          | `false`                         |
| `properties.provenanceStorage`                                              | nifi provenance repository max storage size                                                                        | `8 GB`                          |
| `properties.siteToSite.secure`                                              | Site to Site properties Secure mode                                                                                | `false`                         |
| `properties.siteToSite.port`                                                | Site to Site properties Secure port                                                                                | `10000`                         |
| `properties.siteToSite.authorizer`                                          |                                                                                                                    | `managed-authorizer`            |
| `properties.safetyValve`                                                    | Map of explicit 'property: value' pairs that overwrite other configuration                                         | `nil`                           |
| `properties.customLibPath`                                                  | Path of the custom libraries folder                                                                                | `nil`                           |
| **nifi user authentication**                                                |
| `auth.admin`                                                                | Default admin identity                                                                                             | ` CN=admin, OU=NIFI`            |
| `auth.ldap.enabled`                                                         | Enable User auth via ldap                                                                                          | `false`                         |
| `auth.ldap.host`                                                            | ldap hostname                                                                                                      | `ldap://<hostname>:<port>`      |
| `auth.ldap.searchBase`                                                      | ldap searchBase                                                                                                    | `CN=Users,DC=example,DC=com`    |
| `auth.ldap.searchFilter`                                                    | ldap searchFilter                                                                                                  | `CN=john`                       |
| `auth.oidc.enabled`                                                         | Enable User auth via oidc                                                                                          | `false`                         |
| `auth.oidc.discoveryUrl`                                                    | oidc discover url                                                                                                  | `https://<provider>/.well-known/openid-configuration`      |
| `auth.oidc.clientId`                                                        | oidc clientId                                                                                                      | `nil`    |
| `auth.oidc.clientSecret`                                                    | oidc clientSecret                                                                                                  | `nil`                       |
| `auth.oidc.claimIdentifyingUser`                                            | oidc claimIdentifyingUser                                                                                          | `email`                        |
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
| **Ingress**                                                                 |
| `ingress.enabled`                                                           | Enables Ingress                                                                                                    | `false`                         |
| `ingress.annotations`                                                       | Ingress annotations                                                                                                | `{}`                            |
| `ingress.path`                                                              | Path to access frontend (See issue [#22](https://github.com/cetic/helm-nifi/issues/22))                            | `/`                             |
| `ingress.hosts`                                                             | Ingress hosts                                                                                                      | `[]`                            |
| `ingress.tls`                                                               | Ingress TLS configuration                                                                                          | `[]`                            |
| **Persistence**                                                             |
| `persistence.enabled`                                                       | Use persistent volume to store data                                                                                | `false`                         |
| `persistence.storageClass`                                                  | Storage class name of PVCs (use the default type if unset)                                                         | `nil`                           |
| `persistence.accessMode`                                                    | ReadWriteOnce or ReadOnly                                                                                          | `[ReadWriteOnce]`               |
| `persistence.configStorage.size`                                            | Size of persistent volume claim                                                                                    | `100Mi`                         |
| `persistence.authconfStorage.size`                                          | Size of persistent volume claim                                                                                    | `100Mi`                         |
| `persistence.dataStorage.size`                                              | Size of persistent volume claim                                                                                    | `1Gi`                           |
| `persistence.flowfileRepoStorage.size`                                      | Size of persistent volume claim                                                                                    | `10Gi`                          |
| `persistence.contentRepoStorage.size`                                       | Size of persistent volume claim                                                                                    | `10Gi`                          |
| `persistence.provenanceRepoStorage.size`                                    | Size of persistent volume claim                                                                                    | `10Gi`                          |
| `persistence.logStorage.size`                                               | Size of persistent volume claim                                                                                    | `5Gi`                           |
| `persistence.existingClaim`                                                 | Use an existing PVC to persist data                                                                                | `nil`                           |
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
| **extraContainers**                                                         |
| `extraContainers`                                                           | Additional container-specifications that should run within the pod (see [spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#container-v1-core) for details)  | `[]`                            |
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
| `registry.enabled`                                                          | If true, deploy Nifi Registry                                                                                          | `true`                          |
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
| **metrics**                                                                     |
| `metrics.prometheus.enabled`            | Enable prometheus to access nifi metrics endpoint                                                                                    | `false`                                                      |
| `metrics.prometheus.port`              | Port where Nifi server will expose Prometheus metrics                                                                                  | `9092`                                                      |
| `metrics.prometheus.serviceMonitor.enabled`       | If `true`, creates a Prometheus Operator ServiceMonitor (also requires `metrics.prometheus.enabled` to be `true`)                       | `false`                                        |
| `metrics.prometheus.serviceMonitor.labels`       | Additional labels for the ServiceMonitor                       | `nil`                                        |

## Troubleshooting

Before [filing a bug report](https://github.com/cetic/helm-nifi/issues/new/choose), you may want to:

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

Please read the official [Contribution Guide](https://github.com/helm/charts/blob/master/CONTRIBUTING.md) from Helm for more information on how you can contribute to this Chart.

## License

[Apache License 2.0](/LICENSE)
