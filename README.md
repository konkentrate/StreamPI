# StreamPI

StreamPI is a Raspberry Pi audio platform that integrates JACK audio, AirPlay (via Shairport Sync), Spotify Connect (via Raspotify), and network audio tools. It provides a flexible audio routing environment using JACK, with scripts and services for automatic patching and device management.

## Features

- JACK audio server with auto-patching for common clients (SonoBus, Zita, Shairport, Raspotify)
- AirPlay support via Shairport Sync
- Spotify Connect support via Raspotify
- Network audio bridging with Zita
- Automatic installation of required overlays and services
- Headless SonoBus setup

## Installation

```bash
git clone https://github.com/konkentrate/StreamPI.git
cd StreamPI
chmod +x install.sh
./install.sh
```

The install script will:
- Update your system and install all required packages
- Install Raspotify using the official script
- Download and install the SonoBus AppImage (headless)
- Configure Raspberry Pi overlays for audio
- Reboot your system

**After reboot:**  
Copy the service (`.service`) files from the `services` directory to `/etc/systemd/system/` and the scripts (`.sh`) from the `scripts` directory to `/usr/local/bin/`, then enable and start the services.  
Example:
```bash
sudo cp services/*.service /etc/systemd/system/
sudo systemctl enable shairport.service
sudo systemctl start shairport.service
```
Do the same for other `.service` files as needed.

## TODO

- [x] JackD Audio Server
- [x] Zita Instance
- [x] Jack Patcher (should be working with all instances as long as they are active / working properly)
- [x] Jack Autopatcher testing ...
- [x] Raspotify (make work with Jack instead of Alsa)
- [ ] Sonobus Testing + Integration
- [ ] AirPlay Testing + Integration