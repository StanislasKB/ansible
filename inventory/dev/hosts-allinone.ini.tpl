# Mode : Laravel + MySQL sur la même instance

[webservers]
app01 ansible_host=__WEB_IP__

[dbservers]
app01 ansible_host=__WEB_IP__

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
