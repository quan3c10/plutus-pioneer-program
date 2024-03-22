#!/bin/bash

source scripts/query-danogo-club-config.sh
metapath="/workspace/governance/metadata.json"

metadata=$(jq -r '.data | with_entries( select(.key|contains("operatorNftMetadata")))' $confpath)
label=""
tokenname=$(jq -r '.data | with_entries( select(.key|contains("operatorNftPrefix"))) | values[]' $confpath)
name=""
image=""
description=""
policyid=$(cardano-cli transaction policyid --script-file "/workspace/datum/policy-script.plutus")

populate_token_meta_data() {

    label=$(jq -r '.data.operatorNftMetadata | with_entries( select(.key|contains("label"))) | values[]' $confpath)
    name=$(jq -r '.data.operatorNftMetadata | with_entries( select(.key|contains("name"))) | [.[][]]' /workspace/governance/global-config.json)
    echo $name
    image=$(jq -r '.data.operatorNftMetadata | with_entries( select(.key|contains("image")))' $confpath)
    description=$(jq -r '.data.operatorNftMetadata | with_entries( select(.key|contains("description")))' $confpath)
    test=$(jq -r --arg labeltk "$label" '. | with_entries( select(.key|contains($labeltk))) | if . == {} then true else false end' $metapath)
    echo $test
    if [[ "$test" = true ]]; then
        build_label_json
    else
        build_token_json
    fi
}

build_token_json() {
    # echo "$tokenname:$name,$image,$description"
    echo "{"
    echo "  \"$policyid\": {"
    echo "    \"$tokenname\": {"
    echo "      \"$description\","
    echo "      \"$name\","
    echo "      \"$image\","
    echo "    }"
    echo "  }"
    echo "}"
}

build_label_json() {
    # echo "$label: {$policyid:{$(build_token_json)}"
    echo "{"
    echo "  \"$label\": {"
    echo "    \"21\": {"
    echo "      \"$(echo 22)\": {"
    echo "        \"description\": \"$(echo 23)\","
    echo "        \"name\": \"$(echo 24)\","
    echo "        \"id\": \"1\","
    echo "        \"image\": \"$(echo 25)\""
    echo "      }"
    echo "    }"
    echo "  }"
    echo "}"
}

add_new_key() {
    jq -S --arg values "$(build_label_json)" '. |= . + {"$label":$values}' $metapath
}

add_exist_key() {
    jq -S --arg values "$(build_token_json)" '.$label |= .$label + {$values}' $metapath
}

# get_global_config

populate_token_meta_data
