#!/bin/bash

convert() {
  local src_path="$1"
  local dst_path="$2"
  local rotation="${3:-5}"
  local text="${4:-5}"
  magick "${src_path}" -resize 1500x1500 \
    -font 'TT2020-Style-E' -pointsize 50 \
    -bordercolor '#ffffea' -background white -fill black -gravity center -set caption "${text}" \
    -polaroid "${rotation}" \
    \( +clone -background '#999' -shadow 100x25+11+11 \) +swap -background none -layers merge +repage \
    "${dst_path}" &
}

convert images/bible.jpg images/polaroid/bible.png -5 "His bible\!"
convert images/prophet.jpg images/polaroid/prophet.png 5 "The prophet\!"
convert images/brass_bars.jpg images/polaroid/brass_bars.png +15 "Bars in the HMS SCEPTRE"
convert images/occam.png images/polaroid/occam.png +10 "»When faced with two equally good hypothesis, always choose the simpler«"
convert images/duck.jpg images/polaroid/duck.png -10 "Quack, quack."
wait
