#!/usr/bin/env bash
set -euo pipefail
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT

#
# copy over files from phillips (full) to hera
#  20190509 WF ACP  init

find /Volumes/Phillips/mMR_PETDA/subjs/*/background_connectivity -iname '*NAcc*' -or -iname '*VTA*' -or -iname '*Caudate*' -or -iname '*Putamen*'  |
 sed 's:/Volumes/Phillips/mMR_PETDA/subjs/::' > tx_list_20190509.txt


rsync --progress --size-only -avhi /Volumes/Phillips/mMR_PETDA/subjs/  /Volumes/Hera/Projects/mMR_PETDA/subjs/ --files-from=tx_list_20190509.txt
