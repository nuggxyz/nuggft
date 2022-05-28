// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import {IERC721, IERC165, IERC721Metadata} from "./interfaces/IERC721.sol";
import {INuggftV1Migrator} from "./interfaces/nuggftv1/INuggftV1Migrator.sol";
import {IDotnuggV1Safe} from "./interfaces/dotnugg/IDotnuggV1Safe.sol";
import {INuggftV1Stake} from "./interfaces/nuggftv1/INuggftV1Stake.sol";
import {INuggftV1Proof} from "./interfaces/nuggftv1/INuggftV1Proof.sol";

import {INuggftV1} from "./interfaces/nuggftv1/INuggftV1.sol";

import {NuggftV1Loan} from "./core/NuggftV1Loan.sol";
import {NuggftV1Proof} from "./core/NuggftV1Proof.sol";
import {NuggftV1Globals} from "./core/NuggftV1Globals.sol";

import {DotnuggV1Lib, decodeProofCore, parseItemId, props} from "./libraries/DotnuggV1Lib.sol";

import {data as nuggs} from "./_data/nuggs.data.sol";

/// @title NuggftV1
/// @author nugg.xyz - danny7even & dub6ix
contract NuggftV1 is IERC721, IERC721Metadata, NuggftV1Loan {
    constructor() payable {}

    function premint(uint24 tokenId) public requiresTrust {
        _repanic(agency[tokenId] == 0, Error__0x65__TokenNotMintable);

        (uint24 first, uint24 last) = premintTokens();

        _repanic(tokenId >= first && tokenId <= last, Error__0x65__TokenNotMintable);

        uint256 _agency = (0x01 << 254) + uint160(msg.sender);

        uint256 _proof = initFromSeed(calculateEarlySeed(tokenId));

        proof[tokenId] = _proof;
        agency[tokenId] = _agency;

        emit PreMint(tokenId, STARTING_PRICE, bytes32(_proof), bytes32(_agency));

        xnuggftv1.transferBatch(_proof, address(0), msg.sender);
    }

    /// @inheritdoc INuggftV1Proof
    function mint(uint24 tokenId) public payable override {
        (uint24 first, uint24 last) = mintTokens();

        _repanic(tokenId >= first && tokenId <= last, Error__0x65__TokenNotMintable);

        mint(msg.sender, tokenId, msg.value);
    }

    /// @inheritdoc INuggftV1Proof
    function trustedMint(uint24 tokenId, address to) external payable override requiresTrust {
        (uint24 first, uint24 last) = trustedMintTokens();

        _repanic(tokenId >= first && tokenId <= last, Error__0x66__TokenNotTrustMintable);

        mint(to, tokenId, msg.value);
    }

    /// @inheritdoc INuggftV1Stake
    function burn(uint24 tokenId) external {
        uint96 ethOwed = subStakedShare(tokenId);

        payable(msg.sender).transfer(ethOwed);

        emit Burn(tokenId, msg.sender, ethOwed);
    }

    /// @inheritdoc INuggftV1Stake
    function migrate(uint24 tokenId) external {
        if (migrator == address(0)) _panic(Error__0x81__MigratorNotSet);

        // stores the proof before deleting the nugg
        uint256 proof = proofOf(tokenId);

        uint96 ethOwed = subStakedShare(tokenId);

        INuggftV1Migrator(migrator).nuggftMigrateFromV1{value: ethOwed}(tokenId, proof, msg.sender);

        emit MigrateV1Sent(migrator, tokenId, bytes32(proof), msg.sender, ethOwed);
    }

    function mint(
        address to,
        uint24 tokenId,
        uint256 value
    ) internal {
        uint256 randomEnough;

        uint256 agency__cache;

        uint256 ptr;

        // prettier-ignore
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)

            ptr := mload(0x40)

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

            // we div and mul by 16 here to make the value returned stay constant for 16 blocks
            // this makes gas estimation more acurate as "initFromSeed" will change in gas useage
            // + depending on the value returned here
            mstore(
                /* postion */ 0x20,
                /* value   */ blockhash(shl(shr(sub(number(), 2), 4), 4))
                // /* value   */ blockhash(sub(number(), 69))
            )

            // mstore(0x40, 69)

            randomEnough := keccak256( // ==================================
                0x00, /* [ tokenId                               ]    0x20
                0x20     [ blockhash(sub(number(), 69))          ]    0x40
                0x40     [ block.difficulty()                    ] */ 0x40
            ) // ===========================================================

            agency__cache := or( // ===================================
                // set agency to reflect the new agent
                /* flag  */ shl(254, 0x01), // = OWN(0x01)
                /* epoch */                 // = 0
                /* eth   */                 // = 0
                /* addr  */ to              // = new agent
            ) // ==========================================================

            sstore(agency__sptr, agency__cache)
        }

        uint256 _proof = initFromSeed(randomEnough);

        proof[tokenId] = _proof;

        addStakedShare(value);

        address itemHolder = address(xnuggftv1);

        // prettier-ignore
        assembly {

            mstore(0x00, value)
            mstore(0x20, _proof)
            mstore(0x60, agency__cache)

            log4(0x00, 0x00, Event__Transfer, 0, to, tokenId)

            log2( // ----------------------------------------------------------
                /* param #1: value   */ 0x00, /* [ msg.value       ]     0x20,
                   param #2: proof      0x20,    [ proof[tokenId]  ]     0x40,
                   param #2: stake      0x40,    [ stake           ]     0x60,
                   param #3: agency     0x60,    [ agency[tokenId] ]  */ 0x80,
                /* topic #1: sig     */            Event__Mint,
                /* topic #2: tokenId */            tokenId
            ) // -------------------------------------------------------------

            mstore(0x00, Function__transferBatch)
            mstore(0x40, 0x00)
            mstore(0x60, caller())

            // TODO make sure this is the right way to do this
            if iszero(call(gas(), itemHolder, 0x00, 0x1C, 0x64, 0x00, 0x00)) {
                mstore(0x00, Revert__Sig)
                mstore8(31, Error__0xAE__FailedCallToItemsHolder)
                revert(27, 0x5)
            }

            mstore(0x40, ptr)
        }
    }

    /// @notice removes a staked share from the contract,
    /// @dev this is the only way to remove a share
    /// @dev caculcates but does not handle dealing the eth - which is handled by the two helpers above
    /// @dev ensures the user is the owner of the nugg
    /// @param tokenId the id of the nugg being unstaked
    /// @return ethOwed -> the amount of eth owed to the unstaking user - equivilent to "ethPerShare"
    function subStakedShare(uint24 tokenId) internal returns (uint96 ethOwed) {
        if (!isOwner(msg.sender, tokenId)) _panic(Error__0x77__NotOwner);

        uint256 cache = stake;

        // handles all logic not related to staking the nugg
        delete agency[tokenId];
        delete proof[tokenId];

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
        return "Nugg Fungible Token V1";
    }

    /// @inheritdoc IERC721Metadata
    function symbol() public pure override returns (string memory) {
        return "NUGGFT";
    }

    /// @inheritdoc IERC721Metadata
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory res) {
        // prettier-ignore
        res = string(
            dotnuggv1.encodeJson(
                abi.encodePacked(
                     '{"name":"',         name(),
                    '","description":"',  symbol(),
                    '","image":"',        imageURI(tokenId),
                    '","properites":',    props(decodeProofCore(proofOf(uint24(tokenId))),
                                ['base', 'eyes', 'mouth', 'hair', 'hat', 'background', 'scarf', 'held']
                            ),
                    '}'
                ),
            true)
        );
    }

    /// @inheritdoc INuggftV1Proof
    function imageURI(uint256 tokenId) public view override returns (string memory res) {
        res = dotnuggv1.exec(decodeProofCore(proofOf(uint24(tokenId))), true);
    }

    /// @inheritdoc INuggftV1Proof
    function imageSVG(uint256 tokenId) public view override returns (string memory res) {
        res = dotnuggv1.exec(decodeProofCore(proofOf(uint24(tokenId))), false);
    }

    /// @inheritdoc INuggftV1Proof
    function image123(
        uint256 tokenId,
        bool base64,
        uint8 chunk,
        bytes calldata prev
    ) public view override returns (bytes memory res) {
        if (chunk == 1) {
            res = abi.encode(dotnuggv1.read(decodeProofCore(proofOf(uint24(tokenId)))));
        } else if (chunk == 2) {
            (uint256[] memory calced, uint256 dat) = dotnuggv1.calc(abi.decode(prev, (uint256[][])));
            res = abi.encode(calced, dat);
        } else if (chunk == 3) {
            (uint256[] memory calced, uint256 dat) = abi.decode(prev, (uint256[], uint256));
            res = bytes(dotnuggv1.svg(calced, dat, base64));
        }
    }

    function imageURICheat(uint256 startblock, uint24 _epoch) public view returns (string memory res) {
        return dotnuggv1.exec(decodeProofCore(initFromSeed(cheat(startblock, _epoch))), true);
    }

    /// @inheritdoc IERC721
    function ownerOf(uint256 tokenId) external view override returns (address res) {
        uint256 cache = agency[uint24(tokenId)];

        if (cache == 0) _panic(Error__0x78__TokenDoesNotExist);

        if (cache >> 254 == 0x03 && (cache << 2) >> 232 != 0) {
            return address(this);
        }
        return address(uint160(cache));
    }

    function exists(uint24 tokenId) internal view returns (bool) {
        return agency[tokenId] != 0;
    }

    function isOwner(address sender, uint24 tokenId) internal view returns (bool res) {
        uint256 cache = agency[tokenId];
        return address(uint160(cache)) == sender && uint8(cache >> 254) == 0x01;
    }

    function isAgent(address sender, uint24 tokenId) internal view returns (bool res) {
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
    function balanceOf(address you) external view override returns (uint256 acc) {
        for (uint24 i = 0; i < MAX_TOKENS; i++) if (uint160(you) == uint160(agency[i])) acc++;
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

// 50
// 100
// 200
// 400
// 800
// 1600
// 3200
// 6400

// 1 month slowly mint them out to 10000
// then free for all

// minted nuggs:

// teir a: (once a day from epoch mint)
// - eyes
// - mouth
// - hat/hair
// -

// tier b: (from epoch mint)
// - eyes
// - mouth
// - hat/hair

// tier c:  (from regular mint)
// - eyes
// - mouth
// - hat/hair
// - maybe back/neck/hold

// uint256 minted = MINT_OFFSET + TRUSTED_MINT_TOKENS;

// function mint2(address friend) public payable {
//     _repanic(balance[msg.sender] == TICKET, 0x00);
//     _repanic(balance[friend] == 0, 0x01);
//     // _repanic(friend != msg.sender, 0x02);

//     uint256 _minted = minted;

//     uint96 value = uint96(msg.value / 3);

//     unchecked {
//         mint(msg.sender, uint24(_minted), value);
//         // mint(msg.sender, _minted + 1, value);
//         // mint(msg.sender, _minted + 2, value);

//         minted = _minted + 1;
//     }

//     balance[friend] = TICKET;

//     balance[msg.sender] = 3 | ((_minted + 0) << 24) | ((_minted + 1) << 48) | ((_minted + 2) << 72);
// }

// function trustedMint2(address friend) public payable requiresTrust {
//     _repanic(balance[friend] == 0, 0x03);
//     balance[friend] = TICKET;
// }

// todo
// define rarity of nuggft - make it calculatable
