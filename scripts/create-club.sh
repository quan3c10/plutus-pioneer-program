#!/bin/bash
source /workspace/scripts/generate-nft-meta.sh
source /workspace/scripts/query-address.sh
source /workspace/scripts/calculate-fee.sh
#Required variables
wallet=/workspace/wallets
assets=/workspace/assets
policy=/workspace/policy
addpath="$wallet/quanuh"
addr_file="$wallet/quanuh/add.addr"
# generalMintScript="/workspace/datum/policy-script.plutus"
# policyid=$(cardano-cli transaction policyid --script-file $refscript)
policyid=$(cat "/workspace/policy/policyId")
generalMintScript="/workspace/policy/policy.script"
protocol="governance/protocol.json"
opaddr=$(cat $addr_file)
txin=$(query_add | sort -k2 -nr | head -n 1 | awk '{ print $1,"#",$2 }' | tr -d ' ')
collateralTx=aeeb5f67c747dcc82ac806f4ba563fbc5b2a9bff7489ef36a043cc9920c847a1#0
txbody="$assets/club.txbody"
tx="$assets/clubtx.tx"
fee=0
min_req_utxo="5000000"
generaldatum="/workspace/datum/general-state.json"
tradingdatum="/workspace/datum/trading.json"
navdatum="/workspace/datum/nav.json"
depositdatum="/workspace/datum/deposit.json"
withdrawdatum="/workspace/datum/withdraw.json"
reference=$(cat ./governance/global-config.json | jq -r '.data | with_entries( select(.key|contains("governanceOutRef"))) | values[]')

#Build transaction as below:
#Mint all require token with format that documented at https://confluence.teko.vn/pages/viewpage.action?spaceKey=NIO&title=UTxO+diagram#UTxOdiagram-C.ListTokens
#Spent token to SM and OP wallet
transfer_to_generalState() {

    generalStateSM=$(cat ./governance/global-config.json | jq -r '.data.generalState.address')
    tradingStateSM=$(cat ./governance/global-config.json | jq -r '.data.tradingState.address')
    navStateSM=$(cat ./governance/global-config.json | jq -r '.data.navState.address')
    depositStateSM=$(cat ./governance/global-config.json | jq -r '.data.depositState.address')
    withdrawStateSM=$(cat ./governance/global-config.json | jq -r '.data.withdrawState.address')
    generaltoken=$(cat ./governance/global-config.json | jq -r '.data.generalNftPrefix')
    tradingtoken=$(cat ./governance/global-config.json | jq -r '.data.tradingNftPrefix')
    navtoken=$(cat ./governance/global-config.json | jq -r '.data.navNftPrefix')
    deposittoken=$(cat ./governance/global-config.json | jq -r '.data.depositStateNftPrefix')
    withdrawtoken=$(cat ./governance/global-config.json | jq -r '.data.withdrawStateNftPrefix')
    optoken=$(cat ./governance/global-config.json | jq -r '.data.operatorNftPrefix')

    cardano-cli transaction build-raw \
        --babbage-era \
        --tx-in $txin \
        --simple-script-tx-in-reference $reference \
        --mint "1 $policyid.$generaltoken + 1 $policyid.$tradingtoken" \
        --mint-script-file $generalMintScript \
        --metadata-json-file /workspace/governance/$generaltoken.json \
        --tx-out "$generalStateSM + $min_req_utxo lovelace + 1 $policyid.$generaltoken" \
        --tx-out-inline-datum-file $generaldatum \
        --tx-out "$tradingStateSM + $min_req_utxo lovelace + 1 $policyid.$tradingtoken" \
        --tx-out-inline-datum-file $tradingdatum \
        --protocol-params-file $protocol \
        --fee $fee \
        --out-file "$txbody"
}

sign_tx() {
    # Sign the transaction
    cardano-cli transaction sign \
        --tx-body-file "$txbody" \
        --signing-key-file "$addpath/private.skey" \
        --signing-key-file "$policy/policy.skey" \
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
# get_global_config

# populate_token_meta_data

transfer_to_generalState

fee=$(calculate-min-fee | awk '{ print $1}')
echo "Estimate fee is: $fee"

transfer_to_generalState

sign_tx

submit_tx