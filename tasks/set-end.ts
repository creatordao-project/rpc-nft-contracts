import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { Wallet, JsonRpcProvider } from "ethers";
import { getPrivateKey, getProviderRpcUrl } from "../utils/helper";
import { ReadyPlayerClub, ReadyPlayerClub__factory } from "../typechain-types";

task(`set-end`)
    .addParam(`app`, `NFT contract address`)
    .addParam(`end`, `Mint end time`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const { app, end } = taskArguments;
        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl);
        const wallet = new Wallet(privateKey);
        const deployer = wallet.connect(provider);

        const conract = ReadyPlayerClub__factory.connect(app, deployer)

        const tx = await conract.setMintEndTime(end)

        console.log(`✅ Set end time:`, tx.hash);
    })