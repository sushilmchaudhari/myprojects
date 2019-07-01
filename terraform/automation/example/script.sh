#!/usr/bin/env bash

set -ex

cur_dir=`pwd`

count=1

for i in `echo ${APPS}`
do
    printf "%-30s\t %s\n" "$i" "${ENV}.app$count.nfg.org"
    (( count++ ))
done

count=1

for i in `echo ${WORKERS}`
do
    printf "%-30s\t %s\n" "$i" "${ENV}.worker$count.nfg.org"
    (( count++ ))
done
