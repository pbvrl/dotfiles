#!/usr/bin/env bash

# Decrypt, edit, and encrypt secrets

export SOPS_AGE_KEY_FILE="$HOME/.config/secretkey/sops_private_key.txt"
sops --config ~/.config/nixos/secrets/.sops.yaml ~/.config/nixos/secrets/secrets.yaml
