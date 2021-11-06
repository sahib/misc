#!/bin/bash

set -euo pipefail
set -x

compile_with_include() {
    local include_path="$1"
    local output_dir="pdfs/$(basename ${1/.inc/})"
    sed "s#<<PLACEHOLDER>>#${include_path}#g" urkunde.tex > urkunde.tmp
    latexmk -gg -xelatex -outdir="$output_dir" urkunde.tmp
    rm urkunde.tmp
}

if [ -z "${1:-}" ]; then
    for inc_file in $(find -iname '*.inc'); do
        echo "-- $inc_file"
        compile_with_include "$inc_file"
    done
else
    compile_with_include "$1"
fi
