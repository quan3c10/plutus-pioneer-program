#!/bin/bash
#Require variables:
#name: the name of user => use to find the wallet address to transfer the ADA to contract
#txin: transaction hash of UTXO will use + #index

#in case xxd does not work, please install vim and vim-common package
#apt-get update
#apt-get install apt-file -y
#apt-file update
#apt-get install vim -y
#apt install vim-common -y
policyid=$(cat "policy/policyId")
slot=$(cat "policy/policy.script" | grep slot | cut -d ':' -f 2)

generate_meta_data() {

    meta="governance/$1.json"
    realtokenname=$1
    ipfs_hash=$4
    description=$3
    name=$2
    tokenname=$(echo -n $realtokenname | xxd -b -ps -c 80 | tr -d '\n')
    #k51qzi5uqu5dgizwwls0lqv697i7l1mb8vylcmk04orpfyqayjlcl19a6ts4m8

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
