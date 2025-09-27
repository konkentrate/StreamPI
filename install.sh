#!/bin/bash
set -e

CONFIG=/boot/firmwware/config.txt

echo "==== StreamPi Install ===="

# --- 1. System update ---
sudo apt-get update
sudo apt-get upgrade -y

# --- 2. Install packages ---
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

# --- 3. Boot overlays ---

# Disable onboard Bluetooth
grep -q "dtoverlay=disable-bt" $CONFIG || echo "dtoverlay=disable-bt" | sudo tee -a $CONFIG

# Disable onboard audio
grep -q "dtparam=audio=off" $CONFIG || echo "dtparam=audio=off" | sudo tee -a $CONFIG

# Enable Allo Boss DAC overlay
grep -q "allo-boss-dac-pcm512x-audio" $CONFIG || echo "dtoverlay=allo-boss-dac-pcm512x-audio" | sudo tee -a $CONFIG

# Add noaudio to vc4-kms-v3d overlay
if grep -q "^dtoverlay=vc4-kms-v3d" "$CONFIG"; then
    sudo sed -i 's/^dtoverlay=vc4-kms-v3d\(.*\)/dtoverlay=vc4-kms-v3d\1,noaudio/' "$CONFIG"
else
    echo "dtoverlay=vc4-kms-v3d,noaudio" | sudo tee -a "$CONFIG"
fi

# --- 4. Configure shairport-sync for JACK ---
sudo tee /etc/shairport-sync.conf >/dev/null <<EOF
general = {
    name = "StreamPi-AirPlay";
};

output_backend = "jack";

jack = {
  output_rate = 44100;
};
EOF

# --- 5. Configure Raspotify for JACK (44.1kHz PCM) ---
sudo sed -i '/^OPTIONS=/d' /etc/default/raspotify || true
echo 'OPTIONS="--name StreamPi --backend jack --format S16 --device-type speaker --bitrate 320"' | sudo tee -a /etc/default/raspotify >/dev/null

# --- 6. Reminder ---
echo "==== Install complete. Reboot, then enable StreamPi services. ===="
