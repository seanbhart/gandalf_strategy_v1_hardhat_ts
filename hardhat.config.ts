import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import * as dotenv from "dotenv";
dotenv.config({ path: __dirname+'/.env' });

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (args, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(await account.address);
  }
});

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.7.6",
        settings: { } 
      }
    ]
  },
  networks: {
    ropsten: {
      url: `${process.env.NETWORK}`,
      accounts: [`0x${process.env.ACCOUNT_KEY_PRIV}`]
    }
  }
};

export default config;
