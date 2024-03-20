import { ethers } from "hardhat";

async function main() {
  const name = 'ReadyPlayerClub'
  const symbol = 'ReadyPlayerClub'
  const merkle = '0xaa77cc0d1cd1f82db420ca17686e4dd7b8642b16a09ceb674c029fe07764631d'
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
