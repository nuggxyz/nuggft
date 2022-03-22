// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import {INuggftV1Proof} from "../interfaces/nuggftv1/INuggftV1Proof.sol";
import {IDotnuggV1Safe} from "../interfaces/dotnugg/IDotnuggV1Safe.sol";
import {IERC1155, IERC165} from "../interfaces/IERC721.sol";
import {INuggftV1} from "../interfaces/nuggftv1/INuggftV1.sol";

import {DotnuggV1Lib} from "../libraries/DotnuggV1Lib.sol";

import {NuggftV1Epoch} from "./NuggftV1Epoch.sol";
import {NuggftV1Trust} from "./NuggftV1Trust.sol";

// 0xe5910fca
contract Erc1155Emmitter is IERC1155 {
    INuggftV1 immutable nuggftv1;

    bytes32 constant Event__TransferItem = 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62;

    constructor() {
        nuggftv1 = INuggftV1(msg.sender);
    }

    fallback() external {
        address nuggft = address(nuggftv1);
        assembly {
            if iszero(eq(caller(), nuggft)) {
                revert(0x00, 0x00)
            }

            let work := calldataload(0x00)

            let operator := and(work, 0xffffff)

            mstore(0x00, and(shr(24, work), 0xffff))
            mstore(0x20, 1)

            let from := 0
            let to := 0

            switch shr(40, work)
            case 1 {
                from := nuggft
                to := address()
            }
            case 2 {
                from := address()
                to := nuggft
            }
            case 3 {
                from := nuggft
                to := 0
            }
            default {
                from := address()
                to := nuggft
            }

            log4(0x00, 0x40, Event__TransferItem, operator, from, to)
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == 0xd9b67a26 || //
            interfaceId == 0x0e89341c ||
            interfaceId == type(IERC165).interfaceId;
    }

    function name() public pure returns (string memory) {
        return "Nugg Fungible Token V1 (Items)";
    }

    function symbol() public pure returns (string memory) {
        return "NUGGFT-ITEM";
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory res) {
        // prettier-ignore
        res = string(
            nuggftv1.dotnuggV1().encodeJsonAsBase64(
                abi.encodePacked(
                     '{"name":"',         name(),
                    '","description":"',  nuggftv1.dotnuggV1().parseItemIdAsString(uint16(tokenId),
                            ["base", "eyes", "mouth", "hair", "hat", "background", "scarf", "held"]),
                    '","image":"',        nuggftv1.itemURI(tokenId),
                    '}'
                )
            )
        );
    }
}

abstract contract NuggftV1Proof is INuggftV1Proof, NuggftV1Epoch, NuggftV1Trust {
    mapping(uint160 => uint256) proofs;
    mapping(uint256 => uint256) public hotproof;

    mapping(uint256 => uint256) public agency;

    IDotnuggV1Safe public immutable override dotnuggV1;

    Erc1155Emmitter public immutable emitter;

    constructor(address dotnugg) {
        // address res;

        // assembly {
        //     mstore(0x02, caller())
        //     mstore8(0x00, 0xD6)
        //     mstore8(0x01, 0x94)
        //     mstore8(0x16, 0x01)

        //     res := shr(96, shl(96, keccak256(0x00, 0x17)))
        // }

        // firse index of sender
        dotnuggV1 = IDotnuggV1Safe(dotnugg);
        emitter = new Erc1155Emmitter();
    }

    /// @inheritdoc INuggftV1Proof
    function proofOf(uint160 tokenId) public view override returns (uint256 res) {
        if ((res = proofs[tokenId]) != 0) return res;

        if ((res = hotproof[uint8(tokenId % HOT_PROOF_AMOUNT)]) != HOT_PROOF_EMPTY && agency[tokenId] != 0) {
            return res;
        } else {
            res = 0;
        }

        uint24 epoch = epoch();

        if (tokenId == epoch + 1) epoch++;

        uint256 seed = calculateSeed(epoch);

        if (seed != 0) return initFromSeed(seed);

        _panic(Error__0xAD__InvalidZeroProof);
    }

    function floop(uint160 tokenId) public view returns (bytes2[] memory arr) {
        arr = new bytes2[](16);
        uint256 proof = proofOf(tokenId);
        uint256 max = 0;
        for (uint256 i = 0; i < 16; i++) {
            uint16 check = uint16(proof) & 0xfff;
            proof >>= 16;
            if (check != 0) {
                arr[i] = bytes2(check);
                max = i + 1;
            }
        }
    }

    /// @notice parses the external itemId into a feautre and position
    /// @dev this follows dotnugg v1 specification
    /// @param itemId -> the external itemId
    /// @return feat -> the feautre of the item
    /// @return pos -> the file storage position of the item
    function parseItemId(uint16 itemId) internal pure returns (uint8 feat, uint8 pos) {
        feat = uint8(itemId >> 8);
        pos = uint8(itemId & 0xff);
    }

    /// @inheritdoc INuggftV1Proof
    function rotate(
        uint160 tokenId,
        uint8[] calldata index0s,
        uint8[] calldata index1s
    ) external override {
        assembly {
            function juke(x, L, R) -> b {
                b := shr(R, shl(L, x))
            }

            function panic(code) {
                mstore(0x00, Revert__Sig)
                mstore8(31, code)
                revert(27, 0x5)
            }

            mstore(0x00, tokenId)
            mstore(0x20, agency.slot)
            let buyerTokenAgency := sload(keccak256(0x00, 0x40))

            // ensure the caller is the agent
            if iszero(eq(juke(buyerTokenAgency, 96, 96), caller())) {
                panic(Error__0xA2__NotItemAgent)
            }

            let flag := shr(254, buyerTokenAgency)

            // ensure the caller is really the agent
            if and(eq(flag, 0x3), iszero(iszero(juke(buyerTokenAgency, 2, 232)))) {
                panic(Error__0xA3__NotItemAuthorizedAgent)
            }

            mstore(0x20, proofs.slot)

            let proof__sptr := keccak256(0x00, 0x40)

            let proof := sload(proof__sptr)

            // extract length of tokenIds array from calldata
            let len := calldataload(sub(index0s.offset, 0x20))

            // ensure arrays the same length
            if iszero(eq(len, calldataload(sub(index1s.offset, 0x20)))) {
                panic(Error__0x76__InvalidArrayLengths)
            }
            mstore(0x00, proof)

            // prettier-ignore
            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                // tokenIds[i]
                let index0 := calldataload(add(index0s.offset, mul(i, 0x20)))

                // accounts[i]
                let index1 := calldataload(add(index1s.offset, mul(i, 0x20)))

                // prettier-ignore
                if or(or(or( // ================================================
                    iszero(index0),           // since we are taking working with external input here, we want
                    iszero(index1)),          // + to make sure the indexs passed are valid (1 <= x <= 16)
                    iszero(gt(16, index0))),
                    iszero(gt(16, index1))
                 ) { panic(Error__0x73__InvalidProofIndex) } // ==============

                proof := mload(0x00)

                let pos0 := mul(sub(0xf, index0), 0x2)
                let pos1 := mul(sub(0xf, index1), 0x2)
                let item0 := and(shr(mul(index0, 16), proof), 0xffff)
                let item1 := and(shr(mul(index1, 16), proof), 0xffff)

                mstore8(pos1, shr(8, item0))
                mstore8(add(pos1, 1), item0)
                mstore8(pos0, shr(8, item1))
                mstore8(add(pos0, 1), item1)
            }

            sstore(proof__sptr, mload(0x00))

            log2(0x00, 0x20, Event__Rotate, tokenId)
        }
    }

    // TODO TO BE TESTED
    function initFromSeed(uint256 seed) internal view returns (uint256 res) {
        uint8 selA = uint8((seed >> 8) & 0xff);
        uint8 selB = uint8((seed >> 16) & 0xff);
        uint8 selC = uint8((seed >> 24) & 0xff);

        selA = selA < 128 ? 3 : 4;
        selB = selB < 30 ? 5 : selB < 55 ? 6 : selB < 75 ? 7 : 0;
        selC = selC < 30 ? 5 : selC < 55 ? 6 : selC < 75 ? 7 : selC < 115 ? 4 : selC < 155 ? 3 : selC < 205 ? 2 : 1;

        res |=
            DotnuggV1Lib.search(address(dotnuggV1), 0, seed) |
            (uint256(0x0100 | DotnuggV1Lib.search(address(dotnuggV1), 1, seed)) << (0x10)) |
            (uint256(0x0200 | DotnuggV1Lib.search(address(dotnuggV1), 2, seed)) << (0x20)) |
            (uint256((uint16(selA) << 8) | DotnuggV1Lib.search(address(dotnuggV1), selA, seed)) << (0x30)) |
            (selB == 0 ? 0 : (uint256((uint16(selB) << 8) | DotnuggV1Lib.search(address(dotnuggV1), selB, seed)) << (0x40))) |
            (uint256((uint16(selC) << 8) | DotnuggV1Lib.search(address(dotnuggV1), selC, seed >> 8)) << (0x80));
    }
}
