#!/bin/bash
if [ -z "$1" ] 
then
    echo "Saves data from file to riak"
    echo "Usage: $0 INPUT_FILE"
    exit 1
fi
INPUT_FILE=$1
for DATA in $(cat $INPUT_FILE); do
    curl -XPOST localhost:8098/types/default/buckets/TestBucket/keys -H 'Content-Type: application/json' -d $DATA
done
