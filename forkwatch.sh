#!/bin/bash

# forkwatch.sh v1.0.1 - qSebastiaNp

# config
SAFEMARGIN=50 # use hash of (blockheight - $SAFEMARGIN) to rule out orphan hashes
TRANSCENDENCE=./transcendence-cli
IFTTTKEY=none

# no need to change anything from here --->
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [ ! -f "$TRANSCENDENCE" ]; then
        >&2 echo "* Could not find $TRANSCENDENCE. Please check the configuration at the top of this script."
        exit 1
fi

MNCOUNT=`wget -qO- https://explorer.teloscoin.org/ext/getmasternodecount`
LOCALMNCOUNT=`$TRANSCENDENCE masternode count | grep -w stable | cut -d' ' -f4 | cut -d',' -f1`

# check if explorer knows enough masternodes, else it may be forked
if [ $MNCOUNT -lt $(($LOCALMNCOUNT/2)) ]
then
        >&2 echo "* Explorer reports $MNCOUNT MNs, which is much lower than your $LOCALMNCOUNT. It may have forked. Exiting..."
        exit 1
fi

sleep 1
BLOCKHEIGHT=`wget -qO- https://explorer.teloscoin.org/api/getblockcount`
SAFEBLOCKHEIGHT=$(($BLOCKHEIGHT-$SAFEMARGIN))

sleep 1
EXPLORERHASH=`wget -qO- https://explorer.teloscoin.org/api/getblockhash?index=$SAFEBLOCKHEIGHT`

POLISHASH=`wget -qO- https://telos.polispay.com/api/block-index/$SAFEBLOCKHEIGHT | cut -d\" -f4`
LOCALHASH=`$TRANSCENDENCE getblockhash $SAFEBLOCKHEIGHT`

# output blockhash overview
echo "Local   : $LOCALHASH"
echo "Explorer: $EXPLORERHASH"
echo "PolisPay: $POLISHASH"
echo ""

# compare the blockhash with explorer
if [ $EXPLORERHASH = $LOCALHASH ]
then
        echo "* Your blockhash for block $SAFEBLOCKHEIGHT equals explorer's."

        # check if polis and explorer have consensus
        if [ $EXPLORERHASH = $POLISHASH ]
        then
                echo "* Explorer and PolisPay have consensus."
                echo -e "* You are ${GREEN}NOT FORKED${NC}. Everything is fine. Exiting..."
        else
                echo "* Explorer and PolisPay don't have consensus. Network is agitated."
                echo -e "* You ${RED}SHOULD ${NC}be ${GREEN}NOT FORKED${NC}. Maybe run the test again in a few minutes. Not immediately."
        fi
        exit 0
else
        >&2 echo "Your blockhash for block $SAFEBLOCKHEIGHT differs from explorer's."
        >&2 echo -e "It seems ${RED}YOU ARE FORKED${NC}. Exiting..."

        # send push notification - read README.MD
        if [ $IFTTTKEY != 'none' ]
        then
                wget -qO- -post-data='{"value1":"It seems `hostname` is FORKED."}' --header='Content-Type:application/json' https://maker.ifttt.com/trigger/notify/with/key/$IFTTTKEY
        fi
        exit 1
fi
