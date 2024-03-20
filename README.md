# RPC NFT

## ENV
ETHEREUM_SEPOLIA_RPC_URL 
<!-- ethereum sepolia rpc -->
ETHEREUM_RPC_URL
<!-- ethereum rpc -->
PRIVATE_KEY
<!-- deployer private -->

## Deploy
```shell
npm install
npx hardhat compile
npx hardhat deploy --network <ethereum/ethereumSepolia> --symbol <> --name <> --merkle <0xaa77cc0d1cd1f82db420ca17686e4dd7b8642b16a09ceb674c029fe07764631d> --owner <Optional param: default is deployer address>
```

## Test
```shell
npx hardhat node
npx hardhat test .\test\mint.t.ts --network hardhat
npx hardhat test .\test\supply.t.ts --network hardhat
```

## Tasks
### Deploy Contract
```shell
npx hardhat deploy --network <ethereum/ethereumSepolia> --symbol <> --name <> --merkle <0xaa77cc0d1cd1f82db420ca17686e4dd7b8642b16a09ceb674c029fe07764631d> --owner <Optional param: default is deployer address>
```

### Get whitelist merkle root
```shell
npx hardhat root
```

### Set start time - default is contract deployed time
```shell
npx hardhat set-start --network ethereumSepolia --app 0x17aAf60c8BCC78e3b6B3a33C44cc2784bbc1EC44 --start  1710899151
```

### Set end time - default is contract deployed time + 30 days
```shell
npx hardhat set-start --network ethereumSepolia --app 0x17aAf60c8BCC78e3b6B3a33C44cc2784bbc1EC44 --end  1710899151
```

### Set merkle root
```shell
npx hardhat set-merkle --network ethereumSepolia --app 0x17aAf60c8BCC78e3b6B3a33C44cc2784bbc1EC44 --merkle  0x
```