#!/bin/bash

source scripts/query-danogo-club-config.sh
metapath="/workspace/governance/metadata.json"

metadatas=$(cat $confpath | jq -r '.data | with_entries( select(.key|contains("Metadata"))) | keys[]')
label=""
tokenname=""
name=""
image=""
description=""
policyid=$(cardano-cli transaction policyid --script-file "/workspace/datum/policy-script.plutus")

populate_token_meta_data() {

    for meta in $metadatas; do
        label=$(jq -r --arg meta "$meta" '.data | with_entries( select(.key|contains($meta))) | values[] | with_entries( select(.key|contains("label"))) | values[]' $confpath)
        tokenname=$(jq -r --arg meta "$meta" '.data | with_entries( select(.key|contains($meta))) | values[] | with_entries( select(.key|contains("name"))) | values[]' $confpath)
        name=$(jq -r --arg meta "$meta" '.data | with_entries( select(.key|contains($meta))) | values[] | with_entries( select(.key|contains("name"))) | values[]' $confpath)
        image=$(jq -r --arg meta "$meta" '.data | with_entries( select(.key|contains($meta))) | values[] | with_entries( select(.key|contains("image"))) | values[]' $confpath)
        description=$(jq -r --arg meta "$meta" '.data | with_entries( select(.key|contains($meta))) | values[] | with_entries( select(.key|contains("description"))) | values[]' $confpath)
        echo $label
        test=$(jq --arg labeltk "$label" '. | with_entries( select(.key|contains($labeltk))) | if . == {} then true else false end' $metapath)
        if [[ "$test" = true ]]; then
            build_label_json
        else
            build_token_json
        fi
        # generate_meta_data $(jq -r .$token <<<$token_list) $token $token k51qzi5uqu5dgizwwls0lqv697i7l1mb8vylcmk04orpfyqayjlcl19a6ts4m8
    done
}

build_token_json(){
    echo "$tokenname:{$name,$image,$description}"
}

build_label_json(){
    echo "$label: {$policyid:$(build_token_json)}"
}

add_new_key(){
    jq -S --arg values "$(build_label_json)" '. |= . + {"$label":$values}' $metapath
}

add_exist_key(){
    jq -S --arg values "$(build_token_json)" '.$label |= .$label + {$values}' $metapath
}

# get_global_config

populate_token_meta_data
