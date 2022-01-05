// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ERC721Connector.sol';

contract KryptoBird is ERC721Connector {

    // initialize contract to inherit name and symbol from erc721 data so that
    // the name is KryptoBird and the symbol is KBIRDZ

    constructor() ERC721Connector('KryptoBird', 'KBIRDZ') {}
}

