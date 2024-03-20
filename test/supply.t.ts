import { expect } from "chai";
import { ethers } from "hardhat";
import { ReadyPlayerClub__factory } from "../typechain-types";
import MerkleTree from "merkletreejs";
import { whitelist } from "../utils/constant/whitelist";

describe("Supply", async function () {
    it("totalSupply test", async function () {
        const [deployer, minter_1, minter_2] = await ethers.getSigners();
        const factory: ReadyPlayerClub__factory = await ethers.getContractFactory('ReadyPlayerClub') as ReadyPlayerClub__factory;
        const leafNodes = [...whitelist, deployer, minter_1, minter_2].map(user => ethers.keccak256(ethers.solidityPacked(['address', 'uint256'], [user.address, "100"])));
        const merkleTree = new MerkleTree(leafNodes, ethers.keccak256, { sortPairs: true });
        const rootHash = merkleTree.getRoot();
        const contract = await factory.deploy('test', 'test', rootHash, deployer?.address);
        await contract.waitForDeployment();
        const deployedAddress = await contract.getAddress();
        {
            const proof = merkleTree.getHexProof(leafNodes[leafNodes.length - 2]);
            const tx = await ReadyPlayerClub__factory.connect(deployedAddress, minter_1).mint("100", "100", proof);
            await tx.wait();
            const tx_receipt = await ethers.provider.getTransactionReceipt(tx.hash);

            expect(tx_receipt?.status).to.equal(1);
            console.log("Gas used:", tx_receipt?.gasUsed)

            const tatalSupply = await ReadyPlayerClub__factory.connect(deployedAddress, minter_1).totalSupply()
            const balance = await ReadyPlayerClub__factory.connect(deployedAddress, minter_1).balanceOf(minter_1.address)
            console.log('Total Supply:', tatalSupply);
            console.log('Minter Balance:', balance);
        }
        {
            const proof = merkleTree.getHexProof(leafNodes[leafNodes.length - 1]);
            const tx = await ReadyPlayerClub__factory.connect(deployedAddress, minter_2).mint("50", "100", proof);
            await tx.wait();
            const tx_receipt = await ethers.provider.getTransactionReceipt(tx.hash);

            expect(tx_receipt?.status).to.equal(1);
            console.log("Gas used:", tx_receipt?.gasUsed)

            const tatalSupply = await ReadyPlayerClub__factory.connect(deployedAddress, minter_2).totalSupply()
            const balance = await ReadyPlayerClub__factory.connect(deployedAddress, minter_2).balanceOf(minter_2.address)
            console.log('Total Supply:', tatalSupply);
            console.log('Minter Balance:', balance);
        }
        {
            const proof = merkleTree.getHexProof(leafNodes[leafNodes.length - 3]);
            const tx = await ReadyPlayerClub__factory.connect(deployedAddress, deployer).mint("100", "100", proof);
            await tx.wait();
            const tx_receipt = await ethers.provider.getTransactionReceipt(tx.hash);

            expect(tx_receipt?.status).to.equal(1);
            console.log("Gas used:", tx_receipt?.gasUsed)

            const tatalSupply = await ReadyPlayerClub__factory.connect(deployedAddress, deployer).totalSupply()
            const balance = await ReadyPlayerClub__factory.connect(deployedAddress, deployer).balanceOf(deployer.address)
            console.log('Total Supply:', tatalSupply);
            console.log('Minter Balance:', balance);
        }
    })
})