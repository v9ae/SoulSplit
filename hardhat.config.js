require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    abstractMainnet: {
      url: process.env.ABSTRACT_MAINNET_RPC_URL,
      chainId: Number(process.env.ABSTRACT_MAINNET_CHAIN_ID),
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
