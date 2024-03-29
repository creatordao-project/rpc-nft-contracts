import { expect } from "chai";
import { ethers } from "hardhat";
import { ReadyPlayerClub__factory } from "../typechain-types";
import MerkleTree from "merkletreejs";
import { whitelist } from "../utils/constant/whitelist";

describe("Mint", async function () {
  it("mint nft", async function () {
    const [deployer, minter] = await ethers.getSigners();
    const factory: ReadyPlayerClub__factory = await ethers.getContractFactory('ReadyPlayerClub') as ReadyPlayerClub__factory;
    const leafNodes = [...whitelist, minter].map(user => ethers.keccak256(ethers.solidityPacked(['address'], [user.address])));
    const merkleTree = new MerkleTree(leafNodes, ethers.keccak256, { sortPairs: true });
    const rootHash = merkleTree.getRoot();
    const contract = await factory.deploy('test', 'test', rootHash, deployer?.address);
    await contract.waitForDeployment();
    const deployedAddress = await contract.getAddress();
    const proof = merkleTree.getHexProof(leafNodes[leafNodes.length - 1]);
    console.debug("Minter proof:", proof?.length)
    const tx = await ReadyPlayerClub__factory.connect(deployedAddress, minter).mint(proof);
    await tx.wait();
    const tx_receipt = await ethers.provider.getTransactionReceipt(tx.hash);
    expect(tx_receipt?.status).to.equal(1);
    console.debug("Gas used:", tx_receipt?.gasUsed)

    const tatalSupply = await ReadyPlayerClub__factory.connect(deployedAddress, minter).totalSupply()
    const balance = await ReadyPlayerClub__factory.connect(deployedAddress, minter).balanceOf(minter.address)
    console.log('Total Supply:', tatalSupply);
    console.log('Minter Balance:', balance);
  })
})