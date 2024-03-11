#!/bin/bash
if [ -z "$1" ]; then
    >&2 echo "expected name as argument"
    exit 1
fi

addr_file="/workspace/wallets/$1/add.addr"
echo "Address is: $(cat $addr_file)"
cardano-cli query utxo --address "$(cat $addr_file)" --testnet-magic 2