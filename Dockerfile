FROM basho/riak-ts:1.3.1
MAINTAINER devicehive

ADD ./dh-mr /etc/riak/dh-mr
RUN /usr/lib/riak/$(ls /usr/lib/riak/ | grep erts)/bin/erlc -o /etc/riak/dh-mr/ebin /etc/riak/dh-mr/src/*.erl
RUN echo '[{riak_kv, [{add_paths, ["/etc/riak/dh-mr/ebin"]}]}].' > /etc/riak/advanced.config
