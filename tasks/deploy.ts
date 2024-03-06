import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { Wallet, JsonRpcProvider } from "ethers";
import { getPrivateKey, getProviderRpcUrl } from "../utils/helper";
import { ReadyPlayerClub, ReadyPlayerClub__factory } from "../typechain-types";

task(`deploy`)
    .addParam(`name`)
    .addParam(`symbol`)
    .addParam(`merkle`)
    .addOptionalParam(`owner`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const { name, symbol, merkle, owner } = taskArguments;
        const privateKey = getPrivateKey();
        const rpcProviderUrl = getProviderRpcUrl(hre.network.name);

        const provider = new JsonRpcProvider(rpcProviderUrl);
        const wallet = new Wallet(privateKey);
        const deployer = wallet.connect(provider);

        const factory: ReadyPlayerClub__factory = await hre.ethers.getContractFactory('ReadyPlayerClub') as ReadyPlayerClub__factory;
        const contract = await factory.deploy(name, symbol, merkle, owner ?? deployer?.address);
        await contract.waitForDeployment()
        const address = await contract.getAddress()

        console.log(`✅ Contract deployed at address ${address} on the ${hre.network.name} blockchain`);
    })