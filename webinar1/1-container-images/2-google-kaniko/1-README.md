
## Google-kaniko

`Google-kaniko` is a tool to build container images from a Dockerfile, inside a `container` or `Kubernetes Cluster`.
`Google-kaniko` does not depend on a Docker daemon for building Image. It can execute each command from `Dockerfile` completely in userspace. This enables building container images in environments that can't easily or securely run a Docker daemon, such as a standard Kubernetes cluster. 

The `kaniko executor image` is responsible for building an image from a Dockerfile and pushing it to a specific registry. Within the `kaniko executor image`, it extract the filesystem of the base image. Then it executes the commands specified in Dockerfile one after one. After each command, it append a layer of changed files to the base image and update image metadata.

For building the image you require the kaniko instance running and the context for building image.


Lets build the image in the Kubernetes environment.

- First login to your docker registry from CLI
```
$ docker login -u $USERNAME -p $PASSWORD
```

- After successful login check out the `$HOME/.docker/config.json`. 

- Now create a ConfigMap with `$HOME/.docker/config.json`
```
$ kubectl create configmap docker-config --from-file=$HOME/.docker/config.json
```

- Now create a Kaniko pod as given below.
```
apiVersion: v1
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    args: ["--dockerfile=./Dockerfile",
            "--context=/tmp/rsvpapp/",
            "--destination=docker.io/nkhare/rsvpapp:kaniko",
            "--force" ]
    volumeMounts:
      - name: docker-config
        mountPath: /root/.docker/
      - name: demo
        mountPath: /tmp/rsvpapp
  restartPolicy: Never
  initContainers:
    - image: python
      name: demo
      command: ["/bin/sh"]
      args: ["-c", "git clone https://github.com/cloudyuga/rsvpapp.git /tmp/rsvpapp"] 
      volumeMounts:
      - name: demo
        mountPath: /tmp/rsvpapp
  restartPolicy: Never
  volumes:
    - name: docker-config
      configMap:
        name: docker-config
    - name: demo
      emptyDir: {}
        
```

- Kindly update  `"--destination=docker.io/nkhare/rsvpapp:kaniko"` with your `DockerHub username`. Here my username is `nkhare`. 

- Deploy the kaniko Pod.
```
$ kubectl apply -f pod-kaniko.yaml 
pod/kaniko created

```

- Get the list of pod.
```
$  kubectl get pod
NAME      READY     STATUS     RESTARTS   AGE
kaniko    0/1       Init:0/1   0          47s

$ kubectl get pod
NAME      READY     STATUS    RESTARTS   AGE
kaniko    1/1       Running   0          1m

$ kubectl get pod
NAME      READY     STATUS      RESTARTS   AGE
kaniko    0/1       Completed   0          2m
```
Pod status is `complete` means pod has built the image and pushed it to Docker registry.

- Check the logs of pod.
```
$ kubectl logs kaniko

time="2018-08-02T05:01:24Z" level=info msg="appending to multi args docker.io/nkhare/rsvpapp:kaniko"
time="2018-08-02T05:01:24Z" level=info msg="Downloading base image nkhare/python:alpine"
.
.
.
ime="2018-08-02T05:01:46Z" level=info msg="Taking snapshot of full filesystem..."
time="2018-08-02T05:01:48Z" level=info msg="cmd: CMD"
time="2018-08-02T05:01:48Z" level=info msg="Replacing CMD in config with [/bin/sh -c python rsvp.py]"
time="2018-08-02T05:01:48Z" level=info msg="Taking snapshot of full filesystem..."
time="2018-08-02T05:01:49Z" level=info msg="No files were changed, appending empty layer to config."
2018/08/02 05:01:51 mounted blob: sha256:bc4d09b6c77b25d6d3891095ef3b0f87fbe90621bff2a333f9b7f242299e0cfd
2018/08/02 05:01:51 mounted blob: sha256:809f49334738c14d17682456fd3629207124c4fad3c28f04618cc154d22e845b
2018/08/02 05:01:51 mounted blob: sha256:c0cb142e43453ebb1f82b905aa472e6e66017efd43872135bc5372e4fac04031
2018/08/02 05:01:51 mounted blob: sha256:606abda6711f8f4b91bbb139f8f0da67866c33378a6dcac958b2ddc54f0befd2
2018/08/02 05:01:52 pushed blob sha256:16d1686835faa5f81d67c0e87eb76eab316e1e9cd85167b292b9fa9434ad56bf
2018/08/02 05:01:53 pushed blob sha256:358d117a9400cee075514a286575d7d6ed86d118621e8b446cbb39cc5a07303b
2018/08/02 05:01:55 pushed blob sha256:5d171e492a9b691a49820bebfc25b29e53f5972ff7f14637975de9b385145e04
2018/08/02 05:01:56 index.docker.io/nkhare/rsvpapp:kaniko: digest: sha256:831b214cdb7f8231e55afbba40914402b6c915ef4a0a2b6cbfe9efb223522988 size: 1243
```

- You can pull the Docker image kaniko has recently build.

```
$  docker pull nkhare/rsvpapp:kaniko
kaniko: Pulling from nkhare/rsvpapp
c0cb142e4345: Pull complete 
bc4d09b6c77b: Pull complete 
606abda6711f: Pull complete 
809f49334738: Pull complete 
358d117a9400: Pull complete 
5d171e492a9b: Pull complete 
Digest: sha256:831b214cdb7f8231e55afbba40914402b6c915ef4a0a2b6cbfe9efb223522988
Status: Downloaded newer image for nkhare/rsvpapp:kaniko
```




















### References
- https://github.com/GoogleContainerTools/kaniko
