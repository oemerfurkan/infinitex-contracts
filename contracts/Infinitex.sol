// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Infinitex ERC-1155 contract
 * @notice The contract is an ERC-1155 contract that allows minting of non-transferable NFTs
 */
contract Infinitex is ERC1155, Ownable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bool public isTransferable;

    uint8 public constant USDC_DECIMALS = 6;
    uint8 public constant PRICE_DECIMALS = 2;

    mapping(uint256 => uint256) public _nftPrices;

    IERC20 private _usdcToken;

    /**
     * @dev Constructor
     * @param _owner Address of the owner
     * @param _usdcTokenAddress Address of the USDC token
     * @param _ipfsCID IPFS CID of the metadata
     * @param _prices Prices of the NFTs
     * @param defaultAdmin Default admin address
     * @param minter Minter address
     * @notice The constructor initializes the contract with the owner, USDC token address and IPFS CID
     */
    constructor(
        address _owner,
        address _usdcTokenAddress,
        string memory _ipfsCID,
        uint256[] memory _prices,
        address defaultAdmin,
        address minter
    ) ERC1155(_ipfsCID) Ownable(_owner) {
        _usdcToken = IERC20(_usdcTokenAddress);
        for (uint256 i = 0; i < _prices.length; ++i) {
            require(i <= 10 && i >= 0, "Infinitex: Invalid token id.");
            _nftPrices[i] = _prices[i];
        }
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    /**
     * @dev Update the price of an NFT
     * @param tokenId Token ID to update
     * @param price Price to update
     * @notice The function updates the price of an NFT
     */
    function updateNFTPrice(uint256 tokenId, uint256 price) external onlyOwner {
        require(tokenId >= 0 && tokenId <= 10, "Infinitex: Invalid token id.");
        _nftPrices[tokenId] = price;
    }

    /**
     * @dev Update the prices of the NFTs
     * @param tokenIds Token IDs to update
     * @param prices Token prices to update
     * @notice The function updates the prices of the NFTs
     */
    function batchUpdateNFTPrice(
        uint256[] memory tokenIds,
        uint256[] memory prices
    ) external onlyOwner {
        require(tokenIds.length == prices.length, "Invalid input length");
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            require(i <= 10 && i >= 0, "Infinitex: Invalid token id.");
            _nftPrices[tokenIds[i]] = prices[i];
        }
    }

    /**
     * @dev Get the NFT price for a given token id
     * @param tokenId Token id
     * @return The price of the NFT
     */
    function getNFTPrice(uint256 tokenId) external view returns (uint256) {
        require(tokenId >= 0 && tokenId <= 10, "Infinitex: Invalid token id.");
        return _nftPrices[tokenId];
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
    ) external payable onlyRole(MINTER_ROLE) {
        address _owner = owner();
        uint256 mintPrice = _nftPrices[id] * 10 ** (USDC_DECIMALS - PRICE_DECIMALS);
        require(id >= 0 && id <= 10, "Infinitex: Invalid token id.");
        require(amount > 0, "Infinitex: Invalid amount.");
        require(_usdcToken.allowance(msg.sender, address(this)) >= mintPrice, "Infinitex: Approval check failed.");
        require(_usdcToken.transferFrom(
            msg.sender,
            _owner,
            mintPrice
        ), "Infinitex: Mint payment failed");
        _mint(account, id, amount, data);
    }

    /**
     * @dev Batch mint NFTs
     * @param account Address of the recipient account
     * @param ids Token ids to mint
     * @param amounts Amounts of NFTs to mint
     * @param data Metadata
     * @notice The function mints NFTs in batches
     */
    function batchMint(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external payable onlyRole(MINTER_ROLE) {
        address _owner = owner();
        uint256 totalMintPrice = 0;
        for (uint256 i = 0; i < ids.length; ++i) {
            require(ids[i] >= 0 && ids[i] <= 10, "Infinitex: Invalid token id.");
            totalMintPrice += _nftPrices[ids[i]] * 10 ** (USDC_DECIMALS - PRICE_DECIMALS);
        }
        require(totalMintPrice > 0, "Infinitex: Invalid total mint price.");
        require(_usdcToken.allowance(msg.sender, address(this)) >= totalMintPrice, "Infinitex: Approval check failed.");
        require(_usdcToken.transferFrom(
            msg.sender,
            _owner,
            totalMintPrice
        ), "Infinitex: Mint payment failed");
        _batchMint(account, ids, amounts, data);
    }

    /**
     * 
     * @param account Recipient account
     * @param ids NFT ids to mint
     * @param amounts NFT amounts to mint
     * @param data Data
     */
    function _batchMint(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        for (uint256 i = 0; i < ids.length; ++i) {
            _mint(account, ids[i], amounts[i], data);
        }
    }

    /**
     * @dev Set the transferable status of a token
     * @param _isTransferable Transferable status
     * @notice The function sets the transferable status of a token
     */
    function setTransferable(
        bool _isTransferable
    ) external onlyOwner {
        isTransferable = _isTransferable;
    }

    /**
     * @dev Check the URI of a token
     * @param id Token id
     * @return The URI of the token
     */
    function uri(uint256 id) public view override returns (string memory) {
        require(id >= 0 && id <= 10, "Infinitex: Invalid token id.");
        return
            string(
                abi.encodePacked(super.uri(id), Strings.toString(id), ".json")
            );
    }

    function withdrawUSDC() external onlyOwner {
        _usdcToken.transfer(owner(), _usdcToken.balanceOf(address(this)));
    }

    function withdrawEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
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
        require(isTransferable, "Infinitex: NFT is non-transferable.");
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
                isTransferable,
                "Infinitex: NFT is non-transferable."
            );
        }
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
