#!/bin/bash

source /workspace/scripts/generate-nft-meta.sh

smaddr=$(cat ./governance/global-config.json | jq -r '.data.generalState.address')
tokenname=$(cat ./governance/global-config.json | jq -r '.data.generalNftPrefix')
confpath="./governance/global-config.json"

#Get governace information to know which SM add to spend token
get_global_config() {
    if [ -f $confpath ]; then
        rm -rf $confpath
    fi

    touch $confpath

    curl https://club-bff.dev.tekoapis.net/api/v1/club/get-global-config >$confpath
}

populate_nft_meta_data() {
    generate_meta_data $(jq -r .$token <<<$token_list) $token $token k51qzi5uqu5dgizwwls0lqv697i7l1mb8vylcmk04orpfyqayjlcl19a6ts4m8
}

populate_datum() {
    generate_meta_data $(jq -r .$token <<<$token_list) $token $token k51qzi5uqu5dgizwwls0lqv697i7l1mb8vylcmk04orpfyqayjlcl19a6ts4m8
}