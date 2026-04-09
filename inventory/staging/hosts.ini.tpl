# Généré automatiquement par le workflow GitHub Actions — ne pas éditer manuellement
# Mode : instances web et db séparées

[webservers]
web01 ansible_host=__WEB_IP__

[dbservers]
db01 ansible_host=__DB_IP__

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
