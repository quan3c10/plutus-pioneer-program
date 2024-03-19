#!/bin/bash
#Require variables:
#name: the name of user => use to find the wallet address to transfer the ADA to contract
#txin: transaction hash of UTXO will use + #index
wallet=/workspace/wallets
assets=/workspace/assets
governance=/workspace/governance
policy=/workspace/policy
addpath="$wallet/quanuh"

address="$(cat $addpath/add.addr)"
txbody="$assets/body.txbody"
tx="$assets/tranx.tx"
script=$policy/policy.script
meta="$governance/metadata.json"

#in case xxd does not work, please install vim and vim-common package
#apt-get update
#apt-get install apt-file -y
#apt-file update
#apt-get install vim -y
#apt install vim-common -y
txin="76e8a43154fb1a7cbc593ec5303abce7a021faaf5ded5cdaaa0671bba727f03e#1"
txburn="f53d3271fd9f54aa6be632bb2c1f9b3893232e9cf5c78280db5402cb6370b64d#0"
policyid=$(cat "policy/policyId")
slot=$(cat "policy/policy.script" | grep slot | cut -d ':' -f 2)
# slot=$(expr $(cardano-cli query tip --testnet-magic 2 | jq .slot?) + 100000)
realtokenname="Quanuh NFT"
tokenname=$(echo -n $realtokenname | xxd -b -ps -c 80 | tr -d '\n')
tokenamount="1"
fee="0"
minfee="1400000"
burnfee="1225831"
ipfs_hash="k51qzi5uqu5dgizwwls0lqv697i7l1mb8vylcmk04orpfyqayjlcl19a6ts4m8"
description="This is my first NFT thanks to the Cardano foundation"
name="Cardano foundation NFT guide token"

generate_meta() {

    if [ -f "$meta" ]; then
        echo "remove old meta-data file"
        rm -rf $meta
    fi

    touch $meta

    echo "{" >>$meta
    echo "  \"721\": {" >>$meta
    echo "    \"$policyid\": {" >>$meta
    echo "      \"$(echo $realtokenname)\": {" >>$meta
    echo "        \"description\": \"$(echo $description)\"," >>$meta
    echo "        \"name\": \"$(echo $name)\"," >>$meta
    echo "        \"id\": \"1\"," >>$meta
    echo "        \"image\": \"$(echo $ipfs_hash)\"" >>$meta
    echo "      }" >>$meta
    echo "    }" >>$meta
    echo "  }" >>$meta
    echo "}" >>$meta

    echo "wrote meta data to: $meta"
}

# echo "Build command:\
#         cardano-cli transaction build \
#         --testnet-magic 2 \
#         --alonzo-era \
#         --tx-in $txin \
#         --tx-out $address+$minlove+"$tokenamount $policyid.$tokenname" \
#         --change-address $address \
#         --mint="$tokenamount $policyid.$tokenname" \
#         --minting-script-file $script \
#         --metadata-json-file $meta \
#         --invalid-hereafter $slot \
#         --witness-override 2 \
#         --out-file '$txbody'
# "

mint_nft() {
    cardano-cli transaction build \
        --testnet-magic 2 \
        --alonzo-era \
        --tx-in $txin \
        --tx-out $address+$minfee+"$tokenamount $policyid.$tokenname" \
        --change-address $address \
        --mint="$tokenamount $policyid.$tokenname" \
        --minting-script-file $script \
        --metadata-json-file $meta \
        --invalid-hereafter $slot \
        --witness-override 2 \
        --out-file "$txbody"
}

burn_nft() {
    cardano-cli transaction build \
    --testnet-magic 2 \
    --alonzo-era \
    --tx-in $txburn \
    --tx-out $address+$burnfee \
    --mint="-$tokenamount $policyid.$tokenname" \
    --minting-script-file $script \
    --change-address $address \
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

# generate_meta

# mint_nft

burn_nft

sign_tx

submit_tx