#!/bin/bash

path="policy"
mkdir -p "$path"

vkey="$path/policy.vkey"
skey="$path/policy.skey"
script="$path/policy.script"
policyid="$path/policyId"

create_policy_script() {
    rm -rf $path/*
    

    echo >&2 "generate verification key file $vkey"
    cardano-cli address key-gen --verification-key-file "$vkey" --signing-key-file "$skey"

    touch $script

    echo "{" >>$script
    echo "  \"type\": \"all\"," >>$script
    echo "  \"scripts\":" >>$script
    echo "  [" >>$script
    # echo "   {" >>$script
    # echo "     \"type\": \"before\"," >>$script
    # echo "     \"slot\": $(expr $(cardano-cli query tip --testnet-magic 2 | jq .slot?) + 100000)" >>$script
    # echo "   }," >>$script
    echo "   {" >>$script
    echo "     \"type\": \"sig\"," >>$script
    echo "     \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"" >>$script
    echo "   }" >>$script
    echo "  ]" >>$script
    echo "}" >>$script

    echo "wrote policy script to: $script"
}

generate_policy_id() {

    if [ -f "$policyid" ]; then
        rm -rf $policyid
    fi

    cardano-cli transaction policyid --script-file $script >$policyid
    echo "policyid: $(cat $policyid) was wrote to: $policyid"
}

generate_policy_script

generate_policy_id