#!/bin/bash
calculate-min-required-utxo() {
    cardano-cli transaction calculate-min-required-utxo \
    --babbage-era \
    --tx-out "$opaddr + 1 $policyid.$generaltoken + 1 $policyid.$tradingtoken" \
    --tx-out-inline-datum-file $generaldatum \
    --protocol-params-file $protocol
}
