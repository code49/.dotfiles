#!/usr/bin/env bash

set -eu

# Let the compositor and display stack finish resuming before reloading state.
sleep 1

hyprctl dispatch dpms on || true
