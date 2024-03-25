import { ethers } from "hardhat";

const uris = [
  "ipfs://Qmc9cuQ42J1GFnnGJQeUwnVJTVLBukEDMHzykq8sPrWEeE/0",
  "ipfs://QmXJdjmodTis8vK9EAonjNU67yQ4AD4eNbVb56hgpj3DvC/1",
  "ipfs://QmZbQru9haEvUxNKTKnMQ3YPcLLuhkbnDmQ8aC5FBbDnFs/2",
  "ipfs://QmSnUFj9szQRR9pnihruPGaJKBHMUG26i34Sd5wpC3s6Et/3",
  "ipfs://QmSYysuzFMa1PKpcKD6Y6PK69e3XjcEgBFhoibFrGKeKjh/4",
  "ipfs://QmcQQEHVCNFCPrNMJFRFh8oVnpKpbm4NFwLKQ2JYRP4jvf/5",
  "ipfs://QmNZiYvR7VzXUzQZ9NL9oS8xweP5YcfTYGbdKx9W4wVWqb/6",
  "ipfs://QmWV1gAzNEcCcts5ccnqsvyLs3HpJqx4JvtV39c5khz3Bj/7",
  "ipfs://QmZw84uo2y8o53CmygX5xZJ2Ku5M1R5C3UHoc6S1awJWx2/8",
  "ipfs://QmXcuKt4o5zCcQRVTFXz3JJ9fZrGb8wra2DGLPg5RFhzVU/9",
  "ipfs://QmV1bD7tHqoG5LwsB3kNcxkozegQAJRqFCFFzeBXSdqkw3/10",
  "ipfs://QmQRxP2xeZ9gpPPRhJpJTuRGBonTS477UZVzED3iyLg9dG/11",
  "ipfs://Qmf9PKn57Zaf5QcNUchKbbkDd7gXfQER9dto3x247QdoGX/12",
  "ipfs://QmWS9qjvJ5coDwPqncag6UP7LUy9EbMTCvUUKL8bhhbZe4/13",
  "ipfs://QmWrG2XiGjoSJULtkdtuS3GTwzd1o2HgxCvdVps8kQ1U2U/14",
];

async function main() {
  const accounts = await ethers.getSigners();

  const Usdc = await ethers.getContractFactory("MockUSDC");
  const usdc = await Usdc.deploy(accounts[0].address);

  await usdc.deployed();

  const Nft = await ethers.getContractFactory("Infinitex");
  const nft = await Nft.deploy(
    accounts[0].address,
    usdc.address,
    "ipfs://QmS8rz2EUVuL674KxiNv4efUd8Qtz4Vd3mqnTLcFkEQzXZ/",
    [955, 955, 955, 4780, 4780, 6670, 9520, 9520, 9520, 9520, 95200]
  );

  await nft.deployed();

  console.log("Infinitex ERC1155 token address is: ", nft.address);

  const nftContract = await ethers.getContractAt("Infinitex", nft.address);
  const usdcContract = await ethers.getContractAt("MockUSDC", usdc.address);

  const uriVal = await nftContract.uri(0);
  console.log("URI value for token 0 is: ", uriVal);

  const balance1 = await nftContract.balanceOf(accounts[0].address, 1);
  console.log("Balance of token 1 is: ", balance1.toString());

  const approval = await usdcContract.approve(nftContract.address, 10 * 10 ** 6)
  console.log("Approval TX: ", approval.data)

  const tx = await nftContract.mint(accounts[0].address, 1, 1, "0x");

  console.log("Minting transaction: ", tx.hash);

  const balance2 = await nftContract.balanceOf(accounts[0].address, 1);
  console.log("Balance of token 1 is: ", balance2.toString());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
