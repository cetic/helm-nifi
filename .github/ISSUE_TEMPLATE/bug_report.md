---
name: Bug report
about: Create a report to help us improve
title: '[cetic/nifi] issue title'
labels: ''
assignees: ''

---

<!-- Thanks for filing an issue! Before hitting the button, please answer these questions. It's helpful to search the existing GitHub issues first. It's likely that another user has already reported the issue you're facing, or it's a known issue that we're already aware of 

Fill in as much of the template below as you can.  If you leave out information, we can't help you as well.

Be ready for followup questions, and please respond in a timely manner. If we can't reproduce a bug or think a feature already exists, we might close your issue.  If we're wrong, PLEASE feel free to reopen it and explain why.
-->

**Describe the bug**
A clear and concise description of what the bug is.

**Version of Helm and Kubernetes**:


**What happened**:


**What you expected to happen**:


**How to reproduce it** (as minimally and precisely as possible):


**Anything else we need to know**:

Here are some information that help troubleshooting:

* if relevant, provide your `values.yaml` (after removing sensitive information)
* the output of the folowing commands:

Check if a pod is in error: 
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
