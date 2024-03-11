#!/bin/bash
path=/workspace/governance/protocol.json

if [ ! -f "$path" ]; then
    cardano-cli query protocol-parameters --testnet-magic 2 --out-file governance/protocol.json

    echo "wrote protocol file to: $path"
fi
