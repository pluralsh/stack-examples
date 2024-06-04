# Plural Stack Examples
---

Infrastructure as Code (IaC) Examples repository. This repository contains a collection of examples demonstrating how to manage and provision infrastructure using various IaC tools, including Terraform, Ansible, AWS Cloud Development Kit (CDK), and Pulumi.


## Infrastructure as Code (IaC) 
Infrastructure as Code (IaC) is the practice of managing and provisioning computing infrastructure through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools. This repository showcases examples using different IaC tools to help you get started with automating your infrastructure deployment with [Plural](https://www.plural.sh/).


# Terraform


# Ansible
### Update `./configs/hosts` with ssh accessible IPs or Host Names
```ini
# FILE: ./configs/hosts
# Inventory File for Ansible

[K3sHost:children]
K3sAdmin
K3sNode

[K3sAdmin]
18.191.236.195

[K3sNode]
3.137.199.13
18.118.1.37
```
### Update the K3S Install Args for TLS SAN
```yaml
# FILE: ./playbooks/group_vars/K3sHost.yml
...
k3s: # Lightweight Kubernetes: https://github.com/k3s-io/k3s/releases/
  tmpfile: /tmp/k3s.sh
  url: https://get.k3s.io
  # domain: example.cloud # 👈 optionally configure the DNS name for the cluster
  nodetoken: /var/lib/rancher/k3s/server/node-token
  kubeconfig: /home/ubuntu/.kube/k3sconfig
  local_kubeconfig: "{{ lookup('env', 'HOME') }}/.kube/k3sconfig"
  args:
    - --write-kubeconfig-mode 644
    - --write-kubeconfig ~/.kube/k3sconfig
    - --disable=traefik
    - --disable=servicelb
    - --prefer-bundled-bin
    - --tls-san 10.0.101.197 # 👈 here is where we update the local EC2 instance IP 
    - --tls-san 18.191.236.195 # 👈 optionally update the public EC2 instance IP 
    # - --tls-san example.cloud # 👈 optionally configure the DNS name for the cluster
```
There are other configurable parameters in the `./playbooks/group_vars/K3sHost.yml` file  
Such as desired packages directories and git repos, but these configs are all that is required to install K3S on Ubuntu  

If you are using an alternate OS, make sure to update the host user and the kube config path
e.g. for Pi OS
```yaml
user: pi
k3s:
  kubeconfig: /home/pi/.kube/k3sconfig
```
### Update `./configs/ssh.config` for your hosts
Ansible uses ssh to access the host instances and perform tasks  
Ensure the config has the proper `Host`, `User` and `IdentityFile` for your instances
```ini
Host *
  User ubuntu
  IdentityFile ./configs/ansible-ssh-key.pem
  IdentitiesOnly yes
```
### View the Ansible Playbook Changes without applying them
```sh
ansible-playbook playbooks/makeK3SHost.yml --diff --check
```

### Run the Ansible Playbook 
```sh
ansible-playbook playbooks/makeK3SHost.yml
```

The K3s Cluster should now be available at the IP you configured as the `K3sAdmin`: https://18.191.236.195:6443  

If you are running this ansible locally a copy of the authenticated Kube Config will dowload to `~/.kube/k3sconfig`


# Pulumi