#!/bin/bash

while true; do
    sleep 5

    # Get system playback ports
    PLAY1="system:playback_1"
    PLAY2="system:playback_2"

    # List all JACK output ports
    OUTPUTS=$(jack_lsp | grep -E ':[Oo]ut(_[0-9]+)?$')

    for PORT in $OUTPUTS; do
        case "$PORT" in
            *out_1|*out0) 
                jack_connect "$PORT" "$PLAY1" 2>/dev/null || true
                ;;
            *out_2|*out1) 
                jack_connect "$PORT" "$PLAY2" 2>/dev/null || true
                ;;
        esac
    done
done
