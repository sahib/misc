#!/bin/bash

set -euo pipefail

if ! git diff-index --quiet HEAD --; then
    echo "-- refusing to do something; there are uncommitted changes."
    exit 1
fi

git checkout gh-pages

rm -rf ./*
git checkout master -- bierbogen/{beer,bier}.pdf
git checkout master -- shell/slides

git add .
git commit -am 'updated gh-pages via script' --allow-empty
git push --force origin gh-pages

git checkout -f master
