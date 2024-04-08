#!/bin/bash
source /workspace/scripts/generate-nft-meta.sh
source /workspace/scripts/query-address.sh
source /workspace/scripts/calculate-fee.sh
source /workspace/scripts/calculate-min-required-utxo.sh
#Required variables
wallet=/workspace/wallets
assets=/workspace/assets
policy=/workspace/policy
addpath="$wallet/quanuh"
addr_file="$wallet/quanuh/add.addr"
global_config_file="./governance/global-config.json"
mintScriptFile="/workspace/policy/policy-script.plutus"
policyid=$(cardano-cli transaction policyid --script-file $mintScriptFile)
protocol="governance/protocol.json"
opaddr=addr_test1vrzwaqg46hg8uvyywq2yq8jdecdh0gaua8lkqv22menmhpq9j6wud
# txin=$(query_add | sort -k2 -nr | head -n 1 | awk '{ print $1,"#",$2 }' | tr -d ' ')
txin=1918c4bc99cffde4ef786d7762b412faffb703d999bd0d4664093a875969738a#0
collateralTx=aeeb5f67c747dcc82ac806f4ba563fbc5b2a9bff7489ef36a043cc9920c847a1#0
outref=$(query_add | sort -k2 -nr | head -n 1 | awk '{ print $1 }' | tr -d ' ')
txbody="$assets/club.txbody"
tx="$assets/clubtx.tx"
min_req_utxo="1500000"
generaldatum="/workspace/datum/general-state.json"
tradingdatum="/workspace/datum/trading.json"
navdatum="/workspace/datum/nav.json"
depositdatum="/workspace/datum/deposit.json"
withdrawdatum="/workspace/datum/withdraw.json"
metadata="/workspace/governance/op-metadata.json"
redeemer="/workspace/policy/create-club.json"
reference=$(jq -r '.data | with_entries( select(.key|contains("governanceOutRef"))) | values[]' $global_config_file)
slot=$(cardano-cli query tip --testnet-magic 2 | jq .slot?)

#Build transaction as below:
#Mint all require token with format that documented at https://confluence.teko.vn/pages/viewpage.action?spaceKey=NIO&title=UTxO+diagram#UTxOdiagram-C.ListTokens
#Spent token to SM and OP wallet
transfer_to_generalState() {

    generalStateSM=$(jq -r '.data.generalState.address' $global_config_file)
    tradingStateSM=$(jq -r '.data.tradingState.address' $global_config_file)
    navStateSM=$(jq -r '.data.navState.address' $global_config_file)
    depositStateSM=$(jq -r '.data.depositState.address' $global_config_file)
    withdrawStateSM=$(jq -r '.data.withdrawState.address' $global_config_file)
    generaltoken=$(jq -r '.data.generalNftPrefix' $global_config_file)
    tradingtoken=$(jq -r '.data.tradingNftPrefix' $global_config_file)
    navtoken=$(jq -r '.data.navNftPrefix' $global_config_file)
    deposittoken=$(jq -r '.data.depositStateNftPrefix' $global_config_file)
    withdrawtoken=$(jq -r '.data.withdrawStateNftPrefix' $global_config_file)
    optoken=$(jq -r '.data.operatorNftPrefix' $global_config_file)

    # cardano-cli transaction build \
    #     --babbage-era \
    #     --testnet-magic 2 \
    #     --tx-in $txin \
    #     --tx-in-collateral $collateralTx \
    #     --simple-script-tx-in-reference $reference \
    #     --metadata-json-file $metadata \
    #     --protocol-params-file $protocol \
    #     --mint "1 $policyid.$generaltoken + 1 $policyid.$tradingtoken + 1 $policyid.$navtoken + 1 $policyid.$deposittoken + 1 $policyid.$withdrawtoken + 1 $policyid.$optoken" \
    #     --mint-script-file $mintScriptFile \
    #     --mint-redeemer-value 1 \
    #     --tx-out "$generalStateSM + 24381670 lovelace + 1 $policyid.$generaltoken" \
    #     --tx-out-inline-datum-file $generaldatum \
    #     --tx-out-reference-script-file $mintScriptFile \
    #     --tx-out "$tradingStateSM + 1374890 lovelace + 1 $policyid.$tradingtoken" \
    #     --tx-out-inline-datum-file $tradingdatum \
    #     --tx-out "$navStateSM + 1340410 lovelace + 1 $policyid.$navtoken" \
    #     --tx-out-inline-datum-file $navdatum \
    #     --tx-out "$depositStateSM + 1327480 lovelace + 1 $policyid.$deposittoken" \
    #     --tx-out-inline-datum-file $depositdatum \
    #     --tx-out "$withdrawStateSM + 1327480 lovelace + 1 $policyid.$withdrawtoken" \
    #     --tx-out-inline-datum-file $withdrawdatum \
    #     --tx-out "$opaddr + 9875715202 lovelace + 1 $policyid.$optoken" \
    #     --tx-out-return-collateral "$opaddr +  3000000 lovelace" \
    #     --change-address $opaddr \
    #     --witness-override 2 \
    #     --invalid-before $slot \
    #     --out-file "$txbody"

    cardano-cli transaction build-raw \
        --babbage-era \
        --tx-in $txin \
        --tx-in-collateral $collateralTx \
        --simple-script-tx-in-reference $reference \
        --metadata-json-file $metadata \
        --protocol-params-file $protocol \
        --mint "1 $policyid.$generaltoken + 1 $policyid.$tradingtoken + 1 $policyid.$navtoken + 1 $policyid.$deposittoken + 1 $policyid.$withdrawtoken + 1 $policyid.$optoken" \
        --mint-script-file $mintScriptFile \
        --mint-redeemer-value 01 \
        --mint-execution-units "(324209254, 801053)" \
        --tx-out "$generalStateSM + 24398910 lovelace + 1 $policyid.$generaltoken" \
        --tx-out-inline-datum-file $generaldatum \
        --tx-out-reference-script-file $mintScriptFile \
        --tx-out "$tradingStateSM + 1392130 lovelace + 1 $policyid.$tradingtoken" \
        --tx-out-inline-datum-file $tradingdatum \
        --tx-out "$navStateSM + 1357650 lovelace + 1 $policyid.$navtoken" \
        --tx-out-inline-datum-file $navdatum \
        --tx-out "$depositStateSM + 1344720 lovelace + 1 $policyid.$deposittoken" \
        --tx-out-inline-datum-file $depositdatum \
        --tx-out "$withdrawStateSM + 1344720 lovelace + 1 $policyid.$withdrawtoken" \
        --tx-out-inline-datum-file $withdrawdatum \
        --tx-out "$opaddr + 9874829002 lovelace + 1 $policyid.$optoken" \
        --tx-out-return-collateral "$opaddr +  3000000 lovelace" \
        --fee 800000 \
        --invalid-before $slot \
        --out-file "$txbody"

    # cardano-cli transaction build-raw \
    #     --babbage-era \
    #     --tx-in $txin \
    #     --tx-in-collateral $collateralTx \
    #     --mint "1 $policyid.$generaltoken + 1 $policyid.$tradingtoken + 1 $policyid.$navtoken + 1 $policyid.$deposittoken + 1 $policyid.$withdrawtoken + 1 $policyid.$optoken" \
    #     --mint-script-file $mintScriptFile \
    #     --mint-redeemer-value 1 \
    #     --mint-execution-units "(324209254, 801053)" \
    #     --simple-script-tx-in-reference $reference \
    #     --metadata-json-file $metadata \
    #     --protocol-params-file $protocol \
    #     --tx-out "$generalStateSM + 24381670 lovelace + 1 $policyid.$generaltoken" \
    #     --tx-out-inline-datum-file $generaldatum \
    #     --tx-out-reference-script-file $mintScriptFile \
    #     --tx-out "$tradingStateSM + 1374890 lovelace + 1 $policyid.$tradingtoken" \
    #     --tx-out-inline-datum-file $tradingdatum \
    #     --tx-out "$navStateSM + 1340410 lovelace + 1 $policyid.$navtoken" \
    #     --tx-out-inline-datum-file $navdatum \
    #     --tx-out "$depositStateSM + 1327480 lovelace + 1 $policyid.$deposittoken" \
    #     --tx-out-inline-datum-file $depositdatum \
    #     --tx-out "$withdrawStateSM + 1327480 lovelace + 1 $policyid.$withdrawtoken" \
    #     --tx-out-inline-datum-file $withdrawdatum \
    #     --tx-out "$opaddr + 3697439076 lovelace + 1 $policyid.$optoken \
    #     + 1 26690c4811f4b7bdf355e985391f5bc637d3236b470b8a12b34d0359.8686868601 \
    #     + 1 6fe6355622b22a32370330643729f33522b9856a1aa2f90f296801b5.000de14001 \
    #     + 1 9b84a6c0c32c55fa0e151c3222f46462faad5a6fdc7b1cda7c191658.000de14001 \
    #     + 300000000 9b84a6c0c32c55fa0e151c3222f46462faad5a6fdc7b1cda7c191658.0014df10200001018dcb2d6b80 \
    #     + 1 a92ed40170d8f42342bc417a44eb9eb135389ff20bcd973856c858cf.000de14001 \
    #     + 1 cbb66f334ed0ea76afd4cc1cf2ad5f7fcced59fe82b99355dd95ae83.8686868601 \
    #     + 1 df66fc1a560fee0500d1dd4502c0b2dc6d8686a470af5db1070807d9.8686868601 \
    #     + 1 dfce8d05f20b1318ba48ea1cb67f900b3e39c31b7aaf9ba29c722847.8686868601 \
    #     + 1 ee3168728ccb49179cc1db5f88e724a8913fd7716f7a4cc233a81cb9.8686868601" \
    #     --tx-out-return-collateral "$opaddr +  3727191006 lovelace \
    #     + 1 26690c4811f4b7bdf355e985391f5bc637d3236b470b8a12b34d0359.8686868601 \
    #     + 1 6fe6355622b22a32370330643729f33522b9856a1aa2f90f296801b5.000de14001 \
    #     + 1 9b84a6c0c32c55fa0e151c3222f46462faad5a6fdc7b1cda7c191658.000de14001 \
    #     + 300000000 9b84a6c0c32c55fa0e151c3222f46462faad5a6fdc7b1cda7c191658.0014df10200001018dcb2d6b80 \
    #     + 1 a92ed40170d8f42342bc417a44eb9eb135389ff20bcd973856c858cf.000de14001 \
    #     + 1 cbb66f334ed0ea76afd4cc1cf2ad5f7fcced59fe82b99355dd95ae83.8686868601 \
    #     + 1 df66fc1a560fee0500d1dd4502c0b2dc6d8686a470af5db1070807d9.8686868601 \
    #     + 1 dfce8d05f20b1318ba48ea1cb67f900b3e39c31b7aaf9ba29c722847.8686868601 \
    #     + 1 ee3168728ccb49179cc1db5f88e724a8913fd7716f7a4cc233a81cb9.8686868601" \
    #     --fee 749381 \
    #     --invalid-before $slot \
    #     --out-file $txbody
}

sign_tx() {
    # Sign the transaction
    cardano-cli transaction sign \
        --tx-body-file "$txbody" \
        --signing-key-file "$addpath/private.skey" \
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

# min_req_utxo=$(calculate-min-required-utxo | awk '{ print $2}')
# echo "Estimate min utxo is: $min_req_utxo"

transfer_to_generalState

sign_tx

submit_tx
