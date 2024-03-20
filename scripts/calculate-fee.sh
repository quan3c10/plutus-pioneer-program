#!/bin/bash
calculate-min-fee() {
    cardano-cli transaction calculate-min-fee \
    --tx-body-file $txbody \
    --tx-in-count 1 \
    --tx-out-count 2 \
    --witness-count 1 \
    --byron-witness-count 0 \
    --testnet-magic 2 \
    --protocol-params-file $protocol
}
