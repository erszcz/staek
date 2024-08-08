#!/bin/bash

MARMOT=/Users/erszcz/work/maxpert/marmot.release/marmot

cleanup() {
    kill "$job"
}

trap cleanup EXIT

case "$1" in
"desktop")
        echo running marmot desktop
        rm -rf /Users/erszcz/work/erszcz/staek/_build/dev/lib/staek/db/nats/marmot-node-2
        $MARMOT -config marmot/config.desktop.toml -cluster-addr localhost:4221 -cluster-peers 'nats://localhost:4222/' &
        job=$!
        ;;
"web")
        echo running marmot web
        rm -rf /Users/erszcz/work/erszcz/staek/_build/dev/lib/staek/db/nats/marmot-node-1
        $MARMOT -config marmot/config.web.toml -cluster-addr localhost:4222 -cluster-peers 'nats://localhost:4221/' &
        job=$!
        ;;
*)
        echo "unknown node: $1"
        exit 1
esac

wait $job
