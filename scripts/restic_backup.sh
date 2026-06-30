#!/usr/bin/env bash

RESTIC_REPO=~/restic-repo

if [ ! -d "$RESTIC_REPO" ]; then
    restic init --repo "$RESTIC_REPO"
fi

restic backup ~/projects ~/notes ~/.config/nixos ~/.config/secretkey/sops_private_key.txt --repo "$RESTIC_REPO" \
  --exclude='*/.venv' \
  --exclude='*/node_modules' \
  --exclude='*.iso' \
  --compression max

restic forget --prune --keep-daily 3 --keep-weekly 3 --keep-yearly 1 --repo "$RESTIC_REPO"
