#!/bin/bash
export PATH=$PATH:/var/cfengine/bin:/bin
for each in $(cf-key -s | awk '/192/ {print $2}' | sort -u); do
    state_file="/var/cfengine/state/vagrant_env_collected_$each"
    if [[ ! -f $state_file ]]; then
        echo "Found new remote client: '$each', initiating cf-hub collection ..."
        cf-hub --query rebase --query-host $each &>/dev/null\
            && touch $state_file
    fi
done
