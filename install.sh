#!/bin/bash
set -e

echo "==== StreamPi Install ===="

# --- 1. System update ---
sudo apt-get update
sudo apt-get upgrade -y

# --- 2. Install packages ---
sudo apt-get install -y \
  jackd2 \
  jack-tools \
  jack-mixer \
  zita-njbridge \
  zita-ajbridge \
  alsa-utils \
  shairport-sync \


# --- 2b. Install Raspotify ---
sudo apt-get -y install curl
curl -sL https://dtcooper.github.io/raspotify/install.sh | sh

# --- 2c. Install Sonobus ---
SONOBUS_URL="https://sonobus.net/releases/SonoBus-1.7.0-armhf.AppImage"
SONOBUS_APPIMAGE="/usr/local/bin/sonobus"

if [ ! -f "$SONOBUS_APPIMAGE" ]; then
    echo "Downloading Sonobus AppImage..."
    sudo curl -L "$SONOBUS_URL" -o "$SONOBUS_APPIMAGE"
    sudo chmod +x "$SONOBUS_APPIMAGE"
fi

# --- 3. Boot overlays ---

CONFIG="/boot/firmware/config.txt"

# Disable onboard Bluetooth
if ! grep -q "dtoverlay=disable-bt" "$CONFIG"; then
    echo "dtoverlay=disable-bt" | sudo tee -a "$CONFIG"
fi

# Disable onboard audio
if ! grep -q "dtparam=audio=off" "$CONFIG"; then
    echo "dtparam=audio=off" | sudo tee -a "$CONFIG"
fi

# Enable Allo Boss DAC overlay
if ! grep -q "allo-boss-dac-pcm512x-audio" "$CONFIG"; then
    echo "dtoverlay=allo-boss-dac-pcm512x-audio" | sudo tee -a "$CONFIG"
fi

# Add noaudio to vc4-kms-v3d overlay
if grep -q "^dtoverlay=vc4-kms-v3d" "$CONFIG"; then
    sudo sed -i 's/^dtoverlay=vc4-kms-v3d\(.*\)/dtoverlay=vc4-kms-v3d\1,noaudio/' "$CONFIG"
else
    echo "dtoverlay=vc4-kms-v3d,noaudio" | sudo tee -a "$CONFIG"
fi

sudo reboot now

# --- 4. Final instructions ---
# Now install the service and script files.