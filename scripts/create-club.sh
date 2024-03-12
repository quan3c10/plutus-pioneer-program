#!/bin/bash

#Required variables
opaddr=
policy=
txoutpath=
#datum
meta=
txin=
govtx="507e953ece4d897682608f6fa5d5516c6d2c7ac3f4dad9d673a48d0f7c661620#0"
govpath="./governance/datum.json"
confpath="./governance/global-config.json"

#Get governace information to know which SM add to spend token
get_global_config() {
    if [ -f $confpath ]; then
        rm -rf $confpath
    fi

    touch $confpath

    curl https://club-bff.dev.tekoapis.net/api/v1/club/get-global-config > $confpath
}

get_governace() {

    $

    cardano-cli query utxo --tx-in $govtx --testnet-magic 2 --out-file $govpath


}

#Build transaction as below:
#Mint all require token with format that documented at https://confluence.teko.vn/pages/viewpage.action?spaceKey=NIO&title=UTxO+diagram#UTxOdiagram-C.ListTokens
#Spent token to SM and OP wallet


