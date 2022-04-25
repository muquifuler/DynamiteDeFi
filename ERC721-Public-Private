// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT_Public_Private is ERC721
{
    uint256 private token_count;
    
    // Mapping from token ID to owner hash
    mapping(uint256 => bytes32) private _hashes;

    constructor() ERC721("Bitcoin Whitepaper","BTC-W") {}

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        if(_hashes[tokenId] == keccak256(abi.encodePacked(msg.sender,tokenId))){
            return "https://ipfs.io/ipfs/QmT1RYrfvUhGB8j52fPrmFHExYG43Y6g1gNSaeEAU8ikjJ?filename=nft-private.json";
        }else{
            return "https://ipfs.io/ipfs/QmeXX2dcauN7HrHpbbeMiDtjUpYxFWKKWCpVrZbFrMzBjv?filename=nft-public.json";
        }
    }

    function mintNFT(address to) public

    {
        token_count += 1;
        _mint(to, token_count);
        _hashes[token_count] = keccak256(abi.encodePacked(msg.sender,token_count));
    }

}
