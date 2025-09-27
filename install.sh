#!/bin/bash
set -e

# --- System update ---
sudo apt-get update
sudo apt-get upgrade -y

# --- Audio + tools ---
sudo apt-get install -y \
  jackd2 \
  zita-njbridge \
  alsa-utils \
  git \
  build-essential \
  shairport-sync \
  raspotify \
  sonobus \
  jack-mixer

# --- Boot overlays ---
CONFIG=/boot/firmware/config.txt
grep -q "dtoverlay=disable-bt" $CONFIG || echo "dtoverlay=disable-bt" | sudo tee -a $CONFIG
grep -q "allo-boss-dac-pcm512x-audio" $CONFIG || echo "dtoverlay=allo-boss-dac-pcm512x-audio" | sudo tee -a $CONFIG

# If dtoverlay=vc4-kms-v3d is present, make sure it has ,noaudio
if grep -q "^dtoverlay=vc4-kms-v3d" "$CONFIG"; then
    sudo sed -i 's/^dtoverlay=vc4-kms-v3d\(.*\)/dtoverlay=vc4-kms-v3d\1,noaudio/' "$CONFIG"
else
    echo "dtoverlay=vc4-kms-v3d,noaudio" | sudo tee -a "$CONFIG"
fi

echo "Install complete. Reboot, then enable services."
