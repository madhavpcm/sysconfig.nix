# sysconfig.nix

Heavily inspired from https://unmovedcentre.com/posts/anatomy-of-a-nixos-config/

## Setup sops.nix
Ensure you can clone sops directory, if not edit `flake.nix:50` to manually place a sops directory.

Create a sops directory in the following manner
```
├── README.md
├── secrets.yaml
└── .sops.yaml
```

### .sops.yaml

This file contains the directives to encrypt and decrypt secrets. We specify users and hosts' keys which can unlock the secrets.
If install was successful, then there should be a private key in `~/.config/sops/age/keys.txt`, which will be used by default to decrypt.

Since we already added that key and hosts key to our password manager, on first install, use one of those and, place it in appropriate location to decrypt.

Or when creating a new host, use the newly generated keys found /etc/ssh/. Ensure that ssh server nix pkg is installed (forgot).

#FIXME: update docs for sops while creating fresh install new host.

```yaml
keys:
  - &hosts:
    - &zenhammer <ssh_pubkey>
    - &zenhammer_age <agekey_from_ssh_pubkey>
  - &users:
    - &madhavpcm <ssh_pubkey>
    - &madhavpcm_age <agekey_from_ssh_pubkey>

creation_rules:
  - path_regex: secrets.yaml$
    key_groups:
    - age:
      - *madhavpcm
      - *zenhammer
      - *zenhammer_age
      - *madhavpcm_age
  - path_regex: tmp.yml$
    key_groups:
    - age:
      - *zenhammer_age
      - *madhavpcm_age
      - *madhavpcm
      - *zenhammer
```

### secrets.yaml
Has data like:

```
keys:
    user: <private_age_key>    
passwords:
    user: <etc_password_hash>
```

## Install
### Setup a host

Copy `./hosts/nixos/zenhammer` to `./hosts/nixos/<new_host>`
Edit required modules as in `./hosts/common/`


Install `sudo nixos-rebuild switch --flake .#new_host`

### Setup home-manager

Copy `./home/madhavpcm` to `./home/<new_user>`
Edit required submodules as in `./home/madhavpcm/common`

Install: `home-manager switch --flake .#new_user@new_host`
