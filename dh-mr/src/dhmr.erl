-module(dhmr).

-export([map_values/3, reduce_identity/2, reduce_filter/2]).

map_values(Object, _Keydata, _Arg) ->
  case dict:find(<<"X-Riak-Deleted">>, riak_object:get_metadata(Object)) of
    {ok, "true"} -> [];
    _ -> 
      {struct, Value} = mochijson2:decode(riak_object:get_value(Object)),
      [Value]
  end.

reduce_identity(List, _) ->
  List.

reduce_filter(List, Arg) ->
	case Arg of
		[Param_name, Operator, Value] -> 
			case binary_to_list(Operator) of 
				"=" -> reduce_filter(List, Param_name, Value, fun(V1, V2) -> V1 == V2 end);
				">" -> reduce_filter(List, Param_name, Value, fun(V1, V2) -> V1 > V2 end);
				"<" -> reduce_filter(List, Param_name, Value, fun(V1, V2) -> V1 < V2 end);
				">=" -> reduce_filter(List, Param_name, Value, fun(V1, V2) -> V1 >= V2 end);
				"<=" -> reduce_filter(List, Param_name, Value, fun(V1, V2) -> V1 =< V2 end);
				"!=" -> reduce_filter(List, Param_name, Value, fun(V1, V2) -> V1 =/= V2 end)
			end
	end.

reduce_filter(List, Param_name, Value, Comparator) ->
	lists:filter(fun(Object) -> Comparator(proplists:get_value(Param_name, Object), Value) end, List).