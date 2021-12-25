// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {NuggftV1Loan} from './core/NuggftV1Loan.sol';
import {NuggftV1File} from './core/NuggftV1File.sol';
import {Trust} from './core/Trust.sol';

import {INuggftV1Migrator} from './interfaces/nuggftv1/INuggftV1Migrator.sol';
import {IdotnuggV1Data} from './interfaces/IdotnuggV1.sol';
import {IdotnuggV1Implementer} from './interfaces/IdotnuggV1.sol';

import {INuggftV1Token} from './interfaces/nuggftv1/INuggftV1Token.sol';
import {INuggftV1Stake} from './interfaces/nuggftv1/INuggftV1Stake.sol';
// import {INuggftV1Proof as Provable} from './interfaces/nuggftv1/INuggftV1Proof.sol';
// import {INuggftV1File as dotnuggv1} from './interfaces/nuggftv1/INuggftV1File.sol';
// import {INuggftV1Swap as Swapable} from './interfaces/nuggftv1/INuggftV1Swap.sol';
// import {INuggftV1Loan as Loanable} from './interfaces/nuggftv1/INuggftV1Loan.sol';
// import {INuggftV1Epoch as Epoched} from './interfaces/nuggftv1/INuggftV1Epoch.sol';

import {ITrust} from './interfaces/ITrust.sol';

import {SafeTransferLib} from './libraries/SafeTransferLib.sol';
import {SafeCastLib} from './libraries/SafeCastLib.sol';

import {NuggftV1StakeType} from './types/NuggftV1StakeType.sol';

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
contract NuggftV1 is NuggftV1Loan {
    using SafeCastLib for uint256;

    using NuggftV1StakeType for uint256;

    constructor(address _defaultResolver) NuggftV1File(_defaultResolver) Trust(msg.sender) {}

    function tokenURI(uint256 tokenId) public view override(NuggftV1File) returns (string memory) {
        return NuggftV1File.tokenURI(tokenId);
    }

    function name() public pure override returns (string memory) {
        return 'Nugg Fungible Token V1';
    }

    function symbol() public pure override returns (string memory) {
        return 'NUGGFT';
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                CORE
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc IdotnuggV1Implementer
    function prepareFiles(uint256 tokenId) public view override returns (uint256[][] memory input, IdotnuggV1Data.Data memory data) {
        (
            uint256 proof,
            uint8[] memory ids,
            uint8[] memory extras,
            uint8[] memory xovers,
            uint8[] memory yovers
        ) = parsedProofOfIncludingPending(tokenId.safe160());

        input = getBatchFiles(ids);

        data = IdotnuggV1Data.Data({
            version: 1,
            renderedAt: block.timestamp,
            name: 'NuggFT V1',
            desc: 'Nugg Fungible Token V1',
            owner: exists(tokenId.safe160()) ? _ownerOf(tokenId.safe160()) : address(0),
            tokenId: tokenId,
            proof: proof,
            ids: ids,
            extras: extras,
            xovers: xovers,
            yovers: yovers
        });
    }

    /// @inheritdoc INuggftV1Token
    function trustedMint(uint160 tokenId, address to) external payable override requiresTrust {
        require(tokenId < TRUSTED_MINT_TOKENS && tokenId != 0, 'G:1');

        require(!exists(tokenId), 'G:2');

        addStakedShareFromMsgValue();

        setProof(tokenId);

        _mintTo(to, tokenId);
    }

    /// @inheritdoc INuggftV1Token
    function mint(uint160 tokenId) public payable override {
        require(tokenId < UNTRUSTED_MINT_TOKENS + TRUSTED_MINT_TOKENS && tokenId > TRUSTED_MINT_TOKENS, 'G:1');

        require(!exists(tokenId), 'G:2');

        addStakedShareFromMsgValue();

        setProof(tokenId);

        _mintTo(msg.sender, tokenId);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                BURN/MIGRATE
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Stake
    function withdrawStake(uint160 tokenId) external {
        uint96 ethOwed = subStakedShare(tokenId);

        SafeTransferLib.safeTransferETH(msg.sender, ethOwed);
    }

    /// @inheritdoc INuggftV1Stake
    function migrateStake(uint160 tokenId) external {
        require(migrator != address(0), 'T:4');

        // stores the proof before deleting the nugg
        uint256 proof = checkedProofOf(tokenId);

        uint96 ethOwed = subStakedShare(tokenId);

        INuggftV1Migrator(migrator).nuggftMigrateFromV1{value: ethOwed}(tokenId, proof, msg.sender);

        emit MigrateV1Sent(migrator, tokenId, proof, msg.sender, ethOwed);
    }

    /// @notice removes a staked share from the contract,
    /// @dev this is the only way to remove a share
    /// @dev caculcates but does not handle dealing the eth - which is handled by the two helpers above
    /// @dev ensures the user is the owner of the nugg
    /// @param tokenId the id of the nugg being unstaked
    /// @return ethOwed -> the amount of eth owed to the unstaking user - equivilent to "ethPerShare"
    function subStakedShare(uint160 tokenId) internal returns (uint96 ethOwed) {
        address owner = _ownerOf(tokenId);

        require(_getApproved(tokenId) == address(this) && _isOperatorFor(msg.sender, owner), 'T:3');

        uint256 cache = stake;

        // hanles all logic not related to staking the nugg
        delete owners[tokenId];
        delete approvals[tokenId];

        delete swaps[tokenId];
        delete loans[tokenId];
        delete proofs[tokenId];
        delete resolvers[tokenId];

        emitTransferEvent(owner, address(0), tokenId);

        ethOwed = getEthPerShare(cache);

        /// TODO - test migration
        assert(cache.shares() >= 1);
        assert(cache.staked() >= ethOwed);

        cache = cache.subShares(1);
        cache = cache.subStaked(ethOwed);

        stake = cache;

        emit UnStakeEth(ethOwed, msg.sender);
    }
}
