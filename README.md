# Ansible Laravel - Automated Deployment

## Project Structure

```
ansible/
├── ansible.cfg
├── .gitignore
├── inventory/
│   ├── dev/
│   │   ├── group_vars/
│   │   │   ├── all/
│   │   │   │   ├── main.yml           # Shared variables (non-sensitive)
│   │   │   │   └── vault_template.yml # Secrets template (do not fill in)
│   │   │   ├── webservers/
│   │   │   │   └── main.yml           # Nginx, PHP, Laravel env config
│   │   │   └── dbservers/
│   │   │       └── main.yml           # MySQL config
│   │   ├── hosts.ini.tpl              # Inventory template - separate instances
│   │   └── hosts-allinone.ini.tpl     # Inventory template - all-in-one
│   ├── staging/                       # Same structure as dev
│   └── prod/                          # Same structure as dev
├── playbooks/
│   ├── deploy.yml                     # Web + DB on separate instances
│   ├── deploy-allinone.yml            # Web + DB on the same instance
│   └── redeploy.yml                   # Laravel code only (no infra changes)
└── roles/
    ├── common/       # System packages, timezone, NTP
    ├── database/     # MySQL, database and user creation
    ├── php/          # PHP-FPM, Composer
    ├── webserver/    # Nginx, Laravel vhost
    ├── laravel/      # Clone repo, .env, migrations, cache
    └── certbot/      # SSL Let's Encrypt (optional)
```

## Deployment Modes

### All-in-one mode - Laravel + MySQL on the same instance
```bash
ansible-playbook -i inventory/staging/hosts.ini playbooks/deploy-allinone.yml [options]
```

### Separate mode - web and db on distinct instances
```bash
ansible-playbook -i inventory/staging/hosts.ini playbooks/deploy.yml [options]
```

The deployment mode is controlled by the GitHub Variable `DEPLOY_MODE`: `allinone` or `separated`.

## Secrets - Required GitHub Secrets

| Secret | Description |
|---|---|
| `EC2_SSH_PRIVATE_KEY` | SSH private key to connect to instances |
| `GITHUB_TOKEN` | Token to clone the private Laravel repository |
| `LARAVEL_REPO_OWNER` | GitHub owner of the Laravel repository |
| `LARAVEL_REPO_NAME` | Name of the Laravel repository |
| `LARAVEL_APP_KEY` | Laravel app key (`php artisan key:generate --show`) |
| `DB_PASSWORD` | Laravel MySQL user password |
| `DB_ROOT_PASSWORD` | MySQL root password |
| `CERTBOT_EMAIL` | Let's Encrypt email (if SSL enabled) |
| `MAIL_USERNAME` | SMTP username |
| `MAIL_PASSWORD` | SMTP password |

## GitHub Variables (non-sensitive)

| Variable | Values | Description |
|---|---|---|
| `DEPLOY_MODE` | `allinone` / `separated` | Deployment mode |
| `DB_NAME` | `...` | Database name |
| `DB_USERNAME` | `...` | Database username |
| `CERTBOT_ENABLED` | `true` / `false` | Enable SSL via Let's Encrypt |

## Manual Deployment

```bash
# Install Ansible dependencies
pip install ansible
ansible-galaxy collection install community.mysql community.general

# Generate the inventory from your instance IPs
sed \
  -e 's/__WEB_IP__/1.2.3.4/g' \
  -e 's/__DB_IP__/5.6.7.8/g' \
  inventory/staging/hosts.ini.tpl > inventory/staging/hosts.ini

# Run the playbook with secrets
ansible-playbook \
  -i inventory/staging/hosts.ini \
  playbooks/deploy.yml \
  -e "vault_github_token=ghp_XXX" \
  -e "vault_laravel_app_key=base64:XXX" \
  -e "vault_db_password=XXX" \
  -e "vault_db_root_password=XXX" \
  -e "vault_certbot_email=email@example.com" \
  -e "vault_mail_username=XXX" \
  -e "vault_mail_password=XXX" \
  -e "laravel_repo_owner=my-org" \
  -e "laravel_repo_name=my-repo" \
  -e "db_host=127.0.0.1"
```

## Best Practices

- No secrets in committed files - everything via GitHub Secrets or `-e`
- Inventories generated dynamically from Terraform outputs
- `ansible-vault` not required in CI/CD - secrets injected directly
- Idempotent: `storage:link` uses `creates`, migrations use `--force`
- `no_log: true` on MySQL user creation tasks
- Certbot is optional via the `certbot_enabled` variable
- Clear separation between dev / staging / prod
```