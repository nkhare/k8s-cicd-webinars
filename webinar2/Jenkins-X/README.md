
## Prerequisites.
- GitHub API token.

### Setting up environment.

- Create a 8GB DigitalOcean droplet.

- Install `Docker`.
```
$ curl -fsSL get.docker.com | sh
```
- Install `Minikube`.
```
$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.28.2/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```
- Install `kubectl`.
```
$ sudo apt-get update && sudo apt-get install -y apt-transport-https
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
$ sudo touch /etc/apt/sources.list.d/kubernetes.list 
$ echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
$ sudo apt-get update
$ sudo apt-get install -y kubectl
```

- Install `JX`.
```
$ curl -L https://github.com/jenkins-x/jx/releases/download/v1.3.175/jx-linux-amd64.tar.gz | tar xzv 
sudo mv jx /usr/local/bin
```
- Install `socat`
```
$ apt install socat
```
- Configure Docker to use Insecure registries.
```
cat <<EOF>> /etc/docker/daemon.json
{
  "insecure-registries" : ["0.0.0.0/0"]
}
EOF
```

- Restart Docker service.
```
$ systemctl restart docker
```

- Verify Docker is configured with the insecure registries.
```
$ docker info

Containers: 10
 Running: 0
 Paused: 0
 Stopped: 10
Images: 30
Server Version: 18.06.0-ce
Storage Driver: overlay2
 Backing Filesystem: extfs
 Supports d_type: true
 Native Overlay Diff: true
.
.
.
.
.
.

Insecure Registries:
 0.0.0.0/0
 127.0.0.0/8
Live Restore Enabled: false
```

### Create a Minikube cluster using the JX.

- Create cluster using following command.
```
$ jx create cluster minikube --cpu=3 --default-admin-password=admin --vm-driver=none --memory=4096
```
It will ask you for install missing dependency, Countinue with installing the dependencies.

- Provide your Github username and API token.

- Once Cluster created we can go to next step.

- Get the list of various URLs created by the JX.
```
$ jx get urls
Name                      URL
jenkins                   http://jenkins.jx.206.189.227.210.nip.io
jenkins-x-chartmuseum     http://chartmuseum.jx.206.189.227.210.nip.io
jenkins-x-docker-registry http://docker-registry.jx.206.189.227.210.nip.io
jenkins-x-monocular-api   http://monocular.jx.206.189.227.210.nip.io
jenkins-x-monocular-ui    http://monocular.jx.206.189.227.210.nip.io
nexus                     http://nexus.jx.206.189.227.210.nip.io
```

### Create a Application.

- Clone the application repository.
```
$  git clone https://github.com/cloudyuga/rsvpapp.git

$ cd rsvpapp

$ rm -r .git/

```

- Create the application in `jx` and on `github` using following command.
```
$ jx import
```

It will ask for you some inputs. Provide proper Inputs.

- It will create github repository for your application.

- You can list the Environments.
```
$ jx get env
NAME       LABEL       KIND        PROMOTE NAMESPACE     ORDER CLUSTER SOURCE                                                           REF PR
dev        Development Development Never   jx            0                                                                                  
staging    Staging     Permanent   Auto    jx-staging    100           https://github.com/vghule/environment-crestnickel-staging.git        
production Production  Permanent   Manual  jx-production 200           https://github.com/vghule/environment-crestnickel-production.git     
```

- You can list the applications.
```
$ jx get applications
APPLICATION STAGING PODS URL                                                  PRODUCTION PODS URL
python-http 0.0.1   1/1  http://python-http.jx-staging.206.189.227.210.nip.io      
```

- You can access the simple Python application running at the `http://python-http.jx-staging.206.189.227.210.nip.io`.

- Modify `charts/rsvpapp/values.yaml` files.
```
$ cat <<EOF> charts/rsvpapp/values.yaml 

# Default values for python.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
replicaCount: 1
env: mongodb
image:
  repository: draft
  tag: dev
  pullPolicy: IfNotPresent
service:
  name: rsvpapp
  type: ClusterIP
  externalPort: 80
  internalPort: 5000
  annotations:
    fabric8.io/expose: "true"
    fabric8.io/ingress.annotations: "kubernetes.io/ingress.class: nginx"
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi
ingress:
  enabled: false
EOF
```

- Create `charts/rsvpapp/requirements.yaml`
```
$ cat <<EOF> charts/rsvpapp/requirements.yaml

dependencies:
- name: mongodb-replicaset
  repository: https://kubernetes-charts.storage.googleapis.com/
  version: 3.5.5

EOF

```

- Update Helm chart deployment template at `charts/rsvpapp/templates/deployment.yaml`

```
$ cat <<EOF> charts/rsvpapp/templates/deployment.yaml

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "fullname" . }}
  labels:
    draft: {{ default "draft-app" .Values.draft }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        draft: {{ default "draft-app" .Values.draft }}
        app: {{ template "fullname" . }}
{{- if .Values.podAnnotations }}
      annotations:
{{ toYaml .Values.podAnnotations | indent 8 }}
{{- end }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        env:
        - name: MONGODB_HOST
          value: "mongodb://{{.Release.Name}}-{{ .Values.env }}-replicaset-0.{{.Release.Name}}-{{ .Values.env }}-replicaset,{{.Release.Name}}-{{ .Values.env }}-replicaset-1.{{.Release.Name}}-{{ .Values.env }}-replicaset,{{.Release.Name}}-{{ .Values.env }}-replicaset-2.{{.Release.Name}}-{{ .Values.env }}-replicaset:27017"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.internalPort }}
        resources:
{{ toYaml .Values.resources | indent 12 }}


EOF
````

- Lets add pytest in `Jenkinsfile`.
```
$ cat <<EOF> ./Jenkinsfile
pipeline {
    agent {
        label "jenkins-python"
    }
    environment {
      ORG               = 'cloudyuga'
      APP_NAME          = 'rsvpapp'
      CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    }
    stages {
      stage('CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          container('python') {
            sh "python -m unittest"

            sh 'export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml'


            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }

          dir ('./charts/preview') {
           container('python') {
             sh "make preview"
             sh "jx preview --app $APP_NAME --dir ../.."
           }
          }
        }
      }
      stage('Build Release') {
        when {
          branch 'master'
        }
        steps {
          container('python') {
            // ensure we're not on a detached head
            sh "git checkout master"
            sh "git config --global credential.helper store"

            sh "jx step git credentials"
            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
          }
          dir ('./charts/rsvpapp') {
            container('python') {
              sh "make tag"
            }
          }
          container('python') {
          
            sh "pip install -r requirements.txt"  
            sh "python -m pytest test_rsvpapp.py" 
            sh 'export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml'

            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
          }
        }
      }
      stage('Promote to Environments') {
        when {
          branch 'master'
        }
        steps {
          dir ('./charts/rsvpapp') {
            container('python') {
              sh 'jx step changelog --version v\$(cat ../../VERSION)'

              // release the helm chart
              sh 'jx step helm release'

              // promote through all 'Auto' promotion Environments
              sh 'jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)'
            }
          }
        }
      }
    }
    post {
        always {
            cleanWs()
        }
    }
  }

EOF
```

- Now push the changes to Git repository.
```
$ git add *
$ git commit -m update
$ git push
```

- It will trigger new build of you application. Open the Jenkins UI and you will there see the cosole output of your application build.

- You will list application using the command.
```
$ jx get app

APPLICATION STAGING PODS URL                                             PRODUCTION PODS URL
mongodb     4.1.1   1/1                                                                  
rsvpapp     0.0.3   1/1  http://rsvpapp.jx-staging.167.99.234.182.nip.io                 
```
At this given URL you can access the application.

Now our application is running at above given URL.

- You can get activity of the application by using.
```
$ jx get activity -f rsvpapp 
````

- List the pod running in `jx-staging` namespace.
```
$  kubectl get po -n jx-staging
NAME                                  READY     STATUS    RESTARTS   AGE
jx-staging-mongodb-54b486767f-lngb6   1/1       Running   0          9m
jx-staging-rsvpapp-866d86bc9f-bk2fd   1/1       Running   0          9m
```
## Promote application to the Production.
```
$ jx promote rsvpapp --version=0.0.3 --env=production
```
- After successful promotion you can check the list of application.
```
$ jx get app
APPLICATION STAGING PODS URL                                             PRODUCTION PODS URL
mongodb     4.1.1   1/1                                                  4.1.1      1/1  
rsvpapp     0.0.3   1/1  http://rsvpapp.jx-staging.167.99.234.182.nip.io 0.0.3      1/1  http://rsvpapp.jx-production.167.99.234.182.nip.io
```
We can confirm that our application is promoted to the production by accessing the application URL provided in above output.
