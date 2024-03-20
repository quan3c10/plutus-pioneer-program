#!/bin/bash
name="quanuh"
addr_file="/workspace/wallets/$name/add.addr"
# echo "Address is: $(cat $addr_file)"
query_add(){
    cardano-cli query utxo --address "$(cat $addr_file)" --testnet-magic 2
}

# query_add