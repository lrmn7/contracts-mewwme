import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Deploy TokenFactory
  const TokenFactory = await ethers.getContractFactory("TokenFactory");
  const tokenFactory = await TokenFactory.deploy();
  await tokenFactory.waitForDeployment();
  console.log("TokenFactory deployed to:", await tokenFactory.getAddress());

  // Deploy CustomToken
  const CustomToken = await ethers.getContractFactory("CustomToken");
  const customToken = await CustomToken.deploy("Custom Token Somnia", "CTS", ethers.parseEther("1000000"));
  await customToken.waitForDeployment();
  console.log("CustomToken deployed to:", await customToken.getAddress());

  // Deploy LiquidityPool
  const LiquidityPool = await ethers.getContractFactory("LiquidityPool");
  const liquidityPool = await LiquidityPool.deploy(
    await customToken.getAddress(),
    1,                     // Fee Rate
    deployer.address       // Fee Receiver
  );
  await liquidityPool.waitForDeployment();
  console.log("LiquidityPool deployed to:", await liquidityPool.getAddress());

  // Deploy BurnChallenge
  const BurnChallenge = await ethers.getContractFactory("BurnChallenge");
  const burnChallenge = await BurnChallenge.deploy(await tokenFactory.getAddress());
  await burnChallenge.waitForDeployment();
  console.log("BurnChallenge deployed to:", await burnChallenge.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
