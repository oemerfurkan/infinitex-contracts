import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import { ethers } from "hardhat";
import dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  defaultNetwork: "localhost",
  networks: {
    localhost: {
      chainId: 31337,
      url: "http://localhost:8545",
    },
    sepolia: {
      chainId: 11155111,
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY!],
    },
    polygon: {
      chainId: 137,
      url: `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY!],
    },
    mumbai: {
      chainId: 80001,
      url: `https://polygon-mumbai.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY!],
    },
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY!,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.23",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
};

export default config;
