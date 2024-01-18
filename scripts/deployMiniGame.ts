import { ethers, run, upgrades } from "hardhat";

const CHARLES_TOKEN_ADDRESS = "0x5692DA15d11B8135Fe2c085734CBF25D88d1098A";

const OWNERS_ADDRESS = [
  "0x757107669F696E7ddBe53dB850b48F0a4386DCE9",
];

function delay(ms: number) {
  return new Promise( resolve => setTimeout(resolve, ms) );
}
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  const balanceETH = await ethers.provider.getBalance(deployer.address);
  console.log(`Account balance: ${balanceETH.toString()}`);
  console.log(`Address: ${(await deployer.address).toString()}`);

  console.log("Deploying processing ...!");

  const miniGameProposal = await ethers.getContractFactory("MiniGameProposal");
  const miniGameProposalContract = await upgrades.deployProxy(miniGameProposal, [
    CHARLES_TOKEN_ADDRESS,
    OWNERS_ADDRESS
  ], {
    initializer: "initialize",
    kind: "transparent",
    unsafeAllowCustomTypes: true,
  });
  console.log("Wait for deploy new contract address:", await miniGameProposalContract.getAddress());
  await miniGameProposalContract.waitForDeployment();
  console.log("Deploying completed!");

  const miniGameProposalAddress = await miniGameProposalContract.getAddress();
  console.log("Contract MiniGameProposal address:", miniGameProposalAddress);

  console.log(`Verifying contract on BSC...`);
  await delay(15000);

  await run(`verify:verify`, {
    address: miniGameProposalAddress,
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