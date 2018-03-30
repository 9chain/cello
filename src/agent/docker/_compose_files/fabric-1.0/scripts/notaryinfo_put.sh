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
#CC_02_INVOKE_ARGS='{"Args":["invoke","a","b","10"]}'
#CC_INVOKE_ARGS=${CC_02_INVOKE_ARGS}


echo_g "=== Testing Chaincode put ==="


#Invoke on chaincode on Peer0/Org1
echo_b "Sending invoke transaction (transfer 10) on org1/peer0..."
chaincodeInvoke ${APP_CHANNEL} 1 0 ${CC_NAME} '{"Args":["put","a","aaazzzzxxxx","b","vvvzzzzxxxx","c","aaazzxxxx"]}'

#Invoke on chaincode on Peer0/Org2
echo_b "Sending invoke transaction (transfer 10) on org1/peer0..."
chaincodeInvoke ${APP_CHANNEL} 2 0 ${CC_NAME} '{"Args":["put","a","ddzzzxxxxx","d","ddddddddzzzxx","b","bbbbzzxxxx"]}'

#Invoke on chaincode on Peer0/Org3
echo_b "Sending invoke transaction (transfer 10) on org1/peer0..."
chaincodeInvoke ${APP_CHANNEL} 3 0 ${CC_NAME} '{"Args":["put","c","cccczzzxxx"]}'

#Invoke on chaincode on Peer0/Org4
echo_b "Sending invoke transaction on org2/peer3..."
chaincodeInvoke ${APP_CHANNEL} 4 0 ${CC_NAME} '{"Args":["put","b","bbbbzzzxxxx","d","ddddddzzzxxxxxx"]}'

chaincodeQuery ${APP_CHANNEL} 3 0 ${CC_NAME} '{"Args":["queryHistory","c"]}'
chaincodeQuery ${APP_CHANNEL} 4 0 ${CC_NAME} '{"Args":["queryHistory","a"]}'
chaincodeQuery ${APP_CHANNEL} 1 0 ${CC_NAME} '{"Args":["queryHistory","a"]}'

#for((i=1;i<=5000;i++));
#do
#    chaincodeInvoke ${APP_CHANNEL} 1 0 ${CC_NAME} '{"Args":["put","a","aaazzzzxxxx","b","vvvzzzzxxxx","c","aaazzxxxx"]}'
#    chaincodeInvoke ${APP_CHANNEL} 1 0 ${CC_NAME} '{"Args":["put","a","aaccvxxxx","b","vvvzzcvcvx","c","aacvxvxx"]}'
#    sleep 0.01
#done

echo_g "=== Chaincode invoke/query completed ==="

echo
