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



### Components 


**Envoy** : Envoy is deployed as a sidecar to the relevant service. With sidecar allows you to add Istio functionalities to an existing deployment.


**Mixer** : Mixer is enforces access control and policies across the service mesh. It collects telemetry data from the Envoy proxy and other services. 


**Pilot** : Pilot provides service discovery for the Envoy sidecars, traffic management capabilities for intelligent routing.Pilot converts routing rules propagates them to the sidecars at runtime. Routing rules control traffic behavior into Envoy-specific configurations, and propagates them to the sidecars at runtime.


**Istio-Auth** : Istio-Auth provides strong and secure service-to-service communication and end-user authentication using mutual TLS.


## Features and Benefits


**Traffic Management** : Istio controls traffic and API calls between services.


**Observability** : Istio provides robust monitoring which provides the ability to quickly identify issues.


**Policy Enforcement** : Istio configures policies to access the services. These policies are applied by configuring the Service Mesh, no need to configure services.


**Service Identity and Security** : Istio provides verifiable identity to services in the mesh. Istio also provides the ability to protect service traffic as it flows over networks of varying degrees of trustability.



## References

- https://istio.io/docs/concepts/what-is-istio/overview.html

