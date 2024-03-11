#!/bin/bash

path="policy"
mkdir -p "$path"

vkey="$path/policy.vkey"
skey="$path/policy.skey"
script="$path/policy.script"
policyid="$path/policyId"

generate_policy() {

    touch $script

    echo "{" >>$script
    echo "  \"type\": \"all\"," >>$script
    echo "  \"scripts\":" >>$script
    echo "  [" >>$script
    echo "   {" >>$script
    echo "     \"type\": \"before\"," >>$script
    echo "     \"slot\": $(expr $(cardano-cli query tip --testnet-magic 2 | jq .slot?) + 10000)" >>$script
    echo "   }," >>$script
    echo "   {" >>$script
    echo "     \"type\": \"sig\"," >>$script
    echo "     \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"" >>$script
    echo "   }" >>$script
    echo "  ]" >>$script
    echo "}" >>$script

    echo "wrote policy script to: $script"
}

if [ ! -f "$vkey" ] || [ ! -f "$skey" ]; then
    echo >&2 "generate verification key file $vkey"
    cardano-cli address key-gen --verification-key-file "$vkey" --signing-key-file "$skey"
fi

if [ ! -f "$script" ]; then
    generate_policy
fi

if [ ! -f "$policyid" ]; then
    echo "cardano-cli transaction policyid --script-file $script > $policyid"
    cardano-cli transaction policyid --script-file $script >$policyid
    echo "policyid: $(cat $policyid) was wrote to: $policyid"
fi
