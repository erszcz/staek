#!/bin/bash

MARMOT=/Users/erszcz/work/maxpert/marmot.release/marmot

cleanup() {
    kill "$job"
}

trap cleanup EXIT

case "$1" in
"desktop")
        $MARMOT -config marmot/config.desktop.toml -cluster-addr localhost:4221 -cluster-peers 'nats://localhost:4222/' &
        job=$!
        ;;
"web")
        $MARMOT -config marmot/config.web.toml -cluster-addr localhost:4222 -cluster-peers 'nats://localhost:4221/' &
        job=$!
        ;;
*)
        echo "unknown node: $1"
        exit 1
esac

wait $job
