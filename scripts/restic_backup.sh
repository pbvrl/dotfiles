#!/usr/bin/env bash

RESTIC_REPO=~/restic-repo

if [ ! -d "$RESTIC_REPO" ]; then
    restic init --repo "$RESTIC_REPO"
fi

restic backup ~/projects ~/notes ~/.config/nixos /var/lib/sops-nix/key.txt --repo "$RESTIC_REPO" \
  --exclude='*/.venv' \
  --exclude='*/node_modules' \
  --exclude='*.iso' \
  --compression max

restic forget --prune --group-by '' \
  --keep-daily 5 --keep-weekly 3 --keep-monthly 4 --keep-yearly 3 --repo "$RESTIC_REPO"
