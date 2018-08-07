## CRD or Custom Resource Definition
A `resource` is an endpoint in the `Kubernetes API` that stores a collection of `API objects` . For example, `pods` resource contains a collection of `Pod` objects. A custom resource is nothing but the extension of the Kubernetes API. Custom resources can store and retrieve the structured data. When they are combined with a `controller`, they become a true `declarative API`. With A `declarative API` we can specify the desired state of our resource. 

A `custom controller` is a controller that users can deploy and update CRDs on a running cluster, independent of the cluster’s own controller. `Kubernets Operator` pattern is example of combination of Custom Resource, Custom Controller and Declarative API.


Create a new Custom Resource Definition.

- Create configuration file as below.
```
$ vi crd.yaml

apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: webinars.digitalocean.com
spec:
  group: digitalocean.com
  version: v1
  scope: Namespaced
  names:
    plural: webinars
    singular: webinar
    kind: Webinar
    shortNames:
    - wb
   
```

- Deploy this CRD.
```
$ kubectl create -f crd.yaml 
customresourcedefinition.apiextensions.k8s.io/webinars.digitalocean.com created
```

- Get the list of CRD.
```
$ kubectl get crd
NAME                        CREATED AT
webinars.digitalocean.com   2018-08-03T06:08:39Z

```

- After proxying the Kubernetes API locally using kubectl proxy we can discover the `digitalocean.com` API group as follow.
```
$ kubectl proxy &
$ curl 127.0.0.1:8001/apis/digitalocean.com

HTTP/1.1 200 OK
Content-Length: 238
Content-Type: application/json
Date: Fri, 03 Aug 2018 06:10:12 GMT

{
    "apiVersion": "v1", 
    "kind": "APIGroup", 
    "name": "digitalocean.com", 
    "preferredVersion": {
        "groupVersion": "digitalocean.com/v1", 
        "version": "v1"
    }, 
    "serverAddressByClientCIDRs": null, 
    "versions": [
        {
            "groupVersion": "digitalocean.com/v1", 
            "version": "v1"
        }
    ]
}



```

Next, we will create an instance of the `webinar` CRD :

- Configure the instance as follow.
```
$ vim webinar.yaml

apiVersion: "digitalocean.com/v1"
kind: Webinar
metadata:
  name: webinar1
spec:
  name: webinar
  image: nginx

```

- Deploy the instance of CRD.
```
$  kubectl apply -f webinar.yaml 
webinar.digitalocean.com/webinar1 created
```

- We can manage our `webinar` objects using `kubectl`. For example:
```
$ kubectl get webinar
NAME       CREATED AT
webinar1   21s


$ kubectl get wb
NAME       CREATED AT
webinar1   36s

```

- After proxying the Kubernetes API locally using kubectl proxy we can discover the `webinars` CRD we defined in the previous step like so:
```
$ curl 127.0.0.1:8001/apis/digitalocean.com/v1/namespaces/default/webinars

HTTP/1.1 200 OK
Content-Length: 826
Content-Type: application/json
Date: Fri, 03 Aug 2018 06:13:28 GMT

{
    "apiVersion": "digitalocean.com/v1", 
    "items": [
        {
            "apiVersion": "digitalocean.com/v1", 
            "kind": "Webinar", 
            "metadata": {
                "annotations": {
                    "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"digitalocean.com/v1\",\"kind\":\"Webinar\",\"metadata\":{\"annotations\":{},\"name\":\"webinar1\",\"namespace\":\"default\"},\"spec\":{\"image\":\"nginx\",\"name\":\"webinar\"}}\n"
                }, 
                "clusterName": "", 
                "creationTimestamp": "2018-08-03T06:12:04Z", 
                "generation": 1, 
                "name": "webinar1", 
                "namespace": "default", 
                "resourceVersion": "35024", 
                "selfLink": "/apis/digitalocean.com/v1/namespaces/default/webinars/webinar1", 
                "uid": "247d17ec-96e4-11e8-b522-0800272c1dad"
            }, 
            "spec": {
                "image": "nginx", 
                "name": "webinar"
            }
        }
    ], 
    "kind": "WebinarList", 
    "metadata": {
        "continue": "", 
        "resourceVersion": "35115", 
        "selfLink": "/apis/digitalocean.com/v1/namespaces/default/webinars"
    }
}

```
## Delete a Custom Resource Definition.

- Delete CRD instance.
```
$ kubectl delete webinar --all
```

- Delete the  CRD.
```
$ kubectl delete crd webinars.digitalocean.com
```

### References
- https://kubernetes.io/docs/tasks/access-kubernetes-api/custom-resources/
