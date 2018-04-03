# Installation d'un cluster Kubernetes Hautement Disponible avec Ansible

## Prérequis

- Disposer de trois VMs CentOS7
- Avoir déposé vôtre clé ssh sur ces vm
- Modifier le fichier hosts avec les informations correspondantes à vos serveurs
- Modifier les fichiers ci-dessous avec les Ips (variable master_X_ip ou X est le numéro de votre master (1,2,3)) de vos Master:
  - /roles/etcd-install-systemd/defaults/main.yml
  - /roles/master-init/defaults/main.yml

## Aspects Techniques

- installation de Docker
- installation de kubeadm
- installaiton de keepalived (loadbalancer)
- installation d'ETCD en mode hôte (installé sur les hôtes et pas exécuté en tant que POD)

## Fichier hosts

Le fichier hosts ressemble à ceci :

```shell
[all]
#this group is used to install kubernetes master in playbook.yml
172.16.1.15 ansible_user=root ansible_connection=ssh ansible_hostname=master-1
172.16.1.17 ansible_user=root ansible_connection=ssh ansible_hostname=master-2
172.16.1.16 ansible_user=root ansible_connection=ssh ansible_hostname=master-3

[master]
#this group is used to install kubernetes master in playbook.yml
172.16.1.15 ansible_user=root ansible_connection=ssh ansible_hostname=master-1
172.16.1.17 ansible_user=root ansible_connection=ssh ansible_hostname=master-2
172.16.1.16 ansible_user=root ansible_connection=ssh ansible_hostname=master-3

[master-1]
172.16.1.15 ansible_user=root ansible_connection=ssh ansible_hostname=master-1

[master-2-3]
172.16.1.17 ansible_user=root ansible_connection=ssh ansible_hostname=master-2
172.16.1.16 ansible_user=root ansible_connection=ssh ansible_hostname=master-3

[node]
172.16.1.18 ansible_user=root ansible_connection=ssh ansible_hostname=node-1
```
Le groupe all est utilisé pour exécuter les tâches d'installation de docker et de configuration  (désactivation swap, firewalld, ...) des Master du cluster K8S.

Le groupe master est utilisé pour exécuter les tâches d'installation de keepalived et dl'initialisation des masters.

Le groupe master-1 est utilisé pour exécuter l'installation et la configuration d'ETCD. Le principe est d'initialiser ETCD en premier sur un master donné afin de pouvoir générer les certificats ETCD qui seront utilisées par les autres Master du cluster.

Le groupe master-2-3 est utilisé pour installer ETCD et récupérer les certificats générés par les tâches exécutés sur master-1.

Le groupe node est utilisé pour exécuter les tâches de configuration de Kubernetes (install docker, kubeadm, désactive le swap) sur les noeuds du cluster. Ces noeuds seront utilisés pour déployer les conteneurs Docker.

## Exécution du playbook

```shell
ansible-playbook -vv playbook.yml
```
### Exécution des tâches ansible que pour les masters

```shell
ansible-playbook -vv playbook.yml -t all-in
```
### Exécution des tâches ansible que pour le master-1

```shell
ansible-playbook -vv playbook.yml -t master-1-all
```

### Exécution des tâches ansible que pour les master-2-3

```shell
ansible-playbook -vv playbook.yml -t master-2-3-all
```

### Exécution des tâches ansible que pour les nodes

```shell
ansible-playbook -vv playbook.yml -t node-all
```
