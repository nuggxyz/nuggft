// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IdotnuggV1Data} from '../interfaces/IdotnuggV1.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SSTORE2} from '../libraries/SSTORE2.sol';

import {File} from './FileStorage.sol';
import {FilePure} from './FilePure.sol';
import {FileView} from './FileView.sol';
import {ProofPure} from '../proof/ProofPure.sol';
import {ProofView} from '../proof/ProofView.sol';

import {TokenView} from '../token/TokenView.sol';

import {Trust} from '../trust/TrustStorage.sol';

library FileCore {
    using FilePure for uint256;
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                PROCESS FILES
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                RESOLVER SET
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function setResolver(uint160 tokenId, address to) internal {
        require(TokenView.isApprovedOrOwner(msg.sender, tokenId), 'T:0');

        File.spointer().resolvers[tokenId] = to;
    }
}
