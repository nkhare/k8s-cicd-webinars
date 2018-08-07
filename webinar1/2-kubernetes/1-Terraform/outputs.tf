output "Master_Node_addresses" { 
 value = "${digitalocean_droplet.master.ipv4_address}"
}

output "Worker_Node1_addresses" { 
 value = "${digitalocean_droplet.worker1.ipv4_address}"
}

output "Worker_Node2_addresses" { 
 value = "${digitalocean_droplet.worker2.ipv4_address}"
}

