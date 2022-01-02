const hre = require("hardhat");

async function main() {
  // We get the contract to deploy
  const Staking = await hre.ethers.getContractFactory("Staking");
  // input: token and rewardRate
  const tokenAddress = '';
  const rewardRate = '';
  const staking = await Staking.deploy(tokenAddress, rewardRate);

  await staking.deployed();

  console.log("Greeter deployed to:", staking.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
