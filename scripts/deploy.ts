import { ethers } from "hardhat";

async function main() {
  const name = 'RPC'
  const symbol = 'RPC'
  const merkle = '0x6fd738c93c0ced55e88054568796cac6f386405088c183cb9c863a338b6fdddd'
  const owner = '0x8849AF2Fc730AC16C50914c0D72A0Dc0cD923aDc'

  const contract = await ethers.deployContract("ReadyPlayerClub", [name, symbol, merkle, owner]);

  await contract.waitForDeployment();

  console.log(
    `Contract deployed to ${contract.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
