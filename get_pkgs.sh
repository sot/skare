#!/bin/bash

while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ ${line:0:1} != '#' ]]; then
        cp /proj/sot/ska/pkgs/${line} pkgs/
    fi
done < "cut.manifest"
