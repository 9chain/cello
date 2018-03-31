
package main

import (
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
	"encoding/json"
)

// NotaryInfoChaincode example simple Chaincode implementation
type NotaryInfoChaincode struct {
}

// Init method of chaincode
func (t *NotaryInfoChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success([]byte("OK"))
}

// Invoke transaction
func (t *NotaryInfoChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("NotaryInfoChaincode Invoke")
	function, args := stub.GetFunctionAndParameters()
	if function == "put" {
		return t.put(stub, args)
	} else if function == "queryHistory" {
		return t.queryHistory(stub, args)
	} else if function == "queryState" {
		return t.queryState(stub, args)
	}

	return shim.Error("Invalid invoke function name. Expecting \"put\" \"queryHistory\" \"queryState\"")
}

func (t *NotaryInfoChaincode) put(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	var argsLen = len(args)
	if len(args) % 2 != 0 {
		return shim.Error("Incorrect number of arguments. Expecting even number.")
	}

	for i := 0; i < argsLen; i += 2 {
		// Write the state to the ledger
		err = stub.PutState(args[i], []byte(args[i+1]))
		if err != nil {
			return shim.Error(err.Error())
		}
	}

	p := struct {
		TxId string `json:"tx_id"`
	} {
		stub.GetTxID(),
	}

	data, err := json.Marshal(p)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(data)
}

func (t *NotaryInfoChaincode) queryHistory(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	var key = args[0]
	fmt.Println("Query history of key:", key)

	// (StateQueryIteratorInterface, error)
	resultsIterator, err := stub.GetHistoryForKey(key)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	var results []interface{}
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		results = append(results, response)
	}

	data, err := json.Marshal(results)
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Printf("queryHistory returning:\n%s\n", data)
	return shim.Success(data)
}

func (t *NotaryInfoChaincode) queryState(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	var key = args[0]
	fmt.Println("Query history of key:", key)

	value, err := stub.GetState(key)
	if err != nil {
		return shim.Error(err.Error())
	}

	p := struct {
		State []byte `json:"state"`
	} {
		value,
	}
	data, err := json.Marshal(p)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(data)
}

func main() {
	err := shim.Start(new(NotaryInfoChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}