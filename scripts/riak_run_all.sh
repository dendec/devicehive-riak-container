#!/bin/bash
./riak_docker_restart.sh
sleep 20
./riak_store_data.sh data
./riak_run_map.sh test2 map_kv
./riak_run_map.sh test2 map_select_arg '"name"'
./riak_run_map.sh test2 map_select_arg '"age"'
./riak_run_map.sh test2 map_select_arg '"zzz"'
./riak_run_map.sh test2 map_age_more_than_arg 20
./riak_run_map.sh test2 map_age_more_than_arg 50
