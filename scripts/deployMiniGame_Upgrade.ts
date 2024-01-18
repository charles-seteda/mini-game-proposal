import dotenv from "dotenv";
dotenv.config();
import { ethers, run, upgrades } from "hardhat";

const CHARLES_TOKEN_ADDRESS = "0x5692DA15d11B8135Fe2c085734CBF25D88d1098A";

const OWNERS_ADDRESS = [
  "0x757107669F696E7ddBe53dB850b48F0a4386DCE9",
];

const PROXY = "0xF92bc45127ca1ed820aAE5CB6E58248cd383cF76";
function delay(ms: number) {
  return new Promise( resolve => setTimeout(resolve, ms) );
}

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  const balanceETH = await ethers.provider.getBalance(deployer.address);
  console.log(`Account balance: ${balanceETH.toString()}`);
  console.log(`Address: ${(await deployer.address).toString()}`);

  console.log("Upgrade processing ...!");

  const miniGameProposal = await ethers.getContractFactory("MiniGameProposal");
  await upgrades.upgradeProxy(PROXY, miniGameProposal);
  console.log("Upgrade completed!");

  console.log(`Verifying contract on BSC...`);
  await delay(15000);

  await run(`verify:verify`, {
    address: PROXY,
    constructorArguments:  [],
    initializerArguments:  [CHARLES_TOKEN_ADDRESS, OWNERS_ADDRESS],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });