write_files:
- path: /tmp/bitcoin.conf
  content: |
    rpcallowip=${RPC_ACCESS_CIDR}
    rpcbind=0.0.0.0
    datadir=/bitcoind/bitcoin-${VERSION}/data/
    daemon=1
    zmqpubrawblock=tcp://0.0.0.0:28332
    zmqpubrawtx=tcp://0.0.0.0:28333
    zmqpubrawblockhwm=10000
    zmqpubrawtxhwm=10000
    listen=0
    server=1
    txindex=1
    maxmempool=500
    disablewallet=1
    debug=mempool
    debug=rpc
    dbcach=3000
    maxuploadtarget=1000
    rpcuser=${RPCUSER}
    rpcpassword=${RPCPASS}
  owner: root:root
  permissions: '0440'