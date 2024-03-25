import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("InfinitexNFT ERC1155", function () {
  async function deployOneYearLockFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Nft = await ethers.getContractFactory("Infinitex");
    const nft = await Nft.deploy(owner.address, "", "");

    return { nft, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should deploy the contract", async function () {
      const { nft } = await loadFixture(deployOneYearLockFixture);
      expect(nft.address).to.not.be.undefined;
    });
    it("Should set the owner", async function () {
      const { nft, owner } = await loadFixture(deployOneYearLockFixture);
      expect(await nft.owner()).to.equal(owner.address);
    });
    it("Sould set NFTs as non-transfarable by default", async function () {
      const { nft } = await loadFixture(deployOneYearLockFixture);
      for (let i = 0; i <= 14; i++) {
        expect(await nft.isTransferable(i)).to.equal(false);
      }
    });
  });
  describe("Minting", function () {
    it("Should not allow minting by non-owner", async function () {
      const { nft, otherAccount } = await loadFixture(deployOneYearLockFixture);
      await expect(nft.connect(otherAccount).mint(otherAccount.address, 3, 1, "0x")).to.be.reverted;
    });
    it("Should mint a new NFT", async function () {
      const { nft, owner } = await loadFixture(deployOneYearLockFixture);
      await nft.mint(owner.address, 3, 1, "0x");
      expect(await nft.balanceOf(owner.address, 3)).to.equal(1);
    });
    it("Should set the URI for the minted NFT", async function () {
      const { nft, owner } = await loadFixture(deployOneYearLockFixture);
      await nft.mint(owner.address, 3, 1, "0x");
      expect(await nft.uri(3)).to.equal("ipfs://QmPR4xcJQNgFW1xtuXBxC2XcZs1FDGNNJDRtQEwUKvu6Zi/3.json");
    });
    it("Should set the NFT as transferable", async function () {
      const { nft, owner } = await loadFixture(deployOneYearLockFixture);
      await nft.setTransferable(3, true);
      expect(await nft.isTransferable(3)).to.equal(true);
    });
  });
  describe("Transfers", function () {
    it("Should not allow transfers of non-transferable NFTs", async function () {
      const { nft, owner, otherAccount } = await loadFixture(deployOneYearLockFixture);
      await nft.mint(owner.address, 3, 1, "0x");
      await expect(nft.safeTransferFrom(owner.address, otherAccount.address, 3, 1, "0x")).to.be.revertedWith("Token is non-transferable");
    });
    it("Could owner change transferability of NFTs", async function () {
      const { nft, owner } = await loadFixture(deployOneYearLockFixture);
      await nft.mint(owner.address, 3, 1, "0x");
      await nft.setTransferable(3, true);
      expect(await nft.isTransferable(3)).to.equal(true);
      await nft.setTransferable(3, false);
      expect(await nft.isTransferable(3)).to.equal(false);
    });
    it("Should allow transfers of transferable NFTs", async function () {
      const { nft, owner, otherAccount } = await loadFixture(deployOneYearLockFixture);
      await nft.mint(owner.address, 3, 1, "0x");
      await nft.setTransferable(3, true);
      await nft.safeTransferFrom(owner.address, otherAccount.address, 3, 1, "0x");
      expect(await nft.balanceOf(otherAccount.address, 3)).to.equal(1);
    });
  });
});
