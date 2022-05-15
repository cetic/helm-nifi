FAQ - Frequently Asked Questions
======

Readyness probe fails
---------------

When encountering errors like `Readiness probe failed: Node not found with CONNECTED state` or `Multi-Attach error for volume "pvc-xxxxxx-xxx-xxx-xxxx-xxxxxxxxx" Volume is already exclusively attached to one node and can't be attached to another`, it means Kubernetes can't provide the pod access to the persistent data it wants. 

When this happens, reach out to your Kubernetes cluster administrators to find and fix the problem manually. 

For more background, see https://blog.mayadata.io/recover-from-volume-multi-attach-error-in-on-prem-kubernetes-clusters

(see https://github.com/cetic/helm-nifi/issues/47#issuecomment-1122702262)