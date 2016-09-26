#!/bin/bash
if [ -z "$1" ] 
then
    echo "Executes riak map function"
    echo "Usage: $0 MODULE FUNCTION [ARGUMENT]"
    exit 1
fi
MODULE=$1
FUNC=$2
ARG=$3
if [ -z "$ARG" ] 
then
    curl -XPOST localhost:8098/mapred -H 'Content-Type: application/json' -d '{"inputs":"TestBucket","query":[{"map":{"language":"erlang","module":"'$MODULE'","function":"'$FUNC'"}}]}'
else
    curl -XPOST localhost:8098/mapred -H 'Content-Type: application/json' -d '{"inputs":"TestBucket","query":[{"map":{"language":"erlang","module":"'$MODULE'","function":"'$FUNC'", "arg": '$ARG'}}]}'
fi
echo
