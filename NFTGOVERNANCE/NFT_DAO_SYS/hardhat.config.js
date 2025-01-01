require("dotenv").config();
require("@nomiclabs/hardhat-ethers");

module.exports = {
    solidity: "0.8.0",
    networks: {
        holesky: {
            url: "https://rpc.holesky.ethdevops.io",
            accounts: [`0x${process.env.PRIVATE_KEY}`], // Reads the private key from .env
        },
    },
};
