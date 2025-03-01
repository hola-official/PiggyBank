const hre = require("hardhat");

async function main() {
  // Get the contract factories
  const MockToken = await hre.ethers.getContractFactory("MockToken");
  const PiggyBankFactory = await hre.ethers.getContractFactory(
    "PiggyBankFactory"
  );

  // Deploy mock tokens
  console.log("Deploying Mock Tokens...");
  const usdt = await MockToken.deploy("Mock USDT", "USDT", 1000000); // 1 million USDT
  const usdc = await MockToken.deploy("Mock USDC", "USDC", 1000000); // 1 million USDC
  const dai = await MockToken.deploy("Mock DAI", "DAI", 1000000); // 1 million DAI

  console.log("Mock USDT deployed to:", usdt.target);
  console.log("Mock USDC deployed to:", usdc.target);
  console.log("Mock DAI deployed to:", dai.target);

  // Deploy the PiggyBankFactory contract
  console.log("Deploying PiggyBankFactory...");
  const factory = await PiggyBankFactory.deploy();
  console.log("PiggyBankFactory deployed to:", factory.target);

  // Optional: Deploy a PiggyBank contract through the factory
  const purpose = "Vacation Fund";
  const duration = 30 * 24 * 60 * 60; // 30 days in seconds
  const developer = "0x429cB52eC6a7Fc28bC88431909Ae469977F6daCF"; // Developer's address
  const salt = hre.ethers.id("unique-salt"); // Unique salt for create2
  console.log(salt)

  console.log("Creating a new PiggyBank...");
  const tx = await factory.createPiggyBank(
    purpose,
    duration,
    usdt.target, // Mock USDT address
    usdc.target, // Mock USDC address
    dai.target, // Mock DAI address
    developer,
    salt
  );
  const receipt = await tx.wait();
  console.log(receipt.events);
  const piggyBankAddress = receipt.events?.find(
    (e) => e.event === "PiggyBankCreated"
  )?.args?.piggyBank;
  console.log("PiggyBank deployed to:", piggyBankAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
