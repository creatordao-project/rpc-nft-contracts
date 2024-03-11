import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { keccak256, solidityPacked } from "ethers";
import MerkleTree from "merkletreejs";
import { whitelist } from "../utils/constant/whitelist";

task(`root`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const tree = new MerkleTree(
            whitelist.map((item) => keccak256(solidityPacked(["address"], [item.address as `0x${string}`]))),
            keccak256,
            { sortPairs: true },
        );

        const root = tree.getRoot().toString('hex')
        console.debug("Merkle tree root is:", root);
    })