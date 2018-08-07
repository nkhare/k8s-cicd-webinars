#!/bin/bash


terraform destroy --force -var "pub_key=~/.ssh/id_rsa.pub" -var "pvt_key=~/.ssh/id_rsa"  -var "region=ams3" -var "ssh_fingerprint=$FINGERPRINT" -var "do_token=$TOKEN" -var "size=2gb"
rm *.txt
rm -r terraform.tfstate*

exit 0
