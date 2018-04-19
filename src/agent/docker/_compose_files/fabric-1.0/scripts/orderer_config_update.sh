#!/bin/bash
#
# Copyright O Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Demo to use configtxlator to add some new organization
# Usage:
# Configtxlator APIs:
	# Json -> ProtoBuf: http://$SERVER:$PORT/protolator/encode/<message.Name>
	# ProtoBuf -> Json: http://$SERVER:$PORT/protolator/decode/<message.Name>
	# Compute Update: http://$SERVER:$PORT/configtxlator/compute/update-from-configs
# <message.Name> could be: common.Block, common.Envelope, common.ConfigEnvelope, common.ConfigUpdateEnvelope, common.Config, common.ConfigUpdate
# More details about configtxlator, see http://hlf.readthedocs.io/en/latest/configtxlator.html

set -e

if [ -f ./func.sh ]; then
 source ./func.sh
elif [ -f scripts/func.sh ]; then
 source scripts/func.sh
fi


BLOCK_FILE=${APP_CHANNEL}_config.block
channelFetch ${APP_CHANNEL} 0 0 "config" ${BLOCK_FILE}
[ $? -ne 0 ] && exit 1
echo "fetch config block ${BLOCK_FILE}"

echo_b "Decode latest config block ${BLOCK_FILE} into json..."
configtxlator proto_decode --input ${BLOCK_FILE} --type common.Block | jq .data.data[0].payload.data.config > config.json
[ $? -ne 0 ] && { echo_r "Decode ${BLOCK_FILE} failed"; exit 1; }

BATCH_TIMEOUT=".channel_group.groups.Orderer.values.BatchTimeout.value.timeout"
MAX_BATCH_SIZE_PATH=".channel_group.groups.Orderer.values.BatchSize.value.max_message_count"
echo_b "Modify config file..."
jq "$MAX_BATCH_SIZE_PATH=100 | $BATCH_TIMEOUT=\"60s\"" config.json > modified_config.json

echo_b "First, translate config.json back into a protobuf called config.pb"
configtxlator proto_encode --input config.json --type common.Config --output config.pb

echo_b "Next, encode modified_config.json to modified_config.pb"
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

echo_b "Now use configtxlator to calculate the delta between these two config protobufs"
configtxlator compute_update --channel_id ${APP_CHANNEL} --original config.pb --updated modified_config.pb --output update.pb

echo_b "let’s decode this object into editable JSON format and call it org3_update.json"
configtxlator proto_decode --input update.pb --type common.ConfigUpdate | jq . > update.json

echo_b "we need to wrap in an envelope message. This step will give us back the header field that we stripped away earlier."
echo '{"payload":{"header":{"channel_header":{"channel_id":"'${APP_CHANNEL}'", "type":2}},"data":{"config_update":'$(cat update.json)'}}}' | jq . > update_in_envelope.json

echo_b "Use configtxlator tool one last time and convert it into the fully fledged protobuf format that Fabric requires."
configtxlator proto_encode --input update_in_envelope.json --type common.Envelope --output update_in_envelope.pb


echo_b "Sign this update proto as the Org1 Admin."
peer channel signconfigtx -f update_in_envelope.pb

echo_b "Send update call."
peer channel update -o ${ORDERER_URL} -c ${APP_CHANNEL} -f update_in_envelope.pb --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

exit 0