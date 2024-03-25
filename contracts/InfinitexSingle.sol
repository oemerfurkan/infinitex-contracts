// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract InfinitexSingle is ERC1155, Ownable {
    uint8 public constant USDC_DECIMALS = 6;

    IERC20 private _usdcToken;

    bool public _isTransfarable;
    uint256 public _nftPrice;

    /**
     * @dev Constructor
     * @param _owner Address of the owner
     * @param _usdcTokenAddress Address of the USDC token
     * @param _tokenURI IPFS CID of the metadata
     * @notice The constructor initializes the contract with the owner, USDC token address and IPFS CID
     */
    constructor(
        address _owner,
        address _usdcTokenAddress,
        string memory _tokenURI
    ) ERC1155(_tokenURI) Ownable(_owner) {
        _usdcToken = IERC20(_usdcTokenAddress);
    }

    // Check if the token id is in the range of 0 to 14
    function updateNFTPrice(uint256 price) external onlyOwner {
        _nftPrice = price;
    }

    /**
     * @dev Get the NFT price for a given token id
     * @param tokenId Token id
     * @return The price of the NFT
     */
    function getNFTPrice(uint256 tokenId) external view returns (uint256) {
        require(tokenId >= 0 && tokenId <= 10, "Invalid token id.");
        return _nftPrice;
    }

    /**
     * @dev Mint NFTs
     * @param account Address of the recipient account
     * @param id Token id to mint
     * @param amount Amount of NFTs to mint
     * @param data Metadata
     * @notice The function mints NFTs
     */
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external payable {
        require(amount > 0, "Invalid amount.");
        require(
            _usdcToken.transferFrom(
                msg.sender,
                address(this),
                _nftPrice * 10 ** USDC_DECIMALS
            ),
            "Infinitex: USDC Payment reverted."
        );
        _mint(account, id, amount, data);
    }

    /**
     * @dev Set the transferable status of a token
     * @param _isTransferable Transferable status
     * @notice The function sets the transferable status of a token
     */
    function setTransferable(
        bool _isTransferable
    ) external onlyOwner {
        _isTransfarable = _isTransferable;
    }

    /**
     * @dev Check if a token is transferable
     * @return True if the token is transferable, false otherwise
     * @notice The function checks if a token is transferable
     */
    function isTransferable() external view returns (bool) {
        return _isTransfarable;
    }

    /**
     * @dev Check the URI of a token
     * @param id Token id
     * @return The URI of the token
     */
    function uri(uint256 id) public view override returns (string memory) {
        require(id == 0, "Invalid token id.");
        return super.uri(id);
    }

    function withdrawUSDC() external onlyOwner {
        _usdcToken.transfer(owner(), _usdcToken.balanceOf(address(this)));
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     * @notice The function overrides the safeTransferFrom function to check if the token is transferable
     * @param from Address of the sender
     * @param to Address of the recipient
     * @param id Token id
     * @param amount Amount of tokens
     * @param data Metadata
     * @notice The function transfers tokens from one account to another
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        require(_isTransfarable, "Token is non-transferable");
        super.safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     * @notice The function overrides the safeBatchTransferFrom function to check if the tokens are transferable
     * @param from Address of the sender
     * @param to Address of the recipient
     * @param ids Token ids
     * @param amounts Amounts of tokens
     * @param data Metadata
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override {
        for (uint256 i = 0; i < ids.length; ++i) {
            require(
                _isTransfarable,
                "One or more tokens are non-transferable"
            );
        }
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}
