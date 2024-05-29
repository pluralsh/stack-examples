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
### Run the Ansible Playbook 
```sh
ansible-playbook playbooks/makeK3SHost.yml
```
Example Output
```ini
PLAY [Provision Host Machines] ****************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************
ok: [18.118.1.37]
ok: [3.137.199.13]
ok: [18.191.236.195]

TASK [packages : Install packages with apt] ***************************************************************************************************
ok: [18.118.1.37]
ok: [3.137.199.13]
ok: [18.191.236.195]

TASK [packages : Install packages with yum] ***************************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [packages : Install packages with dnf] ***************************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [packages : Install packages with pacman] ************************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [configs : Create Directories on Host] ***************************************************************************************************
ok: [3.137.199.13] => (item=~/.config/nvim)
ok: [18.118.1.37] => (item=~/.config/nvim)
ok: [18.191.236.195] => (item=~/.config/nvim)
ok: [3.137.199.13] => (item=~/.history)
ok: [18.118.1.37] => (item=~/.history)
ok: [18.191.236.195] => (item=~/.history)
ok: [3.137.199.13] => (item=~/.kube)
ok: [18.118.1.37] => (item=~/.kube)
ok: [18.191.236.195] => (item=~/.kube)

TASK [configs : Copy Config Files to Host] ****************************************************************************************************
ok: [3.137.199.13] => (item={'src': '.zshrc', 'dest': '~/.zshrc'})
ok: [18.118.1.37] => (item={'src': '.zshrc', 'dest': '~/.zshrc'})
ok: [18.191.236.195] => (item={'src': '.zshrc', 'dest': '~/.zshrc'})
ok: [3.137.199.13] => (item={'src': '.vimrc', 'dest': '~/.vimrc'})
ok: [18.118.1.37] => (item={'src': '.vimrc', 'dest': '~/.vimrc'})
ok: [18.191.236.195] => (item={'src': '.vimrc', 'dest': '~/.vimrc'})
ok: [3.137.199.13] => (item={'src': '.bashrc', 'dest': '~/.bashrc'})
ok: [18.118.1.37] => (item={'src': '.bashrc', 'dest': '~/.bashrc'})
ok: [18.191.236.195] => (item={'src': '.bashrc', 'dest': '~/.bashrc'})

TASK [configs : Add API Keys to .zshrc] *******************************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [configs : Install Oh My ZSH] ************************************************************************************************************
ok: [3.137.199.13]
ok: [18.191.236.195]
ok: [18.118.1.37]

TASK [configs : change user shell to zsh] *****************************************************************************************************
ok: [3.137.199.13]
ok: [18.118.1.37]
ok: [18.191.236.195]

TASK [configs : Generate SSH Key Pair] ********************************************************************************************************
ok: [18.118.1.37]
ok: [18.191.236.195]
ok: [3.137.199.13]

TASK [golang : Download go {{go.version}} tar file for linux-{{ go.arch }}] *******************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [golang : Delete previous go installation] ***********************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [golang : Extract tar file to {{ go.root }}/go] ******************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [golang : Delete downloaded tar file] ****************************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [fs : Update /etc/fstab] *****************************************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [repos : Clone Repositories] *************************************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [nfs : Install NFS Server Packages] ******************************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [nfs : Update NFS Exports File] **********************************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [nfs : Export NFS Shares] ****************************************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [nfs : Mount NFS Devices to Local Filesystem] ********************************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [k3s : Check if cmdline.txt exists] ******************************************************************************************************
ok: [18.191.236.195]
ok: [3.137.199.13]
ok: [18.118.1.37]

TASK [k3s : Append cgroup settings to cmdline.txt only if absent] *****************************************************************************
skipping: [18.191.236.195]
skipping: [3.137.199.13]
skipping: [18.118.1.37]

TASK [k3s : meta] *****************************************************************************************************************************

TASK [k3s : meta] *****************************************************************************************************************************

TASK [k3s : meta] *****************************************************************************************************************************

TASK [k3s : Download K3S installer] ***********************************************************************************************************
changed: [3.137.199.13]
changed: [18.118.1.37]
changed: [18.191.236.195]

TASK [k3s : Execute the K3S Installer] ********************************************************************************************************
skipping: [3.137.199.13]
skipping: [18.118.1.37]
changed: [18.191.236.195]

TASK [k3s : Get K3S Node Token] ***************************************************************************************************************
changed: [18.191.236.195]

TASK [k3s : Join K3s Cluster as Node] *********************************************************************************************************
skipping: [18.191.236.195]
changed: [3.137.199.13]
changed: [18.118.1.37]

TASK [k3s : Remove the K3S Installer] *********************************************************************************************************
changed: [18.191.236.195]
changed: [18.118.1.37]
changed: [3.137.199.13]

TASK [k3s : Get K3S Kubeconfig] ***************************************************************************************************************
changed: [18.191.236.195]

TASK [k3s : Update Local Ansible Host Kubeconfig with multiple replacements] ******************************************************************
changed: [18.191.236.195 -> localhost] => (item={'regexp': '127\\.0\\.0\\.1', 'replace': '10.0.101.197'})
changed: [18.191.236.195 -> localhost] => (item={'regexp': '\\bdefault\\b', 'replace': 'k3s'})

TASK [k3s : Decode the CA certificate from Kubeconfig] ****************************************************************************************
changed: [18.191.236.195 -> localhost]


PLAY RECAP ************************************************************************************************************************************
18.118.1.37                : ok=11   changed=3    unreachable=0    failed=0    skipped=16   rescued=0    ignored=0   
18.191.236.195             : ok=16   changed=7    unreachable=0    failed=0    skipped=16   rescued=0    ignored=0   
3.137.199.13               : ok=11   changed=3    unreachable=0    failed=0    skipped=16   rescued=0    ignored=0   

```
The K3s Cluster should now be available at the IP you configured as the `K3sAdmin`: https://18.191.236.195:6443  

If you are running this ansible locally a copy of the authenticated Kube Config will dowload to `~/.kube/k3sconfig`


# Pulumi