#!/bin/sh
readUser() {
  read -p "$1 (Défaut : $2) : " tmpReadUser
  if [ "$tmpReadUser" ]; then
    export $1="${tmpReadUser}"
  fi
}

if [ "$1" = "manual" ]
 then
  echo " -------------------------------------------------"
  echo " > Welcome to Kubernetes HA Installer <"
  echo " ---------------- Manual Mode --------------------"
  echo ""
  echo " > set the settings <"
  readUser "hostname_master_1" ${hostname_master_1:="Master-1"}
  readUser "hostname_master_2" ${hostname_master_2:="Master-2"}
  readUser "hostname_master_3" ${hostname_master_3:="Master-3"}
  readUser "master_1_ip" ${master_1_ip:="172.16.1.31"}
  readUser "master_2_ip" ${master_2_ip:="172.16.1.32"}
  readUser "master_3_ip" ${master_3_ip:="172.16.1.33"}
  readUser "virtual_ip" ${virtual_ip:="172.16.1.37"}
  readUser "interface" ${interface:="enp0s3"}
  readUser "priority_1" ${priority_1:="100"}
  readUser "priority_2" ${priority_2:="101"}
  readUser "state_master" ${state_master:="master"}
  readUser "state_backup" ${state_backup:="BACKUP"}
  readUser "auth_pass" ${auth_pass:="4be37dc3b4c90194d1600c483e10ad1d"}
  readUser "etcd_version (ex: v3.1.12)" ${etcd_version:="v3.1.12"}
  readUser "pod_network_cidr" ${pod_network_cidr:="10.244.0.0/16"}
  ansible-playbook playbook.yml --extra-vars \
  "hostname_master_1=${hostname_master_1} hostname_master_2=${hostname_master_2} hostname_master_3=${hostname_master_3} \
   master_1_ip=${master_1_ip} master_2_ip=${master_2_ip} master_3_ip=${master_3_ip}\
   virtual_ip=${virtual_ip} pod_network_cidr=${pod_network_cidr} \
   interface=${interface} priority_1=${priority_1} priority_2=${priority_2} state_master=${state_master} state_backup=${state_backup} etcd_version=${etcd_version} auth_pass=${auth_pass}"
elif [[ "$1" = "auto" ]]
 then
  echo " -------------------------------------------------"
  echo " > Welcome to Kubernetes HA Installer <"
  echo " ------------------ Auto Mode --------------------"
  echo ""
  if [[ -e /ansible/playbooks/hosts ]]
    then
      echo "Host file is present"
      if [[ -e /ansible/playbooks/playbook.yml ]]
        then
          echo "Running playbook"
          ansible-playbook -vv playbook.yml --tags all
      else
        echo "playbook.yml is missing"
      fi
  else
    echo "Host file is missing"
  fi
fi

/bin/bash
