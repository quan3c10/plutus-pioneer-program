#!/bin/bash

if [ -z "$1" ]; then
    >&2 echo "expected name as argument"
    exit 1
fi

path=/workspace/wallets
mkdir -p "$path/$1"

vkey="$path/$1/public.vkey"
skey="$path/$1/private.skey"
addr="$path/$1/add.addr"

if [ -f "$vkey" ]; then
    >&2 echo "verification key file $vkey already exists"
    exit 1
fi

if [ -f "$skey" ]; then
    >&2 echo "signing key file $skey already exists"
    exit 1
fi

if [ -f "$addr" ]; then
    >&2 echo "address file $addr already exists"
    exit 1
fi

cardano-cli address key-gen --verification-key-file "$vkey" --signing-key-file "$skey" &&
cardano-cli address build --payment-verification-key-file "$vkey" --testnet-magic 2 --out-file "$addr"

echo "wrote verification key to: $vkey"
echo "wrote signing key to: $skey"
echo "wrote address to: $addr"