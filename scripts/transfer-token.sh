#!/bin/bash
#Require variables:
#name: the name of user => use to find the wallet address to transfer the ADA to contract
#txin: transaction hash of UTXO will use + #index
wallet=/workspace/wallets
assets=/workspace/assets
from="$wallet/$1"
to="$wallet/$2"
txin="$3"
amount="$4"
txbody="$assets/body.txbody"
tx="$assets/tranx.tx"

echo "Build command: \
        cardano-cli transaction build \
        --babbage-era \
        --testnet-magic 2 \
        --tx-in "$txin" \
        --tx-out $(cat "$to/add.addr") + $(($amount * 1000000)) lovelace \
        --change-address $(cat "$from/add.addr") \
        --out-file "$txbody"
        "

# Build the transaction
build_tx() {
    cardano-cli transaction build \
        --babbage-era \
        --testnet-magic 2 \
        --tx-in "$txin" \
        --tx-out "$(cat "$to/add.addr") + $(($amount * 1000000)) lovelace" \
        --change-address "$(cat "$from/add.addr")" \
        --out-file "$txbody"
}

sign_tx() {
    # Sign the transaction
    cardano-cli transaction sign \
        --tx-body-file "$txbody" \
        --signing-key-file "$from/private.skey" \
        --testnet-magic 2 \
        --out-file "$tx"
}

submit_tx() {
    # Submit the transaction
    cardano-cli transaction submit \
        --testnet-magic 2 \
        --tx-file "$tx"

    tid=$(cardano-cli transaction txid --tx-file "$tx")
    echo "transaction id: $tid"
    echo "Cardanoscan: https://preview.cardanoscan.io/transaction/$tid"
}
