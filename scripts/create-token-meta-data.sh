#!/bin/bash

source scripts/query-danogo-club-config.sh

token_list=$(cat $confpath | jq -r '.data | with_entries( select(.key|contains("Metadata")))')
tokennames=$($token_list | jq -r '. | keys[]')
echo $tokennames

populate_token_meta_data() {

    for token in $tokennames; do
        echo $token
        # generate_meta_data $(jq -r .$token <<<$token_list) $token $token k51qzi5uqu5dgizwwls0lqv697i7l1mb8vylcmk04orpfyqayjlcl19a6ts4m8
    done
}

# get_global_config

# populate_token_meta_data