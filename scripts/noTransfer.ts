import { ethers } from "hardhat";

async function main() {
  const nftContract = await ethers.getContractAt(
    "InfinitexNFT",
    "0x3F787404CF24729D7F32CFCC40dafA2D1a87fAba"
  );

  const tx = await nftContract.setTransferable(3, true);
  console.log("Transaction: ", tx.hash);

  try {
    const tx = await nftContract.safeTransferFrom(
      "0x42b29aFfdEe56D0d9f9f4512E18C96e85F34f70D",
      "0xa2e5306F55872af862B0fbf44a89484955a6BeDe",
      3,
      1,
      "0x"
    );
    console.log("Transaction: ", tx.hash);
  } catch (error) {
    console.error("Error: ", error);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
