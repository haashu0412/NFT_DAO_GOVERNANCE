async function main() {
    const NFTToken = await ethers.getContractFactory("NFTGovernanceToken");
    const nft = await NFTToken.deploy("DAO NFT", "DAO");
    await nft.deployed();
    console.log("NFT deployed to:", nft.address);

    const DAOGovernance = await ethers.getContractFactory("DAOGovernance");
    const dao = await DAOGovernance.deploy(nft.address);
    await dao.deployed();
    console.log("DAO deployed to:", dao.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
