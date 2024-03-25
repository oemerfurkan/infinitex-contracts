import { ethers, network, run } from "hardhat";

const defaultAdmin = "0x42b29aFfdEe56D0d9f9f4512E18C96e85F34f70D";
const minter = "0x9698Bb5DeF412299cbCD8AB04BF17DbD0E23aE56";
const owner = "0x42b29aFfdEe56D0d9f9f4512E18C96e85F34f70D";
const tokenAddress = "";

async function main() {
  const Nft = await ethers.getContractFactory("BasicNFT");
  const nft = await Nft.deploy();

  await nft.deployed();

  console.log("NFT contract deployed to: ", nft.address);

  setTimeout(async () => {
    console.log(`Verifying NFT contract on Etherscan...`);

    await run(`verify:verify`, {
      address: nft.address,
    });
  }, 15000);

  //   const nftContract = await ethers.getContractAt("Infinitex", nft.address);

  // nftContract.mint(accounts[0].address, 0, 1, "0x");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
