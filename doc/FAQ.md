FAQ - Frequently Asked Questions
================================

Readyness probe fails
---------------------

When encountering errors like `Readiness probe failed: Node not found with CONNECTED state` or `Multi-Attach error for volume "pvc-xxxxxx-xxx-xxx-xxxx-xxxxxxxxx" Volume is already exclusively attached to one node and can't be attached to another`, it means Kubernetes can't provide the pod access to the persistent data it wants.

When this happens, reach out to your Kubernetes cluster administrators to find and fix the problem manually.

For more background, see https://blog.mayadata.io/recover-from-volume-multi-attach-error-in-on-prem-kubernetes-clusters

(see https://github.com/cetic/helm-nifi/issues/47#issuecomment-1122702262)

## Session Afffinity

As mentioned in the official NIFI document regarding [session affinity](https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html#session_affinity), it's required to implement this feature for your ingress. Please refer to the ingress controller your are using for how to implement it. One example for GKE is with [issue #271](https://github.com/cetic/helm-nifi/issues/271). If NIFI cluster has more than one node, the session affinity has to be there due to the stateful implementation of each node.
