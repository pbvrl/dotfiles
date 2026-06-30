#!/usr/bin/env bash

read -r NAME CURRENT < <(wlr-randr --json | jaq -r '.[] | select(.enabled == true) | "\(.name) \(.transform)"' | head -1)

if [ "$CURRENT" = "normal" ]; then
    wlr-randr --output "$NAME" --transform 270
else
    wlr-randr --output "$NAME" --transform normal
fi
