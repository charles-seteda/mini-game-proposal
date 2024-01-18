import dotenv from "dotenv";
dotenv.config();
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';

const key = process.env.PRIVATE_KEY_DEPLOYED ? process.env.PRIVATE_KEY_DEPLOYED : "";

const config: HardhatUserConfig = {
  defaultNetwork: process.env.DEFAULT_NETWORK ? process.env.DEFAULT_NETWORK : "bscTestnet",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    hardhat: {
    },
    bscTestnet: {
      url: process.env.RPC_ENDPOINT_BSC_TESTNET,
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [key]
    },
    mainnet: {
      url: process.env.RPC_ENDPOINT_BSC_MAINNET,
      chainId: 56,
      gasPrice: 20000000000,
      accounts: [key]
    },
    sepolia: {
      url: process.env.RPC_ENDPOINT_SEPOLIA,
      chainId: 11155111,
      gasPrice: 20000000000,
      accounts: [key]
    },
    hederaTestnet: {
      url: process.env.RPC_ENDPOINT_HEDERA_TESTNET,
      chainId: 296,
      accounts: [key]
    },
  },
  solidity: "0.8.20",
  sourcify: {
    enabled: true
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY_SEPOLIA ? process.env.ETHERSCAN_API_KEY_SEPOLIA : "",
      testnet: process.env.ETHERSCAN_API_KEY_TESTNET ? process.env.ETHERSCAN_API_KEY_TESTNET : "",
      bscTestnet: process.env.ETHERSCAN_API_KEY_BSC_TESTNET ? process.env.ETHERSCAN_API_KEY_BSC_TESTNET : "",
    }
  }
};

export default config;
