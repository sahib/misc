#!/bin/bash

show_keys() {
    while read line; do
        if [ -z "$line" ]; then
            continue
        fi

        if [[ $line == \#* ]]; then
            continue
        fi


        echo $line
    done
}

show_keys2() {
    grep -v '^$' | grep -v '^#'
}

cat dummy-config.txt | show_keys | sort
