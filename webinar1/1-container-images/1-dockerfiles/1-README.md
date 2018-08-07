## Dockerfiles
Docker builds the container images automatically by reading the instructions from a `Dockerfile`. A `Dockerfile` is a text file that consist of all the commands required to assemble a container image. Using `docker image build` command we can create an automated build that executes several command-line instructions provided in `Dockerfile`. The `docker image build` command builds an image from a `Dockerfile` and a `context`. The `context` is the set of files required to create a environment and run applications in container image.

## Demo

- Install Docker.
```
$ curl -fsSL get.docker.com | sh
```

- Lets take a look at `Dockerfile`
```
$ cat Dockerfile

FROM ubuntu:16.04

LABEL MAINTAINER neependra@cloudyuga.guru

RUN apt-get update \
    && apt-get install -y nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx"]

```
Dockerfile consist of the set of instructions required to build the image that will run Nginx.

- Lets build the container image.
```
$ docker image build -t nkhare/nginx .

Sending build context to Docker daemon  49.25MB
Step 1/5 : FROM ubuntu:16.04
 ---> 7aa3602ab41e
Step 2/5 : MAINTAINER neependra@cloudyuga.guru
 ---> Using cache
 ---> 552b90c2ff8d
Step 3/5 : RUN apt-get update     && apt-get install -y nginx     && apt-get clean     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*     && echo "daemon off;" >> /etc/nginx/nginx.conf
 ---> Using cache
 ---> 6bea966278d8
Step 4/5 : EXPOSE 80
 ---> Using cache
 ---> 8f1c4281309e
Step 5/5 : CMD ["nginx"]
 ---> Using cache
 ---> f545da818f47
Successfully built f545da818f47
Successfully tagged nginx:latest

```

- List the Docker images.
```
$ docker image ls

REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
nkhare/nginx     latest              f545da818f47        4 days ago          171MB
ubuntu                  16.04               7aa3602ab41e        11 days ago         115MB
```

## Multi-Stage
Multi stage build is the new feature introduced in the Docker 17.05, Which is very useful for optimizing the Dockerfile. It is very challeging task to write down the efficient Dockerfile with the lesser Docker image size. Each instruction in the Dockerfile creates the layer to the Docker image. Generally before this feature one Dockerfile was used for development (which contained everything needed to build your application),and another [reduced/modified] Dockerfile was used for production, which only contained your application and dependencies which were needed to run that application. 

- Clone the git repository. 
```
$ git clone https://github.com/nkhare/k8s-cicd-webinars.git
$ cd k8s-cicd-webinars/webinar1/1-container-images/1-dockerfiles/Multistage/
$ ls
Dockerfile  hello.c  README.md  SimpleDockerfile  start.sh
```

#### Without Multistage

- First build the simple image without multistage. For that take a look at `SimpleDockerfile`.
```
$ cat SimpleDockerfile 


FROM ubuntu AS buildstep
RUN apt-get update && apt-get install -y build-essential gcc
COPY hello.c /app/hello.c
COPY ./start.sh /app/start.sh
WORKDIR /app
RUN gcc -o hello hello.c && chmod +x hello
ENV INITSYSTEM=on
CMD ["bash", "/app/start.sh"]

```

- Build the image.
```
$ docker image build -t nkhare/simpleapp:capp -f ./SimpleDockerfile .
```

- List the images.
```
$ docker image ls
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
nkhare/simpleapp   capp                e36f2e302250        4 days ago          329MB
```

- Run the Docker container from the above created image.
```
$ docker container run nkhare/simpleapp:capp
Hello Everyone
```

#### With Multistage

- Take a look at Dockerfile.
```
$ cat Dockerfile

# This is the base for our build step container
# which has all our build essentials
FROM ubuntu AS buildstep
RUN apt-get update && apt-get install -y build-essential gcc
COPY hello.c /app/hello.c
WORKDIR /app
RUN gcc -o hello hello.c && chmod +x hello

# This is our runtime container that will end up
# running on the device.
FROM ubuntu

# Uncomment the following if your binary requires additional dependencies
# RUN apt-get update && apt-get install -y \
# curl \
# && rm -rf /var/lib/apt/lists/*

# Defines our working directory in container
RUN mkdir -p /usr/src/app/
WORKDIR /usr/src/app

# Copy our artifact into our deployable container context.
COPY --from=buildstep /app/hello ./hello

# Copy our start script into our deployable container context.
COPY ./start.sh ./start.sh

# Enable systemd init system in container
ENV INITSYSTEM=on

# server.js will run when container starts up on the device
CMD ["bash", "/usr/src/app/start.sh"]

```

- Build the image from above Dockerfile.
```
$ ddocker image build -t nkhare/multistage:capp .
```

- List Docker image.
```
$  docker image l
s
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
nkhare/multistage   capp                44aec4c9e792        4 days ago          83.5MB
nkhare/simpleapp    capp                e36f2e302250        4 days ago          329MB

```
Here we can see that the size of image created using the multi-stage build is smaller than earlier image.

- Lets run the Docker container from the above created image.
```
$ docker container run nkhare/multistage:capp
Hello Everyone
```

### References
- https://docs.docker.com/engine/reference/builder/
- https://docs.docker.com/develop/develop-images/multistage-build/
