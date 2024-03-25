import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Infinitex ERC1155 NFTs", () => {
    async function deployOneYearLockFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const Usdc = await ethers.getContractFactory("MockUSDC");
        const usdc = await Usdc.deploy();
    
        const Nft = await ethers.getContractFactory("Infinitex");
        const nft = await Nft.deploy(owner.address, usdc.address, "ipfs://deneme/");
    
        return { nft, owner, otherAccount };
      }
    describe("Deployment", () => {
    });
})