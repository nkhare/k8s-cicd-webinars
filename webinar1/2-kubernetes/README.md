## Prerequisites.


- You Must have a DigitalOcean account and `Personal Access Token` must be generated on [DigitalOcean](https://www.digitalocean.com/docs/api/create-personal-access-token/).


## Tools

### Create SSH Keys.
```
$ ssh-keygen -t rsa

Generating public/private rsa key pair.
Enter file in which to save the key (~/.ssh/id_rsa): 
Created directory '~/.ssh/'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in ~/.ssh/id_rsa.
Your public key has been saved in ~/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:lCVaexVBIwHo++NlIxccMW5b6QAJa+ZEr9ogAElUFyY root@3b9a273f18b5
The key's randomart image is:
+---[RSA 2048]----+
|++.E ++o=o*o*o   |
|o   +..=.B = o   |
|.    .* = * o    |
| .   =.o + *     |
|  . . o.S + .    |
|   . +.    .     |
|    . ... =      |
|        o= .     |
|       ...       |
+----[SHA256]-----+

```

- You must link above created SSH key to [DigitalOcean] For that follow these [guidelines](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/create-with-openssh/)

### Install Terraform
- Download [Terraform binary](https://www.terraform.io/intro/getting-started/install.html) and add it to PATH.
```
apt install unzip
wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
unzip terraform_0.11.7_linux_amd64.zip
mv terraform /usr/bin/.
terraform version
```
- We are asuming your public keys and private keys are located at `~/.ssh/id_rsa.pub` and `~/.ssh/id_rsa`

### Install `kubectl`
```
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/kubernetes.list 
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
mkdir -p ~/.kube
```


## Create Kubernetes cluster on DigitalOcean.

- Clone the Repository
``` 
$ git clone https://github.com/nkhare/k8s-cicd-webinars.git
```

- Go to the Terrafrom script directory.
```
$ cd k8s-cicd-webinars/webinar1/2-kubernetes/1-Terrafrom/
```

- Get a Fingerprint of Your SSH public key.(This SSH key must be linked with DigitalOcean)
```
$ ssh-keygen -E md5 -lf ~/.ssh/id_rsa.pub | awk '{print $2}'
MD5:dd:d1:b7:0f:6d:30:c0:be:ed:ae:c7:b9:b8:4a:df:5e
```

- Export a Fingerprint shown in above output.
```
$ export FINGERPRINT=dd:d1:b7:0f:6d:30:c0:be:ed:ae:c7:b9:b8:4a:df:5e
```

- Export your DO Personal Access Token.
```
$ export TOKEN=##########<Your Digital Ocean Personal Access Token>##########
```

- Now take a look at the directory.
```
$ ls
cluster.tf  destroy.sh  outputs.tf  provider.tf  script.sh
```
- Simply run the script.
```
./script.sh
```

- When your script execution get completed your kubectl will get configured to use the kubernetes cluster.
```
$ kubectl get nodes
NAME                STATUS    ROLES     AGE       VERSION
k8s-matser-node     Ready     master    2m        v1.10.0
k8s-worker-node-1   Ready     <none>    1m        v1.10.0
k8s-worker-node-2   Ready     <none>    57s       v1.10.0
```

### Create a Kubernetes Deployment and Service.

- Lets create Nginx deployment.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80

```

- Deploy the deployment.
```
$ kubectl apply -f deployment.yaml
```

- List the deployments.
```
$ kubectl get deployments
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3         3         3            3           29s
```

- List the pods.
```
$ kubectl get pod
NAME                                READY     STATUS      RESTARTS   AGE
nginx-deployment-75675f5897-nhwsp   1/1       Running     0          1m
nginx-deployment-75675f5897-pxpl9   1/1       Running     0          1m
nginx-deployment-75675f5897-xvf4f   1/1       Running     0          1m

```

- Create service for above deployment.
```
kind: Service
apiVersion: v1
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  type: NodePort
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30111
```

- Deploy the service.
```
$ kubectl apply -f service.yaml
```

- List the Services.
```
$ kubectl get service
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP        5h
nginx-service   NodePort    10.100.98.213   <none>        80:30111/TCP   7s
```

You can access the Nginx application at 30111 port of Node/Master's IP address.


### Clean Up.
```
$ kubectl delete deployment nginx-deployment
$ kubectl delete service nginx-service
```


### Delete Cluster.
```
$ ./destroy.sh
```

