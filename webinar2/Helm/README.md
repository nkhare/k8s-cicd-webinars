## Helm

### Install Helm binaries.

- Download Helm installation script. Change the permission of the script and execute the script using following commands.
```
$ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

- Lets create Service account `tiller` and RBAC rule for `tiller` service account.
```
$ cat rbac_helm.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system

  - kind: User
    name: "admin"
    apiGroup: rbac.authorization.k8s.io

  - kind: User
    name: "kubelet"
    apiGroup: rbac.authorization.k8s.io

  - kind: Group
    name: system:serviceaccounts
    apiGroup: rbac.authorization.k8s.io

```

- Deploy above configuration.
```
$ kubectl apply -f rbac_helm.yaml 
```

- Initialize the Helm.
```
$ helm init --service-account tiller 
```

- Verify tiller pod is running in the `kube-system` namespace.
```
$ kubectl --namespace kube-system get pods | grep tiller
```

- Lets search for `mongodb`.
```
$ helm search mongodb
```

- Create new Helm chart `demo`.
```
$ helm create demo
```

- Take a look at the chart directory and files in it.
```
$ cd demo
$ ls
```

- Take look at `Chart.yaml`
```
$ cat Chart.yaml
```

- Take a look at `values.yaml`
```
$ cat values.yaml
```

- List the files in `templates` directory.
```
$ ls templates
```
Get out of demo directory.

- Lets install the Helm chart.
```
$ helm install --name web ./demo
```

- List the deployments created by the Helm chart.
```
$ kubectl get deploy
```

Modify the `demo/values.yaml`, in this file modify `replicaCount: 3` , change `image:tag` from `stable to latest` and save it.

- List the Helm releases.
```
$ helm list
```

- Upgrade the application to effect of the changes we have done earlier.
```
$ helm upgrade web ./demo
```

- List the Helm releases.
```
$ helm list
```

- Lets get the history of the Helm releases.
```
$ helm history web
```

- Lets RollBack to revision to `1`.
```
$ helm rollback web 1
```

- Lets get the history of the Helm releases.
```
$ helm history web
```

- List the Pods.
```
$ kubectl get pods
```

- Delete the Helm release.
```
$ helm delete web
```

- Lets get the history of the Helm releases.
```
$ helm history web
```

- Delete the Helm release completely
```
$ helm delete web --purge
```
