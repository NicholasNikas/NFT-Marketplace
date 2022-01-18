// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ERC165.sol';
import './interfaces/IERC721.sol';
import './Libraries/Counters.sol';

    /*
    building out the minting function:
    a. nft to point to an address
    b. keep track of the token ids
    c. keep track of token owners addresses to token ids
    d. keep track of how many tokens an owner address has
    e. create an event that emits a transfer log - contract address, where 
       its being minted to, the id
    */

contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    // mapping in solidity creates a hash table of key pair values

    // Mapping from token id to owner
    mapping(uint256 => address) private _tokenOwner;

    // Mapping from owner to number of owned tokens
    mapping(address => Counters.Counter) private _ownedTokensCount;

    // Mapping from token id to approved addresses
    mapping(uint256 => address) private _tokenApprovals;

    constructor() {
        _registerInterface(
            bytes4(
                keccak256('balanceOf(bytes4)')
                ^
                keccak256('ownerOf(bytes4)')
                ^
                keccak256('transferFrom(bytes4)')
            )
        );
    }

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), 'Error: owner query for non-existent token');
        return _ownedTokensCount[_owner].current();
    }

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0), 'Error: tokenId query for non-existent owner');
        return owner;
    }

    function _exists(uint256 tokenId) internal view returns(bool) {
        // setting address of NFT owner to check the mapping 
        // of the address from tokenOwner to tokenId
        address owner = _tokenOwner[tokenId];
        // return truthiness that address is not zero
        return owner != address(0);
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        // requires that the address isn't zero
        require(to != address(0),'ERC721: minting to the zero address');
        // requires that the token does not already exist
        require(!_exists(tokenId), 'ERC721: token already minted');
        // we are adding a new address with a token id for minting
        _tokenOwner[tokenId] = to;
        // keeping track of each address thsat is minting and adding one to the count
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(_to != address(0),'Error: transfer to the zero address');
        require(_from != address(0),'Error: transfer from the zero address');
        require(ownerOf(_tokenId) == _from,'Error: trying to transfer a token address owner does not own');

        _tokenOwner[_tokenId] = _to;
        _ownedTokensCount[_from].decrement();
        _ownedTokensCount[_to].increment();

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) override public {
        approve(_to, _tokenId);
        require(isApprovedOrOwner(msg.sender,_tokenId));
        _transferFrom(_from, _to, _tokenId);
    }

    // 1. require that the person approving is the owner
    // 2. we are approving an address to a token (tokenId)
    // 3. require that we cant approve sending tokens of the owner to the owner (current caller)
    // 4. update the map of the approval addresses
    function _approve(address _to, uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        require(_to != owner, 'Error: approval to current owner');
        require(msg.sender == owner, 'Error: current caller is not the owner of the token');

        _tokenApprovals[tokenId] = _to;

        emit Approval(owner, _to, tokenId);
    }

    function approve(address _to, uint256 tokenId) override public {
        _approve(_to, tokenId);
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) internal view returns(bool) {
        require(_exists(tokenId),'Error: token does not exist');
        address owner = ownerOf(tokenId);

        return(spender == owner || getApproved(tokenId) == spender);
    }

    function getApproved(uint256 tokenId) public view returns(address) {
        require(_exists(tokenId), 'Error: token does not exist');

        return _tokenApprovals[tokenId];
    }
}