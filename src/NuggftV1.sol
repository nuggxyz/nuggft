// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.12;

import {IERC721, IERC165, IERC721Metadata} from './interfaces/IERC721.sol';
import {INuggftV1Migrator} from './interfaces/nuggftv1/INuggftV1Migrator.sol';
import {IDotnuggV1Safe} from './interfaces/dotnugg/IDotnuggV1Safe.sol';
import {INuggftV1Stake} from './interfaces/nuggftv1/INuggftV1Stake.sol';
import {INuggftV1Proof} from './interfaces/nuggftv1/INuggftV1Proof.sol';
import {INuggftV1} from './interfaces/nuggftv1/INuggftV1.sol';

import {NuggftV1Loan} from './core/NuggftV1Loan.sol';
import {NuggftV1Proof} from './core/NuggftV1Proof.sol';

import {data as nuggs} from './_data/nuggs.data.sol';

/// @title NuggftV1
/// @author nugg.xyz - danny7even & dub6ix
contract NuggftV1 is IERC721, IERC721Metadata, NuggftV1Loan {
    constructor(address dotnugg) NuggftV1Proof(dotnugg) {}

    /// @inheritdoc INuggftV1Proof
    function mint(uint160 tokenId) public payable override {
        // prettier-ignore
        if (!(tokenId <= UNTRUSTED_MINT_TOKENS + TRUSTED_MINT_TOKENS &&
              tokenId >= TRUSTED_MINT_TOKENS)) _panic(Error__0x65__TokenNotMintable);

        mint(msg.sender, tokenId);
    }

    /// @inheritdoc INuggftV1Proof
    function trustedMint(uint160 tokenId, address to) external payable override requiresTrust {
        if (!(tokenId < TRUSTED_MINT_TOKENS && tokenId != 0)) _panic(Error__0x66__TokenNotTrustMintable);

        mint(to, tokenId);
    }

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

    function mint(address to, uint160 tokenId) internal {
        uint256 randomEnough;

        addStakedShareFromMsgValue();

        // prettier-ignore
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)

            // ============================================================
            // agency__sptr is the storage value that solidity would compute
            // + if you used "agency[tokenId]"
            let agency__sptr := keccak256( // =============================
                0x00, /* [ tokenId                               ]    0x20
                0x20     [ agency.slot                           ] */ 0x40
            ) // ==========================================================

            if iszero(iszero(sload(agency__sptr))) {
                mstore(0x00, Revert__Sig)
                mstore8(31, Error__0x80__TokenDoesExist)
                revert(27, 0x5)
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

            // prettier-ignore
            let agency__cache := or( // ===================================
                // set agency to reflect the new agent
                /* flag  */ shl(254, 0x01), // = OWN(0x01)
                /* epoch */                 // = 0
                /* eth   */                 // = 0
                /* addr  */ to              // = new agent
            ) // ==========================================================

            sstore(agency__sptr, agency__cache)

            log4(0x00, 0x00, Event__Transfer, 0, to, tokenId)

            mstore(0x00, tokenId)
            mstore(0x20, callvalue())

            // prettier-ignore
            log1( // =======================================================
                /* param #1 */ 0x00, /* [ tokenId   ]    0x20
                /* param #2    0x20     [ msg.value ]    0x40,
                   param #2    0x40     [ proof     ] */ 0x60,
                /* topic #1 */ Event__Mint
            ) // ===========================================================
        }

        uint256 proof = initFromSeed(randomEnough);

        proofs[tokenId] = proof;

        emit Mint(tokenId, uint96(msg.value), bytes32(proof));
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

        ethOwed = calculateEthPerShare(cache);

        cache -= 1 << 192;
        cache -= uint256(ethOwed) << 96;

        stake = cache;

        emit Stake(bytes32(cache));
        emit Transfer(msg.sender, address(0), tokenId);
    }

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
                     '{"name":"',         name(),
                    '","description":"',  symbol(),
                    '","image":"',        imageURI(tokenId),
                    '","properites":',    dotnuggV1.props(proofOf(uint160(tokenId)),
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

    /// @inheritdoc INuggftV1Proof
    function itemURI(uint16 itemId) public view override returns (string memory res) {
        res = dotnuggV1.exec(uint8(itemId >> 8), uint8(itemId), true);
    }

    /// @inheritdoc INuggftV1Proof
    function featureLength(uint8 feature) public view override returns (uint8 res) {
        res = dotnuggV1.lengthOf(feature);
    }

    function imageURICheat(uint256 startblock, uint24 _epoch) public view returns (string memory res) {
        return dotnuggV1.exec(initFromSeed(cheat(startblock, _epoch)), true);
    }

    /// @inheritdoc IERC721
    function ownerOf(uint256 tokenId) external view override returns (address res) {
        uint256 cache = agency[tokenId];

        if (cache == 0) _panic(Error__0x78__TokenDoesNotExist);

        if (cache >> 254 == 0x03 && (cache << 2) >> 232 != 0) {
            return address(this);
        }
        return address(uint160(cache));
    }

    function exists(uint160 tokenId) internal view returns (bool) {
        return agency[tokenId] != 0;
    }

    function isOwner(address sender, uint160 tokenId) internal view returns (bool res) {
        uint256 cache = agency[tokenId];
        return address(uint160(cache)) == sender && uint8(cache >> 254) == 0x01;
    }

    function isAgent(address sender, uint160 tokenId) internal view returns (bool res) {
        uint256 cache = agency[tokenId];

        if (uint160(cache) == uint160(sender)) {
            if (
                uint8(cache >> 254) == 0x01 || //
                uint8(cache >> 254) == 0x02 ||
                (uint8(cache >> 254) == 0x03 && ((cache >> 230) & 0xffffff) == 0)
            ) return true;
        }
    }

    /// @inheritdoc IERC721
    function approve(address, uint256) external payable override {
        _panic(Error__0x69__Wut);
    }

    /// @inheritdoc IERC721
    function setApprovalForAll(address, bool) external pure override {
        _panic(Error__0x69__Wut);
    }

    /// @inheritdoc IERC721
    function getApproved(uint256) external pure override returns (address) {
        return address(0);
    }

    /// @inheritdoc IERC721
    function isApprovedForAll(address, address) external pure override returns (bool) {
        return false;
    }

    /// @inheritdoc IERC721
    function balanceOf(address) external pure override returns (uint256) {
        return 0;
    }

    //prettier-ignore
    /// @inheritdoc IERC721
    function transferFrom(address, address, uint256) external payable override {
        _panic(Error__0x69__Wut);
    }

    //prettier-ignore
    /// @inheritdoc IERC721
    function safeTransferFrom(address, address, uint256) external payable override {
        _panic(Error__0x69__Wut);
    }

    //prettier-ignore
    /// @inheritdoc IERC721
    function safeTransferFrom(address, address, uint256, bytes memory) external payable override {
        _panic(Error__0x69__Wut);
    }
}
