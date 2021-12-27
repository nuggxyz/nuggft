// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC165, IERC721Metadata} from './interfaces/IERC721.sol';

import {NuggftV1Loan} from './core/NuggftV1Loan.sol';
import {NuggftV1Dotnugg} from './core/NuggftV1Dotnugg.sol';
import {Trust} from './core/Trust.sol';

import {INuggftV1Migrator} from './interfaces/nuggftv1/INuggftV1Migrator.sol';
import {IDotnuggV1Data} from './interfaces/dotnuggv1/IDotnuggV1Data.sol';
import {IDotnuggV1Implementer} from './interfaces/dotnuggv1/IDotnuggV1Implementer.sol';
import {IDotnuggV1ImplementerMetadata} from './interfaces/dotnuggv1/IDotnuggV1ImplementerMetadata.sol';
import {IDotnuggV1Processor} from './interfaces/dotnuggv1/IDotnuggV1Processor.sol';

import {INuggftV1Token} from './interfaces/nuggftv1/INuggftV1Token.sol';
import {INuggftV1Stake} from './interfaces/nuggftv1/INuggftV1Stake.sol';

import {INuggftV1} from './interfaces/nuggftv1/INuggftV1.sol';

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
contract NuggftV1 is IERC721Metadata, NuggftV1Loan {
    using SafeCastLib for uint256;

    using NuggftV1StakeType for uint256;

    constructor(address _defaultResolver) NuggftV1Dotnugg(_defaultResolver) Trust(msg.sender) {}

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IDotnuggV1Implementer).interfaceId ||
            interfaceId == type(IDotnuggV1ImplementerMetadata).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function name() public pure override returns (string memory) {
        return 'Nugg Fungible Token V1';
    }

    function symbol() public pure override returns (string memory) {
        return 'NUGGFT';
    }

    /// @inheritdoc IERC721Metadata
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory res) {
        uint160 safeTokenId = tokenId.safe160();

        address resolver = hasResolver(safeTokenId) ? dotnuggV1ResolverOf(safeTokenId) : dotnuggV1Processor;

        (, res) = IDotnuggV1Processor(dotnuggV1Processor).dotnuggToUri(
            address(this),
            tokenId,
            resolver,
            dotnuggV1DefaultWidth,
            dotnuggV1DefaultZoom
        );
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                CORE
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @inheritdoc IDotnuggV1Implementer
    function dotnuggV1Callback(uint256 tokenId) public view override returns (IDotnuggV1Data.Data memory data) {
        (uint256 proof, uint8[] memory ids, uint8[] memory extras, uint8[] memory xovers, uint8[] memory yovers) = parsedProofOf(
            tokenId.safe160()
        );

        data = IDotnuggV1Data.Data({
            version: 1,
            renderedAt: block.timestamp,
            name: 'NuggFT V1',
            desc: 'Nugg Fungible Token V1',
            // code that throws error: owner: proof != 0 ? _ownerOf(tokenId.safe160()) : address(0),
            owner: owners[tokenId], // fix
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

        // require(!exists(tokenId), 'G:2');

        addStakedShareFromMsgValue();

        setProof(tokenId);

        _mintTo(to, tokenId);
    }

    /// @inheritdoc INuggftV1Token
    function mint(uint160 tokenId) public payable override {
        require(tokenId < UNTRUSTED_MINT_TOKENS + TRUSTED_MINT_TOKENS && tokenId > TRUSTED_MINT_TOKENS, 'G:1');

        // require(!exists(tokenId), 'G:2');

        addStakedShareFromMsgValue();

        setProof(tokenId);

        _mintTo(msg.sender, tokenId);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                BURN/MIGRATE
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Stake
    function burn(uint160 tokenId) external {
        uint96 ethOwed = subStakedShare(tokenId);

        SafeTransferLib.safeTransferETH(msg.sender, ethOwed);

        emit Burn(tokenId, msg.sender, ethOwed);
    }

    /// @inheritdoc INuggftV1Stake
    function migrate(uint160 tokenId) external {
        require(migrator != address(0), 'T:4');

        // stores the proof before deleting the nugg
        uint256 proof = proofOf(tokenId);

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
        // reverts if token does not exist
        address owner = _ownerOf(tokenId);

        require(_getApproved(tokenId) == address(this) && owner == msg.sender, 'T:3');

        uint256 cache = stake;

        // hanles all logic not related to staking the nugg
        delete owners[tokenId];
        delete approvals[tokenId];

        delete swaps[tokenId];
        delete loans[tokenId];
        delete proofs[tokenId];
        delete resolvers[tokenId];

        emitTransferEvent(owner, address(0), tokenId);

        ethOwed = calculateEthPerShare(cache);

        /// TODO - test migration
        assert(cache.shares() >= 1);
        assert(cache.staked() >= ethOwed);

        cache = cache.subShares(1);
        cache = cache.subStaked(ethOwed);

        stake = cache;

        emit UnstakeEth(ethOwed, msg.sender);
    }
}
