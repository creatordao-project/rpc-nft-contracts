import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { keccak256, solidityPacked } from "ethers";
import MerkleTree from "merkletreejs";
import { whitelist } from "../utils/constant/whitelist";

// You can edit /utils/constant/whitelist.ts to update Whitelist

task(`root`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const tree = new MerkleTree(
            whitelist.map((item) => keccak256(solidityPacked(["address", "uint256"], [item.address as `0x${string}`, item.amount]))),
            keccak256,
            { sortPairs: true },
        );

        const root = tree.getRoot().toString('hex')
        console.debug("Merkle tree root is:", root);
    })