#!/usr/bin/env bash
# Select a screen region, OCR it, copy the text to the clipboard.
pidof slurp >/dev/null && exit 0
region="$(slurp)" || exit 0
tmp="$(mktemp --suffix=.png)"
grim -g "$region" "$tmp" || exit 1
langs="$(tesseract --list-langs | awk 'NR>1{print $1}' | paste -sd+)"
tesseract "$tmp" stdout -l "${langs:-eng}" | wl-copy
rm -f "$tmp"
notify-send "Text copied to clipboard" -a OCR
