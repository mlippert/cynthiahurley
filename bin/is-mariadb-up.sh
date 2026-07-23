#! /usr/bin/env bash

LINES=$(podman ps --filter name=cynthiahurley_chw-mariadb --filter status=running | wc --lines)

# 1 line is just the header, so no containers match the filter, 2 lines means we found 1 match
if (( $LINES == 2 )); then exit 0; else exit 1; fi
