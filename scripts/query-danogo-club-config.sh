#!/bin/bash

confpath="./governance/global-config.json"

#Get danogo club default config
get_global_config() {
    if [ -f $confpath ]; then
        rm -rf $confpath
    fi

    touch $confpath

    curl https://club-bff.dev.tekoapis.net/api/v1/club/get-global-config >$confpath
}