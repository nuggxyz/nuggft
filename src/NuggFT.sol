// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721Metadata} from './interfaces/IERC721.sol';

import {INuggFT as a} from './interfaces/INuggFT.sol';

import {TokenExternal as Token} from './token/TokenExternal.sol';
import {SwapExternal as Swapable} from './swap/SwapExternal.sol';
import {ProofExternal as Provable} from './proof/ProofExternal.sol';
import {FileExternal as dotnuggV1} from './file/FileExternal.sol';
import {StakeExternal as Staked} from './stake/StakeExternal.sol';
import {LoanExternal as Loanable} from './loan/LoanExternal.sol';
import {EpochExternal as Epoched} from './epoch/EpochExternal.sol';
import {TrustExternal as Migratable} from './trust/TrustExternal.sol';

/// @title NuggFT V1
/// @author nugg.xyz - danny7even & dub6ix
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
/// @dev the words "share" and "nugg" are used interchangably throughout

/// deviations from ERC721 standard:
/// 1. no verificaiton the receiver is a ERC721Reciever - on top of this being a gross waste of gas,
/// the way the swapping logic works makes this only worth calling when a user places an offer - and
/// we did not want to call "onERC721Recieved" when no token was being sent.
/// 2.
contract NuggFT is a, Swapable, Provable, Loanable, Migratable, Staked, Epoched, dotnuggV1, Token {
    constructor(address _defaultResolver) dotnuggV1(_defaultResolver) {}

    function tokenURI(uint256 tokenId) public view override(dotnuggV1, IERC721Metadata) returns (string memory) {
        return dotnuggV1.tokenURI(tokenId);
    }

    function name() public pure override returns (string memory) {
        return 'Nugg Fungible Token V1';
    }

    function symbol() public pure override returns (string memory) {
        return 'NUGGFT';
    }
}
