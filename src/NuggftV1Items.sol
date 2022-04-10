// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import {IERC1155, IERC165} from "./interfaces/IERC721.sol";

import {DotnuggV1Lib, parseItemIdAsString} from "./libraries/DotnuggV1Lib.sol";
import {INuggftV1} from "./interfaces/nuggftv1/INuggftV1.sol";

// 0xe5910fca

contract NuggftV1Items is IERC1155 {
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
                    '","description":"',  parseItemIdAsString(uint16(tokenId),
                            ["base", "eyes", "mouth", "hair", "hat", "background", "scarf", "held"]),
                    '","image":"',        nuggftv1.itemURI(tokenId),
                    '}'
                )
            )
        );
    }
}
