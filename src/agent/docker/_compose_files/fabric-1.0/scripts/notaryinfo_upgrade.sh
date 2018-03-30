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

CC_NAME="notaryinfo"
CC_UPGRADE_VERSION=0.5
CC_PATH="examples/chaincode/go/notaryinfo"
CC_UPGRADE_ARGS='{"Args":["upgrade"]}'
#Upgrade to new version
echo_b "=== Upgrade chaincode ${CC_NAME} to new version... ==="

for org in "${ORGS[@]}"
do
	for peer in "${PEERS[@]}"
	do
	    echo "chaincodeInstall $org $peer ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_PATH}"
		chaincodeInstall $org $peer ${CC_NAME} ${CC_UPGRADE_VERSION} ${CC_PATH}
	done
done

echo_g "=== Install chaincode done ==="

# Upgrade on one peer of the channel will update all
chaincodeUpgrade ${APP_CHANNEL} 1 0 "${CC_NAME}" "${CC_UPGRADE_VERSION}" "${CC_UPGRADE_ARGS}"


echo_g "=== chaincode ${CC_NAME} Upgrade completed ==="

echo
