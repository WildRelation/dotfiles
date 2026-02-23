#!/usr/bin/env bash
SINK="alsa_output.pci-0000_00_1f.3.analog-stereo"

# Set default back to analog
pactl set-default-sink "$SINK"

# Move all active streams
for input in $(pactl list short sink-inputs | awk '{print $1}'); do
  pactl move-sink-input $input "$SINK"
done

