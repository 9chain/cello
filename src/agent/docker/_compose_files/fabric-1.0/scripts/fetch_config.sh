#!/usr/bin/env bash
#
# Copyright O Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# This script will fetch blocks for testing.

# Importing useful functions for cc testing
if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi

echo_b "=== Fetching config of channel ${APP_CHANNEL} ==="

BLOCK_FILE=${APP_CHANNEL}_config1.block
channelFetch ${APP_CHANNEL} 0 0 "config" ${BLOCK_FILE}
[ $? -ne 0 ] && exit 1
echo "fetch config block ${BLOCK_FILE}"

echo_b "Decode latest config block ${BLOCK_FILE} into json..."
configtxlator proto_decode --input ${BLOCK_FILE} --type common.Block | jq .data.data[0].payload.data.config > config1.json
[ $? -ne 0 ] && { echo_r "Decode ${BLOCK_FILE} failed"; exit 1; }

echo_g "=== Fetched config from channels done! ==="

echo
