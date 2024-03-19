import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { Wallet, JsonRpcProvider } from "ethers";
import { getPrivateKey, getProviderRpcUrl } from "../utils/helper";
import { ReadyPlayerClub, ReadyPlayerClub__factory } from "../typechain-types";

task(`set-merkle`)
    .addParam(`app`)
    .addParam(`merkle`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const { app, merkle } = taskArguments;
        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl);
        const wallet = new Wallet(privateKey);
        const deployer = wallet.connect(provider);

        const conract = ReadyPlayerClub__factory.connect(app, deployer)
        console.log(`Start transaction...`);

        const tx = await conract.updateWhitelisteMerkleTree(merkle)

        console.log(`✅ Set merkle tree:`, tx.hash);
    })