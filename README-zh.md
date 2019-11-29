# Hyperledger Fabric 部署

本项目不建议零基础直接上手, 可以先根据官方的 
[fabric-samples/first-network](https://github.com/hyperledger/fabric-samples) 入门

本项目基于 `Docker swarm` 进行多机部署

## 前期准备工作

1. docker swarm 集群 (可单节点)
2. nfs server client (用于共享证书等文件)
3. channel-artifacts
4. crypto-config

```text
channel-artifacts
├── channel.tx
├── genesis.block
├── Org1MSPanchors.tx
└── Org2MSPanchors.tx
```

```text
crypto-config
├── ordererOrganizations
│   └── example.com
└── peerOrganizations
    ├── org1.example.com
    └── org2.example.com
```

## 启动网络 (单节点为例子)

nfs server 目录位于 `/nfsvolume`

### 创建集群网络

```bash
docker network create --driver=overlay --attachable hlf
```

### 启动 Orderer

```bash
ORDERER_HOSTNAME=orderer \
    ORDERER_DOMAIN=example.com \
    ORDERER_GENERAL_LOCALMSPID=OrdererMSP \
    FABRIC_LOGGING_SPEC=debug \
    NODE_HOSTNAME=master \
    NETWORK=hlf \
    PORT=7050 \
    NFS_ADDR=192.168.51.10 \
    NFS_PATH=/nfsvolume \
    docker stack up -c orderer.yaml orderer
```

### 启动 peer

使用 LevelDB

```bash
PEER_HOSTNAME=peer0 \
    PEER_DOMAIN=org1.example.com \
    FABRIC_LOGGING_SPEC=debug \
    CORE_PEER_LOCALMSPID=Org1MSP \
    NODE_HOSTNAME=master \
    NETWORK=hlf \
    PORT=7051 \
    NFS_ADDR=192.168.51.10 \
    NFS_PATH=/nfsvolume \
    docker stack up -c peer-leveldb.yaml peer0org1
```

使用 CouchDB

```bash
PEER_HOSTNAME=peer0 \
    PEER_DOMAIN=org1.example.com \
    FABRIC_LOGGING_SPEC=debug \
    CORE_PEER_LOCALMSPID=Org1MSP \
    NODE_HOSTNAME=master \
    NETWORK=hlf \
    PORT=7051 \
    NFS_ADDR=192.168.51.10 \
    NFS_PATH=/nfsvolume \
    docker stack up -c peer-couchdb.yaml peer0org1
```

### 启动 CA Server

```bash
PEER_DOMAIN=org1.example.com \
    NODE_HOSTNAME=master \
    USERNAME=admin \
    PASSWORD=adminpwd \
    NETWORK=hlf \
    PORT=7054 \
    NFS_ADDR=192.168.51.10 \
    NFS_PATH=/nfsvolume \
    CA_PRIVEATE_KEY=$(cd ${NFS_PATH}/crypto-config/peerOrganizations/${PEER_DOMAIN}/ca && ls *_sk) \
    docker stack up -c ca.yaml peer0org1ca
```

## 部署

### 创建 Channel

```bash
hlf-deploy createChannel --configFile config.yaml \
    --channelTxFile channel.tx \
    --channelName testchannel \
    --ordererOrgName OrdererOrg \
    Org1 Org2
```

### 更新 Anchor Peer

```bash
hlf-deploy uptateAnchorPeer --configFile config.yaml \
    --anchorPeerTxFile anchor.tx \
    --channelName testchannel \
    --ordererOrgName OrdererOrg \
    Org1
```

### 加入 Channel

```bash
hlf-deploy joinChannel --configFile config.yaml \
    --channeName testchannel \
    Org1 Org2
```

### 安装 Chaincode

```bash
hlf-deploy installChaincode --configFile config.yaml \
    --goPath ./chaincode \
    --chaincodePath example02 \
    --chaincodeName example \
    --chaincodeVersion v0.1.0 \
    Org1 Org2
```

### 更新 Chaincode

`chaincodePolicy`: 设置需要哪些组织签名 (目前只支持 Member)
`chaincodePolicyNOutOf`: 用来设置多少个组织签名检验成功后返回 true

```bash
hlf-deploy upgradeChaincode --configFile config.yaml \
    --channelName testchannel \
    --orgName Org1 \
    --chaincodePolicy Org1MSP,Org2MSP \
    --chaincodePolicyNOutOf 2 \
    --chaincodePath example02 \
    --chaincodeName example \
    --chaincodeVersion v0.1.0 \
    a 200 b 100
```

### 实例化 Chaincode

```bash
hlf-deploy instantiateChaincode --configFile config.yaml \
    --channelName testchannel \
    --orgName Org1 \
    --chaincodePolicy Org1MSP,Org2MSP \
    --chaincodePolicyNOutOf 1 \
    --chaincodePath example02 \
    --chaincodeName example \
    --chaincodeVersion v0.0.0 \
    a 100 b 200
```

### 查询 Chaincode

```bash
hlf-deploy queryChaincode --configFile config.yaml \
    --channelName testchannel \
    --orgName Org1 \
    --chaincodeName example \
    query a
```

### 调用 Chaincode

```bash
hlf-deploy invokeChaincode --configFile config.yaml \
    --channelName testchannel \
    --orgName Org1 \
    --endorsementOrgsName Org1,Org2 \
    --chaincodeName example \
    invoke a b 50
```