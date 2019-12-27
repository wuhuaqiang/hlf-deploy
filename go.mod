module github.com/yakumioto/hlf-deploy

go 1.13

replace github.com/hyperledger/fabric-sdk-go => /home/mioto/Workspace/me/fabric-sdk-go

require (
	github.com/Shopify/sarama v1.24.1 // indirect
	github.com/gogo/protobuf v1.2.1
	github.com/google/go-cmp v0.3.1 // indirect
	github.com/grpc-ecosystem/go-grpc-middleware v1.1.0 // indirect
	github.com/hashicorp/go-version v1.2.0 // indirect
	github.com/hyperledger/fabric-amcl v0.0.0-20190902191507-f66264322317 // indirect
	github.com/hyperledger/fabric-protos-go v0.0.0-20191121202242-f5500d5e3e85
	github.com/hyperledger/fabric-sdk-go v1.0.0-beta1
	github.com/klauspost/cpuid v1.2.2 // indirect
	github.com/miekg/pkcs11 v1.0.3 // indirect
	github.com/onsi/ginkgo v1.10.3 // indirect
	github.com/onsi/gomega v1.7.1 // indirect
	github.com/op/go-logging v0.0.0-20160315200505-970db520ece7 // indirect
	github.com/prometheus/procfs v0.0.5 // indirect
	github.com/spf13/cobra v0.0.5
	github.com/sykesm/zap-logfmt v0.0.3 // indirect
	go.uber.org/zap v1.13.0 // indirect
	golang.org/x/crypto v0.0.0-20190927123631-a832865fa7ad // indirect
	golang.org/x/sys v0.0.0-20190916202348-b4ddaad3f8a3 // indirect
	golang.org/x/text v0.3.2 // indirect
)

exclude (
	github.com/hyperledger/fabric v1.4.4
	github.com/hyperledger/fabric v2.0.0-alpha+incompatible
	github.com/hyperledger/fabric v2.0.0-beta+incompatible
)
