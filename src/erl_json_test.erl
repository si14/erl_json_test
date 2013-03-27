-module(erl_json_test).
-export([start/0]).
-define(RESULTS_FILE, "results.csv").
-define(NUM_TESTS, 300).
-define(PARSERS,
        [{"jsonx", fun jsonx:encode/1, fun jsonx:decode/1},
         {"jiffy", fun jiffy:encode/1, fun jiffy:decode/1},
         {"mochijson2", fun mochijson2:encode/1, fun mochijson2:decode/1},
         {"jsx", fun jsx:term_to_json/1, fun jsx:json_to_term/1}]).
-define(TESTFILES,
        [{"1x", "1x.json"},
         {"3x", "3x.json"},
         {"9x", "9x.json"},
         {"27x", "27x.json"},
         {"81x", "81x.json"},
         {"243x", "243x.json"}]).

start() ->
    JSONs = [begin
                 FullName = "priv/" ++ FileName,
                 {ok, File} = file:read_file(FullName),
                 {Name, File}
             end
             || {Name, FileName} <- ?TESTFILES],
    ResultsDeep = [[begin
                        T = {ParserName, TestName, size(JSON),
                             bench(EncFun, DecFun, JSON)},
                        io:format("~s ~s done~n", [ParserName, TestName]),
                        T
                    end
                    || {TestName, JSON} <- JSONs]
                   || {ParserName, EncFun, DecFun} <- ?PARSERS],
    Results = lists:flatten(ResultsDeep),
    format_results(Results),
    init:stop().

bench(EncFun, DecFun, TestJSON) ->
    DecThunk = fun() -> times(DecFun, TestJSON, ?NUM_TESTS) end,
    {DecTime, Decoded} = timer:tc(DecThunk),
    EncThunk = fun() -> times(EncFun, Decoded, ?NUM_TESTS) end,
    {EncTime, _} = timer:tc(EncThunk),
    {EncTime, DecTime}.

format_results(Results) ->
    Header = io_lib:format("\"Parser\","
                           "\"Test\","
                           "\"TestSize\","
                           "\"ResultEnc\","
                           "\"ResultDec\"~n", []),
    Out = [Header |
           [io_lib:format("\"~s\",\"~s (~pb)\",~p,~p,~p~n",
                          [Parser, Test, TestSize, TestSize,
                           round(ResultEnc / ?NUM_TESTS),
                           round(ResultDec / ?NUM_TESTS)])
            || {Parser, Test, TestSize, {ResultEnc, ResultDec}} <- Results]],
    file:write_file(?RESULTS_FILE, lists:flatten(Out)).

times(F, X,  0) -> F(X);
times(F, X, N) -> F(X), times(F, X, N-1).
