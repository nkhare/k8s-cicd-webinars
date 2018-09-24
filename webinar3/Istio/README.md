## Istio


Istio is an open-source service mesh which provides platform to connect, manage, and secure microservices.


As per `https://istio.io/docs/`

Istio provides an easy way to create a network of deployed services with load balancing, service-to-service authentication, monitoring, and more, without requiring any changes in service code.


Istio support to services by deploying a special sidecar proxy along with the service that tracks all network communication between microservices. Sidecars are configured and managed by Istio’s control plane functionality.



## Architecture



![](https://istio.io/docs/concepts/what-is-istio/arch.svg) 


Istio is divided into `Data plane` and a `Control plane`. 


**Data plane** : It is composed of set of Envoy deployed as sidecars that provides medium for communications and controls all network communication between microservices.


**Control plane**: It manages and configures proxies to route traffic. Control plane enforces policies at runtime.



### Components of Istio


**Envoy** : Envoy is deployed as a sidecar to the relevant service. With sidecar allows you to add Istio functionalities to an existing deployment.


**Mixer** : Mixer is enforces access control and policies across the service mesh. It collects telemetry data from the Envoy proxy and other services. 


**Pilot** : Pilot provides service discovery for the Envoy sidecars, traffic management capabilities for intelligent routing.Pilot converts routing rules propagates them to the sidecars at runtime. Routing rules control traffic behavior into Envoy-specific configurations, and propagates them to the sidecars at runtime.


**Citadel** : Citadel provides strong and secure service-to-service communication and end-user authentication using mutual TLS.

**Galley**

Galley validates user authored Istio API configuration on behalf of the other Istio control plane components. Over time, Galley will take over responsibility as the top-level configuration ingestion, processing and distribution component of Istio. It will be responsible for insulating the rest of the Istio components from the details of obtaining user configuration from the underlying platform (e.g. Kubernetes).

## Features and Benefits


**Traffic Management** : Istio controls traffic and API calls between services.


**Observability** : Istio provides robust monitoring which provides the ability to quickly identify issues.


**Policy Enforcement** : Istio configures policies to access the services. These policies are applied by configuring the Service Mesh, no need to configure services.


**Service Identity and Security** : Istio provides verifiable identity to services in the mesh. Istio also provides the ability to protect service traffic as it flows over networks of varying degrees of trustability.



## Get Istio Manifest.

- Download files and Setup `istioctl` in PATH
```
$ curl -L https://git.io/getLatestIstio | sh -
$ cd istio-1.0.0/
$ cp bin/istioctl /usr/bin/.
```

- Install required CRD.
```
$ kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
```

- Update `install/kubernetes/istio-demo.yaml`. find `istio-ingressgateway` service,  `grafana` service, `prometheus` service, `tracing` service, `servicegraph` service and update `type: NodePort` in it. 



- Deploy the Istio Service Mesh.
```
$ kubectl apply -f install/kubernetes/istio-demo.yaml
```

- Verify the pods running in `istio-system` namespace.

```

$ kubectl get pod -n istio-system
NAME                                        READY     STATUS      RESTARTS   AGE
grafana-66469c4d95-7ppmr                    1/1       Running     0          16d
istio-citadel-5799b76c66-bm5dh              1/1       Running     0          16d
istio-cleanup-secrets-chq4g                 0/1       Completed   0          16d
istio-egressgateway-6578f84b68-xxsfq        1/1       Running     0          16d
istio-galley-5bf4d6b8f7-5tjrx               1/1       Running     1          16d
istio-grafana-post-install-68q7s            0/1       Completed   0          16d
istio-ingressgateway-67995c486c-tfzcm       1/1       Running     0          16d
istio-pilot-5c778f6dfd-bz44h                2/2       Running     0          16d
istio-policy-8667975f76-6zrjl               2/2       Running     0          16d
istio-sidecar-injector-5b5fcf4df6-8jhbk     1/1       Running     0          16d
istio-statsd-prom-bridge-7f44bb5ddb-zsvgn   1/1       Running     0          16d
istio-telemetry-7d87746bbf-d82qs            2/2       Running     0          16d
istio-telemetry-7d87746bbf-djq24            2/2       Running     0          12d
istio-telemetry-7d87746bbf-f2qdg            2/2       Running     0          16d
istio-telemetry-7d87746bbf-k4ltb            2/2       Running     0          16d
istio-telemetry-7d87746bbf-r89zf            2/2       Running     0          11d
istio-tracing-ff94688bb-74wgv               1/1       Running     0          16d
prometheus-84bd4b9796-ddw5k                 1/1       Running     0          16d
servicegraph-7875b75b4f-hx5vq               1/1       Running     0          16d
```


- Verify the services running.
```
$ kubectl get svc -n istio-system
NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                                                     AGE
grafana                    NodePort    10.107.131.215   <none>        3000:31386/TCP                                                                                              16d
istio-citadel              ClusterIP   10.102.178.156   <none>        8060/TCP,9093/TCP                                                                                           16d
istio-egressgateway        ClusterIP   10.97.99.6       <none>        80/TCP,443/TCP                                                                                              16d
istio-galley               ClusterIP   10.103.197.15    <none>        443/TCP,9093/TCP                                                                                            16d
istio-ingressgateway       NodePort    10.102.21.45     <none>        80:31380/TCP,443:31390/TCP,31400:31404/TCP,15011:32606/TCP,8060:31119/TCP,15030:31174/TCP,15031:31212/TCP   16d
istio-pilot                ClusterIP   10.105.2.253     <none>        15010/TCP,15011/TCP,8080/TCP,9093/TCP                                                                       16d
istio-policy               ClusterIP   10.105.172.82    <none>        9091/TCP,15004/TCP,9093/TCP                                                                                 16d
istio-sidecar-injector     ClusterIP   10.106.209.44    <none>        443/TCP                                                                                                     16d
istio-statsd-prom-bridge   ClusterIP   10.104.220.26    <none>        9102/TCP,9125/UDP                                                                                           16d
istio-telemetry            ClusterIP   10.103.127.2     <none>        9091/TCP,15004/TCP,9093/TCP,42422/TCP                                                                       16d
jaeger-agent               ClusterIP   None             <none>        5775/UDP,6831/UDP,6832/UDP                                                                                  16d
jaeger-collector           ClusterIP   10.111.41.169    <none>        14267/TCP,14268/TCP                                                                                         16d
jaeger-query               ClusterIP   10.100.89.13     <none>        16686/TCP                                                                                                   16d
prometheus                 NodePort    10.104.34.34     <none>        9090:31310/TCP                                                                                              16d
servicegraph               NodePort    10.99.114.50     <none>        8088:32330/TCP                                                                                              16d
tracing                    NodePort    10.101.220.237   <none>        80:32057/TCP                                                                                                16d
zipkin                     ClusterIP   10.108.120.60    <none>        9411/TCP                                                                                                    16d

```

- Set the `GATEWAY_URL`.
```
$ export INGRESS_HOST=<NODE IP Address>

$ export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

$ export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')

$ export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
```

## References

- https://istio.io/docs/concepts/what-is-istio/overview.html

