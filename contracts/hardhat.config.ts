import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ignition";

const config: HardhatUserConfig = {
	solidity: {
		version: "0.8.27",
		settings: {
			optimizer: { enabled: true, runs: 200 }
		}
	},
	paths: {
		sources: "./contracts/contracts",
		artifacts: "./artifacts",
		cache: "./cache"
	},
	networks: {
		hardhat: {}
	}
};

export default config;

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  paths: {
    sources: "./",
    tests: "../test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  networks: {
    hardhat: {}
  }
};

export default config;


