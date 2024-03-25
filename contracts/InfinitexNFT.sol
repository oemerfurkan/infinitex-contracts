// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract InfinitexNFT is ERC721, ERC721URIStorage, AccessControl, Ownable {
    
    bool public isTransferable;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _nextTokenId;

    uint256 constant MAX_MINT_PRICE = 10000;
    uint256 constant MIN_MINT_PRICE = 1;

    ERC20 private token;
    mapping(uint256 _tokenId => uint256 _price) public prices;

    constructor(
        address defaultAdmin, 
        address minter, 
        address owner, 
        address tokenAddress
    ) 
        ERC721("Infinitex", "IFX") 
        Ownable(owner) 
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        token = ERC20(tokenAddress);
    }

    function safeMint(address to, string memory uri, uint256 price) 
        public 
        onlyRole(MINTER_ROLE) 
    {
        uint256 tokenId = _nextTokenId++;
        require(price >= MIN_MINT_PRICE && price <= MAX_MINT_PRICE, "Inifinitex: Price doesn't satisfy the requirements.");
        require(token.transferFrom(to, owner(), price * 10 ** token.decimals()), "Infinitex: Error in token transfer.");
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        prices[tokenId] = price;
    }

    function transferFrom(address from, address to, uint256 tokenId) 
        public 
        override(ERC721, IERC721) 
    {
        require(isTransferable, "Infinitex: Token is not transferable.");
        super.transferFrom(from, to, tokenId);
    }

    function setIsTransferable(bool newVal) public onlyOwner {
        isTransferable = newVal;
    }

    function getPrice(uint256 _tokenId) public view returns (uint256) {
        return prices[_tokenId];
    }

    function getPrices() public view returns (uint256[] memory) {
        uint256[] memory _prices = new uint256[](_nextTokenId);
        for (uint256 i = 0; i < _nextTokenId; i++) {
            _prices[i] = prices[i];
        }
        return _prices;
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
