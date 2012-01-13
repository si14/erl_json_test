#!/bin/sh
erl -pa ebin -pa deps/*/ebin \
    -s erl_json_test
