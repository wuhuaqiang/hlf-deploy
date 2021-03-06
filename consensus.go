package main

import (
	"bytes"
	"log"

	"github.com/hyperledger/fabric-sdk-go/pkg/client/resmgmt"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
	"github.com/spf13/cobra"
	"github.com/yakumioto/hlf-deploy/internal/utils"
)

func updateConsensusState(_ *cobra.Command, args []string) {
	utils.InitRPCClient(rpcAddress)
	sdk := utils.SDKNew(fabconfig)

	ordererCtx := sdk.Context(fabsdk.WithUser("Admin"), fabsdk.WithOrg(ordererOrgName))
	resMgmt, err := resmgmt.New(ordererCtx)
	if err != nil {
		log.Fatalln("resmgmt new error: ", err)
	}

	// get newest config
	configBytes := utils.GetNewestConfigWithConfigBlock(resMgmt, channelName, sysChannel)

	// get modified config
	modifiedConfigBytes := utils.GetChannelConsensusStateModifiedConfig(configBytes, consensusOption, etcdOption, sysChannel)

	// get config.pb
	updateEnvelopePBBytes := utils.GetUpdateEnvelopeProtoBytes(configBytes, modifiedConfigBytes, channelName)

	req := resmgmt.SaveChannelRequest{
		ChannelID:         channelName,
		ChannelConfig:     bytes.NewBuffer(updateEnvelopePBBytes),
		SigningIdentities: utils.GetSigningIdentities(sdk.Context(), args),
	}

	txID, err := resMgmt.SaveChannel(req)
	if err != nil {
		log.Fatalf("update %s channel parameters error: %s", channelName, err)
	}

	log.Printf("update %s channel consensus success txID: %s", channelName, txID.TransactionID)
}
