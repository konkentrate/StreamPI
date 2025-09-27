#!/bin/bash

while true; do
    # Small delay between scans
    sleep 5

    # SonoBus
    jack_connect sonobus:out_1 system:playback_1 2>/dev/null || true
    jack_connect sonobus:out_2 system:playback_2 2>/dev/null || true

    # Zita
    jack_connect zita-n2j:out_1 system:playback_1 2>/dev/null || true
    jack_connect zita-n2j:out_2 system:playback_2 2>/dev/null || true

    # Shairport
    jack_connect shairport-sync:out_0 system:playback_1 2>/dev/null || true
    jack_connect shairport-sync:out_1 system:playback_2 2>/dev/null || true

    # Raspotify (librespot)
    jack_connect librespot:out_0 system:playback_1 2>/dev/null || true
    jack_connect librespot:out_1 system:playback_2 2>/dev/null || true
done
