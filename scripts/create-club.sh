#!/bin/bash
source /workspace/scripts/generate-nft-meta.sh
#Required variables
wallet=/workspace/wallets
assets=/workspace/assets
policy=/workspace/policy
addpath="$wallet/quanuh"
refscript="/workspace/datum/policy-script.plutus"
policyid=$(cardano-cli transaction policyid --script-file $refscript)
opaddr=$(cat $addpath/add.addr)
txin=08a991b09c1abb1537a61b0fb265f110e84629f8b2823f46666484be40840b2e#2
txbody="$assets/club.txbody"
tx="$assets/clubtx.tx"
amount=20
minlove="23687760"
slot=$(expr $(cardano-cli query tip --testnet-magic 2 | jq .slot?) + 10000)
confpath="./governance/global-config.json"
token_list=$(cat ./governance/global-config.json | jq -r '.data | with_entries( select(.key|contains("Prefix")))')
tokennames=$(cat ./governance/global-config.json | jq -r '.data | with_entries( select(.key|contains("Prefix"))) | keys[]')
generaldatum="/workspace/datum/general-state.json"
tradingdatum="/workspace/datum/trading.json"
navdatum="/workspace/datum/nav.json"
depositdatum="/workspace/datum/deposit.json"
withdrawdatum="/workspace/datum/withdraw.json"
reference="d7dfc348ce291b976e72a8e8ac4a5ce8287bf444936e11ad094b7f7fe5225533#0"

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
    smaddr="addr_test1xplte6dn2wlznasgd4eanr6aq5dfqmjkz8kr0hr63vgqxfp63zxktut8jz2s5uk6ac0k82s94htdy6zrgyrulfdkwufq5tha9z"
    generaltoken=$(cat ./governance/global-config.json | jq -r '.data.generalNftPrefix')
    tradingtoken=$(cat ./governance/global-config.json | jq -r '.data.tradingNftPrefix')
    navtoken=$(cat ./governance/global-config.json | jq -r '.data.navNftPrefix')
    deposittoken=$(cat ./governance/global-config.json | jq -r '.data.depositStateNftPrefix')
    withdrawtoken=$(cat ./governance/global-config.json | jq -r '.data.withdrawStateNftPrefix')
    optoken=$(cat ./governance/global-config.json | jq -r '.data.operatorNftPrefix')

    cardano-cli transaction build \
        --testnet-magic 2 \
        --babbage-era \
        --tx-in $txin \
        --simple-script-tx-in-reference $reference \
        --mint="1 $policyid.$generaltoken" \
        --minting-script-file $refscript \
        --metadata-json-file /workspace/governance/$generaltoken.json \
        --tx-out-inline-datum-file $generaldatum \
        --tx-out-reference-script-file $refscript \
        --tx-out $smaddr+$minlove+"1 $policyid.$generaltoken" \
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