// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Global} from './storage.sol';

import {TokenCore} from '../token/core.sol';

library GlobalCore {
    function burn(uint256 tokenId) internal {
        TokenCore.onBurn(tokenId);

        delete Global.ptr().swap.map[tokenId];
        delete Global.ptr().loan.map[tokenId];
        delete Global.ptr().proof.map[tokenId];

        delete Global.ptr().vault.resolvers[tokenId];

        delete Global.ptr().token.owners[tokenId];
        delete Global.ptr().token.approvals[tokenId];
    }
}
