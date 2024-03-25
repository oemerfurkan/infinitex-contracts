//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {
    constructor(address _owner) ERC20("USDC", "USDC") {
        _mint(_owner, 1000000 * (10 ** uint256(decimals())));
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}