import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    sepolia: {
      url:
        "https://eth-sepolia.g.alchemy.com/v2/" + vars.get("ALCHEMY_API_KEY"),
      accounts: [vars.get("PRIVATE_KEY") || ""],
      gas: 5000000,
    },
  },
  etherscan: {
    apiKey: {
       sepolia: vars.get("ETHERSCAN_API_KEY"),
    },
  },
};

export default config;
