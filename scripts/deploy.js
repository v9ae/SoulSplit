const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with:", deployer.address);

  const SoulSplit = await hre.ethers.getContractFactory("SoulSplit");
  const soulSplit = await SoulSplit.deploy();

  await soulSplit.deployed();
  console.log("SoulSplit deployed to:", soulSplit.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});