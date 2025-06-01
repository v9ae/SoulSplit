const hre = require("hardhat");

async function main() {
  const [owner] = await hre.ethers.getSigners();
  const contractAddress = "0xYourDeployedContractAddress"; // TODO: Replace with deployed address
  const SoulSplit = await hre.ethers.getContractAt("SoulSplit", contractAddress, owner);

  const tx = await SoulSplit.fundContract({ value: hre.ethers.utils.parseEther("1.0") });
  await tx.wait();
  console.log("Contract funded with 1 ETH");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});