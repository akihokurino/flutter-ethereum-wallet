MAKEFLAGS=--no-builtin-rules --no-builtin-variables --always-make
ROOT := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

init-private-net:
	geth --datadir ./private-net/ init ./private-net/genesis.json

private-net-console:
	geth --networkid "10" --port 8545 --http --nodiscover --datadir ./private-net/ --allow-insecure-unlock console