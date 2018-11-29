#!/bin/sh
erl -pa _build/default/deps/erl_json_test/ebin -pa _build/default/deps/*/ebin \
    -s erl_json_test
