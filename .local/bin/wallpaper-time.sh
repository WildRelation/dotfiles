#!/bin/bash

WALLDIR="$HOME/Pictures/wallpapers"
HOUR=$(date +%-H)

if [ $HOUR -ge 6 ] && [ $HOUR -lt 12 ]; then
    FOLDER="$WALLDIR/morning"
elif [ $HOUR -ge 12 ] && [ $HOUR -lt 18 ]; then
    FOLDER="$WALLDIR/day"
elif [ $HOUR -ge 18 ] && [ $HOUR -lt 21 ]; then
    FOLDER="$WALLDIR/evening"
else
    FOLDER="$WALLDIR/night"
fi

# Elegir uno aleatorio del periodo
WALL=$(ls "$FOLDER"/*.{jpg,png} 2>/dev/null | shuf -n 1)

echo "$WALL"
