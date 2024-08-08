#!/bin/bash

MARMOT=/Users/erszcz/work/maxpert/marmot.release/marmot

cleanup() {
    kill "$job1" "$job2"
}

trap cleanup EXIT
rm -rf /tmp/nats
$MARMOT -config marmot/config.desktop.toml -cluster-addr localhost:4221 -cluster-peers 'nats://localhost:4222/' &
job1=$!

sleep 1
$MARMOT -config marmot/config.web.toml -cluster-addr localhost:4222 -cluster-peers 'nats://localhost:4221/' &
job2=$!

wait $job1 $job2
