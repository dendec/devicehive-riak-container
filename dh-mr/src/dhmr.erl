%%% @doc DeviceHive map reduce functions
-module(dhmr).

-export([map_values/3, reduce_filter/2, reduce_sort/2, reduce_offset_with_limit/2]).

%% @doc json decode of existed object's value
map_values(Object, _Keydata, _Arg) ->
    case dict:find(<<"X-Riak-Deleted">>, riak_object:get_metadata(Object)) of
        {ok, "true"} ->
            [];
        _ ->
            {struct, Value} = mochijson2:decode(riak_object:get_value(Object)),
            [Value]
    end.

%% @doc Data filtration. Argument is a list with three elements: parameter to filter, operator and value 
reduce_filter(List, [ParamName, Operator, Value]) ->
    case string:to_lower(binary_to_list(Operator)) of
        "=" ->
            reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 == V2 end);
        ">" ->
            reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 > V2 end);
        "<" ->
            reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 < V2 end);
        ">=" ->
            reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 >= V2 end);
        "<=" ->
            reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 =< V2 end);
        "!=" ->
            reduce_filter(List, ParamName, Value, fun(V1, V2) -> V1 =/= V2 end);
        "regex" ->
            reduce_filter(List, ParamName, Value,
                          fun(Val, Regex) ->
                              case re:run(Val, Regex) of
                                  {match, _} -> true;
                                  nomatch -> false
                              end
                          end)
    end.

reduce_filter(List, ParamName, Value, Comparator) ->
    FilerFun = fun(Object) ->
        case get_value(ParamName, Object) of
            undefined -> false;
            ObjectValue -> Comparator(ObjectValue, Value)
        end
    end,
    lists:filter(FilerFun, List).

%% @doc Data sorting. Argument is a list with two elements: parameter name and order {asc, desc}
reduce_sort(List, [ParamName, Order]) ->
    case string:to_lower(binary_to_list(Order)) of
        "asc" ->
            lists:sort(fun(O1, O2) ->
                           get_value(ParamName, O1) < proplists:get_value(ParamName, O2)
                       end, List);
        "desc" ->
            lists:sort(fun(O1, O2) ->
                           get_value(ParamName, O1) > proplists:get_value(ParamName, O2)
                       end, List)
    end.

%% @doc Data pagination. Argument is a list with two elements: offset and limit
reduce_offset_with_limit(List, [Offset, Limit]) ->
    lists:sublist(List, Offset, Limit).

get_value(Property, Object) ->
    get_value_from_tokens(string:tokens(binary_to_list(Property), "."), Object).

get_value_from_tokens([H | T], Object) ->
    case proplists:get_value(list_to_binary(H), Object) of
        {struct, SubObject} ->
            get_value_from_tokens(T, SubObject);
        undefined ->
            undefined;
        SubObject ->
            get_value_from_tokens([], SubObject)
    end;
get_value_from_tokens([], Object) ->
    Object.
