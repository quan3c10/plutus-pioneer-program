#!/bin/bash
source /workspace/scripts/generate-nft-meta.sh
#Required variables
wallet=/workspace/wallets
assets=/workspace/assets
policy=/workspace/policy
addpath="$wallet/quanuh"
policyid=$(cat "policy/policyId")
opaddr=$(cat $addpath/add.addr)
txin=f53d3271fd9f54aa6be632bb2c1f9b3893232e9cf5c78280db5402cb6370b64d#1
txbody="$assets/club.txbody"
tx="$assets/clubtx.tx"
amount=20
minlove="1400000"
slot=$(expr $(cardano-cli query tip --testnet-magic 2 | jq .slot?) + 10000)
confpath="./governance/global-config.json"
token_list=$(cat ./governance/global-config.json | jq -r '.data | with_entries( select(.key|contains("Prefix")))')
tokennames=$(cat ./governance/global-config.json | jq -r '.data | with_entries( select(.key|contains("Prefix"))) | keys[]')
datum="/workspace/datum/general-state.json"
reference="/workspace/datum/policy-script.plutus"

#Get governace information to know which SM add to spend token
get_global_config() {
    if [ -f $confpath ]; then
        rm -rf $confpath
    fi

    touch $confpath

    curl https://club-bff.dev.tekoapis.net/api/v1/club/get-global-config >$confpath
}

populate_token_meta_data() {

    for token in $tokennames; do
        generate_meta_data $(jq -r .$token <<<$token_list) $token $token k51qzi5uqu5dgizwwls0lqv697i7l1mb8vylcmk04orpfyqayjlcl19a6ts4m8
    done
}

#Build transaction as below:
#Mint all require token with format that documented at https://confluence.teko.vn/pages/viewpage.action?spaceKey=NIO&title=UTxO+diagram#UTxOdiagram-C.ListTokens
#Spent token to SM and OP wallet
transfer_to_generalState() {

    # smaddr=$(cat ./governance/global-config.json | jq -r '.data.generalState.address')
    smaddr="addr_test1xrtly8cuhmuvhpjk9jkytjn9g3tk85n7tg4q5dwl4aa50vf63zxktut8jz2s5uk6ac0k82s94htdy6zrgyrulfdkwufqy0m7rm"
    tokenname=$(cat ./governance/global-config.json | jq -r '.data.generalNftPrefix')

    cardano-cli transaction build \
        --testnet-magic 2 \
        --alonzo-era \
        --tx-in $txin \
        --mint="1 $policyid.$tokenname" \
        --minting-script-file $policy/policy.script \
        --metadata-json-file /workspace/governance/$tokenname.json \
        --tx-out-inline-datum-cbor-file $datum \
        --tx-out-reference-script-file ./assets/alwaysTrueV2.plutus \
        --tx-out $smaddr+$minlove+"1 $policyid.$tokenname" \
        --tx-out $smaddr+"$(($amount * 1000000)) lovelace" \
        --change-address $opaddr \
        --invalid-hereafter $slot \
        --witness-override 2 \
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

# sign_tx

# submit_tx