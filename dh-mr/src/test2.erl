-module(test2).

-export([map_test/3, map_kv/3, map_select_arg/3, map_age_more_than_arg/3, reduce_identity/2]).

map_test(Object, _Keydata, _Arg) ->
  [[{test1, _Arg == [1, 2, 3]}, {test2, _Arg == {struct,[{<<"name">>,<<"Alex">>}]}}, {key, riak_object:key(Object)}, {test, <<"zzz">>}]].
  
map_kv(Object, _Keydata, _Arg) ->
  case dict:find(<<"X-Riak-Deleted">>, riak_object:get_metadata(Object)) of
    {ok, "true"} -> test3:map_empty(Object, _Keydata, _Arg);
    _ -> [[{key, riak_object:key(Object)}, {value, mochijson2:decode(riak_object:get_value(Object))}]]
  end.

map_select_arg(Object, _Keydata, Arg) ->
  {struct, Map} = mochijson2:decode(riak_object:get_value(Object)),
  case proplists:get_value(Arg, Map) of
    {struct, Result} -> [[{Arg, Result}]];
    undefined -> [];
    Result -> [[{Arg, Result}]]
  end.

map_age_more_than_arg(Object, _Keydata, Arg) ->
  {struct, Map} = mochijson2:decode(riak_object:get_value(Object)),
  Age = proplists:get_value(<<"age">>, Map),
  case Age > Arg of
    true -> [[{key, riak_object:key(Object)}]];
    false -> []
  end.

reduce_identity(List, _) ->
  List.
