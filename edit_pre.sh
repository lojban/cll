#!/bin/sh
ROOT="."
FILE=`grep -r -l '<pre>' "$ROOT"/* | head -n 1`
LINE=`grep -n '<pre>' "$FILE" | cut -d ':' -f 1`

vim "$FILE" +"$LINE"
