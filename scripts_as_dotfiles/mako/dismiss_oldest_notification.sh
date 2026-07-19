#!/usr/bin/env bash

oldest_id=$(makoctl list | grep -oP 'Notification \K\d+' | sort -n | head -1)
makoctl dismiss -n "$oldest_id"
