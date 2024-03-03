import { ethers } from "hardhat";

async function main() {
  const name = ''
  const symbol = ''
  const merkle = ''
  const owner = ''

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
