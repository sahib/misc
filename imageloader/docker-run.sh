#!/usr/bin/sh

mkdir -p /usr/src/app/images/by-name
cd /usr/src/app/images/by-name

echo "-- Serving files from" $(pwd)
echo "-- Please visit localhost:8000 to view the pictures"
python -m http.server --bind 0.0.0.0 8000 &

while true; do
    echo "-- Downloading images..."
    python /usr/src/app/loader.py /usr/src/app/example.urls
    sleep 5m
done
