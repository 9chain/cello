#!/bin/bash
#
# Copyright O Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

## Install chaincode on all peers
CC_NAME="notaryinfo"
CC_PATH="examples/chaincode/go/notaryinfo"
CC_VERSION=0.5
echo_b "=== Installing chaincode ${CC_NAME} on all 4 peers... ==="

for org in "${ORGS[@]}"
do
	for peer in "${PEERS[@]}"
	do
	    echo "chaincodeInstall $org $peer ${CC_NAME} ${CC_VERSION} ${CC_PATH}"
		chaincodeInstall $org $peer ${CC_NAME} ${CC_VERSION} ${CC_PATH}
	done
done

echo_g "=== Install chaincode done ==="



# Instantiate chaincode in the channel, executed once on any node is enough
# (once for each channel is enough, we make it concurrent here)
CC_INIT_ARGS='{"Args":["init"]}'
echo_b "=== Instantiating chaincode on channel ${APP_CHANNEL}... ==="

chaincodeInstantiate "${APP_CHANNEL}" 3 0 ${CC_NAME} ${CC_VERSION} ${CC_INIT_ARGS}

echo_g "=== Instantiate chaincode on channel ${APP_CHANNEL} done ==="


echo
