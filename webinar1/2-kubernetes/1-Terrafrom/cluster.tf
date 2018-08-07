resource "digitalocean_droplet" "master" {
    name = "k8s-matser-node"
    image = "36148574"
    size = "${var.size}"
    region = "${var.region}"
    ipv6 = true
    private_networking = false
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]
    connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
      }

    provisioner "local-exec" {
    command = "echo Master Node IP-ADDRESS == ${digitalocean_droplet.master.ipv4_address} >> info.txt"
  }
    provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # initialize the Master node.
      "kubeadm init  --kubernetes-version v1.10.0 --pod-network-cidr=192.168.0.0/16 --token=ff6edf.38d10317aa6fa57e --ignore-preflight-errors=all"
    ]
  }


    provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "mkdir -p /root/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config",
      "sudo chown $(id -u):$(id -g) /root/.kube/config",
      "kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml",
      "kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml",
      "kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml"
    ]
  }
    
    provisioner "local-exec" {
    command = "scp -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${digitalocean_droplet.master.ipv4_address}:/root/.kube/config ~/.kube/."
  }
}

resource "digitalocean_droplet" "worker1" {
    name = "k8s-worker-node-1"
    image = "36148574"
    size = "${var.size}"
    region = "${var.region}"
    ipv6 = true
    private_networking = false
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]
    connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
      }

    provisioner "local-exec" {
    command = "echo Worker1 Node IP-ADDRESS == ${digitalocean_droplet.worker1.ipv4_address} >> info.txt"
  }
    provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # Join the Cluster.
      "kubeadm join --skip-preflight-checks --token ff6edf.38d10317aa6fa57e '${digitalocean_droplet.master.ipv4_address}':6443 --discovery-token-unsafe-skip-ca-verification",
     ]
}
}

resource "digitalocean_droplet" "worker2" {
    name = "k8s-worker-node-2"
    image = "36148574"
    size = "${var.size}"
    region = "${var.region}"
    ipv6 = true
    private_networking = false
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]
    connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
      }
    
    provisioner "local-exec" {
    command = "echo Worker2 Node IP-ADDRESS == ${digitalocean_droplet.worker2.ipv4_address} >> info.txt"
  }
    provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # Join the Cluster.
      "kubeadm join --skip-preflight-checks --token ff6edf.38d10317aa6fa57e '${digitalocean_droplet.master.ipv4_address}':6443 --discovery-token-unsafe-skip-ca-verification",
     ]
}
}
