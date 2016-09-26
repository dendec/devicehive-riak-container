#!/bin/bash
docker stop devicehiveriak_coordinator_1
docker rm devicehiveriak_coordinator_1
docker rmi devicehive/riak-ts
docker-compose up -d coordinator
