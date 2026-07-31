#!/usr/bin/env bash

# Take a screenshot of a rectangle within the screen

grim -g "$(slurp)" - | swappy -f -
