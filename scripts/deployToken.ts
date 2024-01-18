import { ethers, run } from "hardhat";

function delay(ms: number) {
  return new Promise( resolve => setTimeout(resolve, ms) );
}

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  const balanceETH = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", balanceETH.toString());

  const token = await ethers.deployContract("CharlesToken", ["Charles", "CHR", 18, "1000000000"]);
  const tokenAddress = await token.getAddress();
  console.log("Token address:", tokenAddress);
  await token.waitForDeployment();
  console.log("Deploying completed!");

  console.log(`Verifying contract on BSC...`);
  await delay(15000);

  await run(`verify:verify`, {
    address: tokenAddress,
    constructorArguments:  [
      "Charles",
      "CHR",
      18,
      "1000000000"
    ],
  });

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });