import { ethers, network, run } from "hardhat";

const defaultAdmin = "0xbCa7Fa4548f01ceF64B83B5ce1DD539f7e7A611D";
const minter = "0x6cAd8E6D8d343E5ef2989E5735BE46C9fb2983C1";
const owner = "0xbCa7Fa4548f01ceF64B83B5ce1DD539f7e7A611D";
const tokenAddress = "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359";

async function main() {
  // const Usdc = await ethers.getContractFactory("MockUSDC");
  // const usdc = await Usdc.deploy(minter);

  // await usdc.deployed();
  const constructorArguments = [defaultAdmin, minter, owner, tokenAddress];
  // console.log("USDC contract deployed to: ", );

  // const Nft = await ethers.getContractFactory("InfinitexNFT");
  // const nft = await Nft.deploy(
  //   constructorArguments[0],
  //   constructorArguments[1],
  //   constructorArguments[2],
  //   constructorArguments[3]
  // );

  // await nft.deployed();

  // console.log("NFT contract deployed to: ", nft.address);

  setTimeout(async () => {
    console.log(`Verifying NFT contract on Etherscan...`);

    await run(`verify:verify`, {
      address: "0xeea1cFb9266220aB1Ef3c8002274B92695A90190",
      constructorArguments: constructorArguments,
    });

    // console.log("Verifying USDC contract on Etherscan...");

    // await run(`verify:verify`, {
    //   address: usdc.address,
    //   constructorArguments: [minter],
    // });
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
