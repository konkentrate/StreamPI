#!/bin/bash
set -e

CONFIG="/boot/firmware/config.txt"

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

# --- 6. Install systemd services ---
echo "Copying StreamPI service files..."
sudo cp /home/top/Documents/StreamPI/services/*.service /etc/systemd/system/

# Enable and start all StreamPI services
for svc in /home/top/Documents/StreamPI/services/*.service; do
    svcname=$(basename "$svc")
    sudo systemctl enable "$svcname"
    sudo systemctl restart "$svcname"
done

# --- 7. Install scripts ---
echo "Copying StreamPI scripts..."
for script in /home/top/Documents/StreamPI/scripts/*.sh; do
    sudo cp "$script" /usr/local/bin/
    sudo chmod +x "/usr/local/bin/$(basename "$script")"
done

echo "==== Install complete. Reboot, then enable StreamPi services. ===="
