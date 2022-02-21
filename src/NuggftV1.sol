// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import {IERC721, IERC165, IERC721Metadata} from './interfaces/IERC721.sol';

import {NuggftV1Loan} from './core/NuggftV1Loan.sol';
import {NuggftV1Dotnugg} from './core/NuggftV1Dotnugg.sol';

import {INuggftV1Migrator} from './interfaces/nuggftv1/INuggftV1Migrator.sol';

import {IDotnuggV1} from './interfaces/dotnugg/IDotnuggV1.sol';
import {IDotnuggV1Safe} from './interfaces/dotnugg/IDotnuggV1Safe.sol';

import {INuggftV1Token} from './interfaces/nuggftv1/INuggftV1Token.sol';
import {INuggftV1Stake} from './interfaces/nuggftv1/INuggftV1Stake.sol';
import {INuggftV1Proof} from './interfaces/nuggftv1/INuggftV1Proof.sol';

import {INuggftV1} from './interfaces/nuggftv1/INuggftV1.sol';

import {data as nuggs} from './_data/nuggs.data.sol';

/// @title NuggftV1
/// @author nugg.xyz - danny7even & dub6ix
contract NuggftV1 is IERC721Metadata, NuggftV1Loan {
    constructor(address dotnugg) NuggftV1Dotnugg(dotnugg) {}

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId || //
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    /// @inheritdoc IERC721Metadata
    function name() public pure override returns (string memory) {
        return 'Nugg Fungible Token V1';
    }

    /// @inheritdoc IERC721Metadata
    function symbol() public pure override returns (string memory) {
        return 'NUGGFT';
    }

    /// @inheritdoc IERC721Metadata
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory res) {
        // prettier-ignore
        res = string(
            dotnuggV1.encodeJsonAsBase64(
                abi.encodePacked(
                     '{"name":"',        name(),
                    '","description":"', symbol(),
                    '","image":"',       imageURI(tokenId),
                    '","properites":',   dotnuggV1.props(
                            proofOf(uint160(tokenId)),
                            ['base', 'eyes', 'mouth', 'hair', 'hat', 'background', 'scarf', 'held']
                        ),
                    '}'
                )
            )
        );
    }

    /// @inheritdoc INuggftV1Proof
    function imageURI(uint256 tokenId) public view override returns (string memory res) {
        res = dotnuggV1.exec(proofOf(uint160(tokenId)), true);
    }

    function imageURICheat(uint256 startblock, uint24 _epoch) public view returns (string memory res) {
        return dotnuggV1.exec(initFromSeed(cheat(startblock, _epoch)), true);
    }

    /// @inheritdoc INuggftV1Token
    function mint(uint160 tokenId) public payable override {
        // prettier-ignore
        if (!(tokenId <= UNTRUSTED_MINT_TOKENS + TRUSTED_MINT_TOKENS &&
              tokenId >= TRUSTED_MINT_TOKENS)) _panic(Error__0x65__TokenNotMintable);

        mint(msg.sender, tokenId);
    }

    /// @inheritdoc INuggftV1Token
    function trustedMint(uint160 tokenId, address to) external payable override requiresTrust {
        if (!(tokenId < TRUSTED_MINT_TOKENS && tokenId != 0)) _panic(Error__0x66__TokenNotTrustMintable);

        mint(to, tokenId);
    }

    function mint(address to, uint160 tokenId) internal {
        uint256 randomEnough;

        addStakedShareFromMsgValue();

        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)

            let agency__sptr := keccak256(0x00, 0x40)

            if iszero(iszero(sload(agency__sptr))) {
                mstore(0x00, Revert__Sig)
                mstore(0x04, Error__0x80__TokenDoesExist)
                revert(0x00, 0x05)
            }

            // prettier-ignore
            mstore( // ====================================================
                /* postion */ 0x20,
                // we div and mul by 16 here to make the value returned stay constant for 16 blocks
                // this makes gas estimation more acurate as "initFromSeed" will change in gas useage
                // + depending on the value returned here
                /* value   */ blockhash(shl(shr(sub(number(), 2), 4), 4))
            ) // ==========================================================

            // prettier-ignore
            randomEnough := keccak256( // =================================
                0x00, /* [ tokenId                               ]    0x20
                0x20     [ blockhash(((blocknum - 2) / 16) * 16) ] */ 0x40
            ) // ==========================================================

            // update agency to reflect the new leader

            // prettier-ignore
            let agency__cache := or( // ===================================
            /* flag  */ shl(254, 0x01), // = OWN(0x01)
            /* epoch */                 // = 0
            /* eth   */                 // = 0
            /* addr  */ to              // = new agent
            ) // ==========================================================

            sstore(agency__sptr, agency__cache)

            log4(0x00, 0x00, Event__Transfer, 0, to, tokenId)

            mstore(0x00, tokenId)
            mstore(0x20, callvalue())
            log1(0x00, 0x40, Event__Mint)
        }

        uint256 proof = initFromSeed(randomEnough);

        proofs[tokenId] = proof;

        emit Rotate(tokenId, bytes32(proof));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                BURN/MIGRATE
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Stake
    function burn(uint160 tokenId) external {
        uint96 ethOwed = subStakedShare(tokenId);

        payable(msg.sender).transfer(ethOwed);

        emit Burn(tokenId, msg.sender, ethOwed);
    }

    /// @inheritdoc INuggftV1Stake
    function migrate(uint160 tokenId) external {
        if (migrator == address(0)) _panic(Error__0x81__MigratorNotSet);

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
        if (!isOwner(msg.sender, tokenId)) _panic(Error__0x77__NotOwner);

        uint256 cache = stake;

        // handles all logic not related to staking the nugg
        delete agency[tokenId];
        delete proofs[tokenId];

        emit Transfer(msg.sender, address(0), tokenId);

        ethOwed = calculateEthPerShare(cache);

        /// TODO - test migration
        // assert(cache.shares() >= 1);
        // assert(cache.staked() >= ethOwed);

        cache -= 1 << 160;
        cache -= ethOwed << 96;

        stake = cache;

        emit Stake(bytes32(cache));
    }
}
