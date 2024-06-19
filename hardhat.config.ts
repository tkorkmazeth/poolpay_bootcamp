import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import * as dotenv from "dotenv";
dotenv.config();

const PRIVATE_KEY = process.env.PRIVATE_KEY as string;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  networks: {
    mumbai: {
      chainId: 534351,
      accounts: [],
      url: "https://sepolia-rpc.scroll.io",
    },
  },
};

export default config;
