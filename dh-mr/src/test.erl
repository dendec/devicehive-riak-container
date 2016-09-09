-module(test).

-export([get_keys/3, reduce/2]).

get_keys(RiakObject, KeyData, none) ->
    get_keys(RiakObject, KeyData, <<>>);
get_keys(RiakObject, _KeyData, Prefix) ->
    Size = byte_size(Prefix),    
    case riak_object:get_value(RiakObject) of
        <<Prefix:Size/binary, _Value/binary>> ->
            [[{riak_object:key(RiakObject), riak_object:get_value(RiakObject)}]];
        _Value ->
            []
    end.

reduce(List, _Arg) ->
    [{guitars, List}, {num, length(List)}].
