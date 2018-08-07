## Projectatomic-Buildah
Buildah is a CLI tool developed by `Projectatomic` for efficiently and quickly building Open Container Initiative (OCI) compliant images. Buildah can create an image, either from a working container or a Dockerfile. `Buildah` can perform image operation like build, list, push, tag. `Buildah`


### Installation.

Following instructions are for Ubuntu 16.04. If you are using different OS then please follow the [installation notes](https://github.com/projectatomic/buildah/blob/master/install.md)

- Install the required dependencies.
```
  apt-get -y install software-properties-common
  add-apt-repository -y ppa:alexlarsson/flatpak
  add-apt-repository -y ppa:gophers/archive
  apt-add-repository -y ppa:projectatomic/ppa
  apt update
  apt-get -y install bats btrfs-tools git libapparmor-dev libdevmapper-dev libglib2.0-dev libgpgme11-dev libostree-dev libseccomp-dev libselinux1-dev skopeo-containers go-md2man
```

- Install Go language.
```
  sudo apt-get update
  sudo curl -O https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz
  sudo tar -xvf go1.8.linux-amd64.tar.gz
  sudo mv go /usr/local
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
  source ~/.profile
  go version
```

- Install the runc and Buildah.
```
  mkdir ~/buildah
  cd ~/buildah
  export GOPATH=`pwd`
  git clone https://github.com/projectatomic/buildah ./src/github.com/projectatomic/buildah
  cd ./src/github.com/projectatomic/buildah
  make runc all TAGS="apparmor seccomp"
  cp ~/buildah/src/github.com/opencontainers/runc/runc /usr/bin/.
  apt install buildah -y
```

- Configure the `/etc/containers/registries.conf`.
```
$ cat <<EOF >> /etc/containers/registries.conf

# This is a system-wide configuration file used to
# keep track of registries for various container backends.
# It adheres to TOML format and does not support recursive
# lists of registries.

# The default location for this configuration file is /etc/containers/registries.conf.

# The only valid categories are: 'registries.search', 'registries.insecure',
# and 'registries.block'.

[registries.search]
registries = ['docker.io', 'registry.fedoraproject.org', 'quay.io', 'registry.access.redhat.com', 'registry.centos.org']

# If you need to access insecure registries, add the registry's fully-qualified name.
# An insecure registry is one that does not have a valid SSL certificate or only does HTTP.
[registries.insecure]
registries = []


# If you need to block pull access from a registry, uncomment the section below
# and add the registries fully-qualified name.
#
# Docker only
[registries.block]
registries = []

EOF
```

### Build the image.

- Building the image using our github repository as context.
```
$ sudo buildah build-using-dockerfile -t nkhare/rsvpapp:buildah github.com/cloudyuga/rsvpapp 
```

- List the images.
```
$ sudo buildah images

IMAGE ID             IMAGE NAME                                               CREATED AT             SIZE
edaae541faea         localhost/nkhare/rsvpapp:buildah                         Aug 7, 2018 16:04      114 MB

```
- [If you have installed docker and logged in to docker using CLI then you can skip this step].

- Install Docker and Login.
```
$ curl -fsSL get.docker.com | sh

$ docker login -u USERNAME -p PASSWORD
```

- Push the image to the Docker registry 
```
$ sudo buildah push --authfile ~/.docker/config.json nkhare/rsvpapp:buildah docker://nkhare/rsvpapp:buildah
```

- Push the image to Docker Daemon.
```
$ sudo buildah push  nkhare/rsvpapp:buildah docker-daemon:nkhare/rsvpapp:buildah
```

- List the Docker images.
```
$ docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nkhare/rsvpapp      buildah             edaae541faea        41 seconds ago      108MB

```
### Reference
- https://github.com/projectatomic/buildah
