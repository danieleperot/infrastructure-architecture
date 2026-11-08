## Infrastructure architecture

A repository to configure my remote infrastructure. 

## Requirements
* `python`, at least 3.13
* `pre-commit`, at least 4.3.0 (`uvx pre-commit` installs it)
* `ansible`, at least 2.21.6
* [optional] `ansible-lint`, at least 26.11.0
* `tailscale`, with your machine onboarded to the same network as the nodes

## First things first
Start by installing pre-commit hooks, which primarily protects you from
committing unencrypted var files:

```bash
pre-commit install --install-hooks
```

If you need to edit encrypted files, use `ansible-vault edit path/to/file.yml`,
using the Bitwarden password "Ansible Vault - infrastructure architecture".

Install the required ansible roles and collections with:
```bash
ansible-galaxy install -r requirements.yml
```

## Onboarding a new VM

All VMs are assumed to be running Alma Linux 10 (or RHEL compatible OS).

0. Make sure your SSH public key is uploaded to the VM `root` user, so that the
    setup doesn't require you to add passwords. We'll disable SSH access later.
1. Add the host to `inventory/production/hosts.yml`:
    ```diff
    nodes:
      hosts:
    +    [host]:
    +      # the ansible_host is used to do most of the Ansible configuration
    +      # via Tailscale, so that we don't need to expose SSH
    +      ansible_host: [host].[tailnet].ts.net
    + 
    +      # in order to bootstrap Tailscale, we also need to indicate what's
    +      # the public IP / host of the machine
    +      boostrap_host: [ip or domain]
    ```
2. Copy an existing `host_vars/[host].yml`, and fill it according to the
    instructions reported in the file comments. 
    Remember! Use `ansible-vault` to encrypt the file.
3. Run the first playbook to install and connect the node to Tailscale:
    ```bash
    ansible-playbook playbooks/tailscale.yml --limit [host]
    ```
    `--limit` is optional. 
4. Next, start onboarding the node by configuring the rest of the services:
    ```bash
    ansible-playbook playbooks/onboard-vm.yml --limit [host]
    ```
    `--limit` is optional. 

