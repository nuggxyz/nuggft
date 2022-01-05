// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IERC721, IERC165, IERC721Metadata} from './interfaces/IERC721.sol';

import {NuggftV1Loan} from './core/NuggftV1Loan.sol';
import {NuggftV1Dotnugg} from './core/NuggftV1Dotnugg.sol';
import {Trust} from './core/Trust.sol';

import {INuggftV1Migrator} from './interfaces/nuggftv1/INuggftV1Migrator.sol';
import {IDotnuggV1Metadata} from './interfaces/dotnuggv1/IDotnuggV1Metadata.sol';
import {IDotnuggV1Implementer} from './interfaces/dotnuggv1/IDotnuggV1Implementer.sol';
import {IDotnuggV1} from './interfaces/dotnuggv1/IDotnuggV1.sol';

import {INuggftV1Token} from './interfaces/nuggftv1/INuggftV1Token.sol';
import {INuggftV1Stake} from './interfaces/nuggftv1/INuggftV1Stake.sol';

import {INuggftV1} from './interfaces/nuggftv1/INuggftV1.sol';

import {SafeTransferLib} from './libraries/SafeTransferLib.sol';
import {SafeCastLib} from './libraries/SafeCastLib.sol';
import {ShiftLib} from './libraries/ShiftLib.sol';

import {NuggftV1StakeType} from './types/NuggftV1StakeType.sol';
import {NuggftV1ProofType} from './types/NuggftV1ProofType.sol';

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

        address resolver = hasResolver(safeTokenId) ? dotnuggV1ResolverOf(safeTokenId) : address(0);

        res = IDotnuggV1(dotnuggV1).dotnuggToSvg(address(this), tokenId, resolver, 10, true, false, true, false, '');
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                CORE
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function dotnuggV1ImplementerCallback(uint256 tokenId) public view override returns (IDotnuggV1Metadata.Memory memory data) {
        (
            ,
            data.ids, //
            data.xovers,
            data.yovers,
            data.styles,
            data.background
        ) = proofToDotnuggMetadata(tokenId.safe160());

        data.labels = new string[](8);

        data.labels[0] = 'BASE';
        data.labels[1] = 'EYES';
        data.labels[2] = 'MOUTH';
        data.labels[3] = 'HAIR';
        data.labels[4] = 'HAT';
        data.labels[5] = 'BACK';
        data.labels[6] = 'NECK';
        data.labels[7] = 'HOLD';

        return data;
    }

    /// @inheritdoc INuggftV1Token
    function trustedMint(uint160 tokenId, address to) external payable override requiresTrust {
        require(tokenId < TRUSTED_MINT_TOKENS && tokenId != 0, 'G:1');

        // require(!exists(tokenId), 'G:2');

        addStakedShareFromMsgValue();

        setProof(tokenId);

        _mintTo(to, tokenId);
    }

    // modifier haha() {
    //     uint256 price = gasleft();

    //     _;
    //     uint256 price2 = gasleft();
    //     // console.log(price, price2, price - price2);
    //     assert(price < 90000 && price - price2 < 58000);
    // }

    /// @inheritdoc INuggftV1Token
    function mint(uint160 tokenId) public payable override {
        // uint256 price = gasleft();
        // console.log(price);

        require(tokenId < UNTRUSTED_MINT_TOKENS + TRUSTED_MINT_TOKENS && tokenId > TRUSTED_MINT_TOKENS, 'G:1');

        // require(!exists(tokenId), 'G:2');

        addStakedShareFromMsgValue();

        setProof(tokenId);

        _mintTo(msg.sender, tokenId);

        // uint256 price2 = gasleft();
        // console.log('used: ', price - price2);
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
    }
}
