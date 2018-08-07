#!/bin/bash
terraform init
terraform plan -var "pub_key=~/.ssh/id_rsa.pub" -var "pvt_key=~/.ssh/id_rsa"  -var "region=ams3" -var "ssh_fingerprint=$FINGERPRINT" -var "do_token=$TOKEN" -var "size=2gb" 
terraform apply -input=false -auto-approve -var "pub_key=~/.ssh/id_rsa.pub" -var "pvt_key=~/.ssh/id_rsa"  -var "region=ams3" -var "ssh_fingerprint=$FINGERPRINT" -var "do_token=$TOKEN" -var "size=2gb" 

exit 0
