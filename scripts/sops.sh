#!/usr/bin/env bash

# Decrypt, edit, and encrypt secrets

sudo --preserve-env=HOME,EDITOR SOPS_AGE_KEY_FILE="/var/lib/sops-nix/key.txt" sops --config /home/nixos/.config/nixos/secrets/.sops.yaml /home/nixos/.config/nixos/secrets/secrets.yaml
