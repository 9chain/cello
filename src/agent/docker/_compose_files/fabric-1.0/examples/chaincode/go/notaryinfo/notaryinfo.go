
package main

import (
	"bytes"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
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
	}

	return shim.Error("Invalid invoke function name. Expecting \"put\" \"queryHistory\"")
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

	return shim.Success([]byte(fmt.Sprintf("{\"TxId\": %s}", stub.GetTxID())))
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

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		buffer.WriteString(string(response.Value))

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("queryHistory returning:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func main() {
	err := shim.Start(new(NotaryInfoChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}