const EthCrypto = require('eth-crypto');
const signerIdentity = EthCrypto.createIdentity();
const fs = require('fs');

let keys = { 
    address: signerIdentity.address,
    publicKey: signerIdentity.publicKey, 
    privateKey: signerIdentity.privateKey
};
 
let data = JSON.stringify(keys);
fs.writeFileSync('src/data/keys.json', data);