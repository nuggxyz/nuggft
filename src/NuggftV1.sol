// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {IERC721, IERC165, IERC721Metadata} from './interfaces/IERC721.sol';

import {NuggftV1Loan} from './core/NuggftV1Loan.sol';
import {NuggftV1Dotnugg} from './core/NuggftV1Dotnugg.sol';

import {INuggftV1Migrator} from './interfaces/nuggftv1/INuggftV1Migrator.sol';
import {IDotnuggV1Metadata} from './interfaces/dotnuggv1/IDotnuggV1Metadata.sol';
import {IDotnuggV1Implementer} from './interfaces/dotnuggv1/IDotnuggV1Implementer.sol';
import {IDotnuggV1} from './interfaces/dotnuggv1/IDotnuggV1.sol';

import {INuggftV1Token} from './interfaces/nuggftv1/INuggftV1Token.sol';
import {INuggftV1Stake} from './interfaces/nuggftv1/INuggftV1Stake.sol';

import {INuggftV1} from './interfaces/nuggftv1/INuggftV1.sol';

import {TransferLib} from './libraries/TransferLib.sol';
import {CastLib} from './libraries/CastLib.sol';
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
    using CastLib for uint256;

    using NuggftV1StakeType for uint256;

    constructor() {
        assembly {
            let addr := mload(0x40)

            mstore(addr, shl(72, or(shl(176, 0xd6), or(shl(168, 0x94), or(shl(8, caller()), 0x02)))))

            addr := keccak256(addr, 23)

            let sig := mload(0x40)

            mstore(sig, hex'8e3b3a6b')

            let ptr := mload(0x40)

            let ok := staticcall(gas(), addr, sig, 0x4, ptr, 32)
            if iszero(ok) {
                revert(sig, 0x4)
            }

            addr := mload(ptr)

            sstore(dotnuggV1.slot, addr)

            // mstore(sig, hex'1aa3a008')

            // ok := call(gas(), addr, 0, sig, 0x4, ptr, 32)
            // if iszero(ok) {
            //     revert(sig, 0x4)
            // }

            // addr := mload(ptr)

            // sstore(dotnuggV1StorageProxy.slot, addr)
        }

        dotnuggV1StorageProxy = dotnuggV1.register();
    }

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
        uint160 safeTokenId = tokenId.to160();

        res = dotnuggV1.dat(address(this), tokenId, dotnuggV1ResolverOf(safeTokenId), symbol(), name(), true, '');
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
        ) = proofToDotnuggMetadata(tokenId.to160());

        data.labels = new string[](8);
        data.version = 1;
        data.artifactId = tokenId;
        data.implementer = address(this);

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
    function mint(uint160 tokenId) public payable override {
        assembly {
            if or(iszero(gt(add(TRUSTED_MINT_TOKENS, UNTRUSTED_MINT_TOKENS), tokenId)), lt(tokenId, TRUSTED_MINT_TOKENS)) {
                mstore8(0x00, Error__A__0x65__TokenNotMintable)
                revert(0x00, 0x01)
            }
        }

        // (tokenId <= UNTRUSTED_MINT_TOKENS + TRUSTED_MINT_TOKENS && tokenId >= TRUSTED_MINT_TOKENS, 'G:1');

        addStakedShareFromMsgValue__dirty();

        setProof(tokenId);

        mint__dirty(msg.sender, tokenId);

        emit Mint(tokenId, uint96(msg.value));
    }

    /// @inheritdoc INuggftV1Token
    function trustedMint(uint160 tokenId, address to) external payable override requiresTrust {
        assembly {
            if or(iszero(lt(tokenId, TRUSTED_MINT_TOKENS)), iszero(tokenId)) {
                mstore8(0x00, Error__B__0x66__TokenNotTrustMintable)
                revert(0x00, 0x01)
            }
        }

        // (tokenId < TRUSTED_MINT_TOKENS && tokenId != 0, 'G:1');

        addStakedShareFromMsgValue__dirty();

        setProof(tokenId);

        mint__dirty(to, tokenId);

        emit Mint(tokenId, uint96(msg.value));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                BURN/MIGRATE
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Stake
    function burn(uint160 tokenId) external {
        uint96 ethOwed = subStakedShare(tokenId);

        TransferLib.give(msg.sender, ethOwed);

        emit Burn(tokenId, msg.sender, ethOwed);
    }

    /// @inheritdoc INuggftV1Stake
    function migrate(uint160 tokenId) external {
        require(migrator != address(0), hex'74');

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
        require(isOwner(msg.sender, tokenId), hex'73');

        uint256 cache = stake;

        // hanles all logic not related to staking the nugg
        delete agency[tokenId];

        // delete swaps[tokenId];
        // delete loans[tokenId];
        delete proofs[tokenId];
        delete resolvers[tokenId];

        emit Transfer(msg.sender, address(0), tokenId);

        ethOwed = calculateEthPerShare(cache);

        /// TODO - test migration
        assert(cache.shares() >= 1);
        assert(cache.staked() >= ethOwed);

        cache = cache.subShares(1);
        cache = cache.subStaked(ethOwed);

        stake = cache;

        emit Stake(bytes32(cache));
    }
}
