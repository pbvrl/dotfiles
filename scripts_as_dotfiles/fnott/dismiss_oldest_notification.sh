#!/usr/bin/env bash
oldest_id=$(fnottctl list | grep -oP '^\K\d+' | sort -n | head -1)
if [ -n "$oldest_id" ]; then
  fnottctl dismiss "$oldest_id"
fi
