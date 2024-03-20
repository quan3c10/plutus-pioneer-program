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
clubname="Quanuh cardano cli"
refscript="/workspace/datum/policy-script.plutus"
policyid=$(cardano-cli transaction policyid --script-file $refscript)
name=$(echo -n $clubname | xxd -b -ps -c 80 | tr -d '\n')
lockupPeriod=6
earlyWithdrawalPenalty=500
managementFee=500
hurdleRate=1000
performanceBonus=500
minCapitalContribution=2000
inceptionDate=$(date "+%s" -d $(date +"%H:%M:%S"))
share_token_price_init=1000000

generate_datum() {

    datum="datum/general-state.json"

    if [ -f "$datum" ]; then
        echo "remove old datum-data file"
        rm -rf $datum
    fi

    touch $datum

    echo "{" >>$datum
    echo "    \"constructor\": 0," >>$datum
    echo "    \"fields\": [" >>$datum
    echo "        {" >>$datum
    echo "          \"bytes\": \"$policyid\"" >>$datum
    echo "        }," >>$datum
    echo "        {" >>$datum
    echo "          \"bytes\": \"$name\"" >>$datum
    echo "        }," >>$datum
    echo "        {" >>$datum
    echo "          \"int\": \"$lockupPeriod\"" >>$datum
    echo "        }," >>$datum
    echo "        {" >>$datum
    echo "          \"int\": \"$earlyWithdrawalPenalty\"" >>$datum
    echo "        }," >>$datum
    echo "        {" >>$datum
    echo "          \"int\": \"$managementFee\"" >>$datum
    echo "        }," >>$datum
    echo "        {" >>$datum
    echo "          \"int\": \"$hurdleRate\"" >>$datum
    echo "        }," >>$datum
    echo "        {" >>$datum
    echo "          \"int\": \"$performanceBonus\"" >>$datum
    echo "        }," >>$datum
    echo "        {" >>$datum
    echo "          \"int\": \"$minCapitalContribution\"" >>$datum
    echo "        }," >>$datum
    echo "        {" >>$datum
    echo "          \"int\": \"$inceptionDate\"" >>$datum
    echo "        }," >>$datum
    echo "        {" >>$datum
    echo "          \"int\": \"$share_token_price_init\"" >>$datum
    echo "        }" >>$datum
    echo "    ]" >>$datum
    echo "}" >>$datum

    echo "wrote datum data to: $datum"
}

generate_datum