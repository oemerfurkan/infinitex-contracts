import { ethers, network, run } from "hardhat";

async function main() {
  console.log(`Verifying contract on Etherscan...`);

  await run(`verify:verify`, {
    address: "0x428D0c87a58E361d92e703D4cd9e15122Be7F8ac",
    constructorArguments: [
      "0x42b29aFfdEe56D0d9f9f4512E18C96e85F34f70D",
      "0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC",
      "ipfs://QmS8rz2EUVuL674KxiNv4efUd8Qtz4Vd3mqnTLcFkEQzXZ/",
      [955, 955, 955, 4780, 4780, 6670, 9520, 9520, 9520, 9520, 95200],
      "0x42b29aFfdEe56D0d9f9f4512E18C96e85F34f70D",
      "0xc98b4b1e373A1292388F4CBC425D0258875DDF75",
    ],
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
