import { defineConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-viem";
import "@nomicfoundation/hardhat-viem-assertions";
import hardhatIgnitionViemPlugin from "@nomicfoundation/hardhat-ignition-viem";
import "@solidstate/hardhat-contract-sizer";

export default defineConfig({
  plugins: [hardhatIgnitionViemPlugin],
  solidity: {
    compilers: [
      {
        version: "0.8.27",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
    overrides: {
      "contracts/VerifierBoard.sol": {
        version: "0.8.27",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1, // Minimum runs for smallest deployment size
          },
          metadata: {
            bytecodeHash: "none",
          },
          debug: {
            revertStrings: "strip",
          },
        },
      },
      "contracts/VerifierShot.sol": {
        version: "0.8.27",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1,
          },
          metadata: {
            bytecodeHash: "none",
          },
          debug: {
            revertStrings: "strip",
          },
        },
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: false,
    disambiguatePaths: false,
    strict: true,
  },
  networks: {
    hardhat: {
      type: "http",
      url: "http://127.0.0.1:8545",
      chainId: 31337,
      blockGasLimit: 30000000,
    },
    localhost: {
      type: "http",
      url: "http://127.0.0.1:8545",
      gas: 30000000,
      gasPrice: "auto",
      timeout: 60000,
    },
  },
});
