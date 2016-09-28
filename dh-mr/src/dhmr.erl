%%% @doc DeviceHive map reduce functions
-module(dhmr).

-export([map_values/3, reduce_filter/2, reduce_sort/2, reduce_offset_with_limit/2]).

%% @doc json decode of existed object's value
map_values(Object, _Keydata, _Arg) ->
	case dict:find(<<"X-Riak-Deleted">>, riak_object:get_metadata(Object)) of
		{ok, "true"} -> [];
		_ -> 
			{struct, Value} = mochijson2:decode(riak_object:get_value(Object)),
			[Value]
	end.

%% @doc Data filtration. Argument is a list with three elements: parameter to filter, operator and value 
reduce_filter(List, Arg) ->
	case Arg of
		[ParamName, Operator, Value] ->
			case string:to_lower(binary_to_list(Operator)) of
				"=" -> reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 == V2 end);
				">" -> reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 > V2 end);
				"<" -> reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 < V2 end);
				">=" -> reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 >= V2 end);
				"<=" -> reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 =< V2 end);
				"!=" -> reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 =/= V2 end);
				"regex" -> reduce_filter(List, ParamName, Value, fun(Val, Regex) -> case re:run(Val, Regex) of {match, _} -> true; nomatch -> false end end)
			end
	end.

reduce_filter(List, ParamName, Value, Comparator) ->
	lists:filter(fun(Object) -> Comparator(proplists:get_value(ParamName, Object), Value) end, List).

%% @doc Data sorting. Argument is a list with two elements: parameter name and order {asc, desc}
reduce_sort(List, Arg) -> 
	case Arg of
		[ParamName, Order] ->
			case string:to_lower(binary_to_list(Order)) of 
				"asc" -> lists:sort(fun(O1, O2) -> proplists:get_value(ParamName, O1) < proplists:get_value(ParamName, O2) end, List);
				"desc" -> lists:sort(fun(O1, O2) -> proplists:get_value(ParamName, O1) > proplists:get_value(ParamName, O2) end, List)
			end
	end.

%% @doc Data pagination. Argument is a list with two elements: offset and limit
reduce_offset_with_limit(List, Arg) -> 
	case Arg of
		[Offset, Limit] -> lists:sublist(List, Offset, Limit)
	end.
