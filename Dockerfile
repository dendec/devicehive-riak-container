FROM basho/riak-ts
MAINTAINER devicehive

RUN mkdir /etc/riak/dh-mr && mkdir /etc/riak/dh-mr/ebin
ADD ./dh-mr /etc/riak/dh-mr
RUN /usr/lib/riak/erts-5.10.3/bin/erlc -o /etc/riak/dh-mr/ebin /etc/riak/dh-mr/*.erl
RUN echo '[{riak_kv, [{add_paths, ["/etc/riak/dh-mr/ebin"]}]}].' > /etc/riak/advanced.config
