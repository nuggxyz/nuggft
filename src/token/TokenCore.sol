// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';
import {SafeCastLib} from '../libraries/SafeCastLib.sol';

import {Token} from './TokenStorage.sol';
import {Global} from '../global/GlobalStorage.sol';

import {TokenView} from './TokenView.sol';

import {StakeCore} from '../stake/StakeCore.sol';
import {ProofCore} from '../proof/ProofCore.sol';

// system test
library TokenCore {
    using SafeCastLib for uint256;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRANSFER
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function checkedTransferFromSelf(address to, uint160 tokenId) internal {
        Token.ptr().owners[tokenId] = to;

        emit Transfer(address(this), to, tokenId);
    }

    function approvedTransferToSelf(uint160 tokenId) internal {
        require(TokenView.isOperatorForOwner(msg.sender, tokenId) && TokenView.getApproved(tokenId) == address(this), 'T:4');

        delete Token.ptr().owners[tokenId];

        // Clear approvals from the previous owner
        delete Token.ptr().approvals[tokenId];

        emit Transfer(msg.sender, address(this), tokenId);
    }

    function emitTransferEvent(
        address from,
        address to,
        uint160 tokenId
    ) internal {
        emit Transfer(from, to, tokenId);
    }

    function onBurn(uint160 tokenId) internal {
        require(TokenView.getApproved(tokenId) == address(this), 'T:6');

        require(TokenView.ownerOf(tokenId) == msg.sender, 'T:7');

        delete Token.ptr().owners[tokenId];
        delete Token.ptr().approvals[tokenId];

        delete Global.ptr().swap.map[tokenId];
        delete Global.ptr().loan.map[tokenId];
        delete Global.ptr().proof.map[tokenId];
        delete Global.ptr().file.resolvers[tokenId];

        emit Transfer(msg.sender, address(0), tokenId);
    }
}
