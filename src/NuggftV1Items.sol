// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {IERC1155, IERC165, IERC1155Metadata_URI} from "./interfaces/IERC721.sol";

import {DotnuggV1Lib, parseItemIdAsString} from "./libraries/DotnuggV1Lib.sol";
import {NuggftV1} from "./NuggftV1.sol";

contract NuggftV1Items is IERC1155, IERC1155Metadata_URI {
    NuggftV1 immutable nuggftv1;

    constructor() {
        nuggftv1 = NuggftV1(msg.sender);
    }

    // mapping(uint256 => uint256) supply;

    function transferBatch(
        uint256 proof,
        address from,
        address to
    ) public {
        unchecked {
            uint256 tmp = proof;
            uint256 length = 0;
            for (uint256 i = 0; i < 16; i++) {
                uint256 check = tmp & 0xffff;
                tmp >>= 16;
                if (check != 0) {
                    length++;
                }
            }

            uint256[] memory ids = new uint256[](length);
            uint256[] memory values = new uint256[](length);

            uint256 count = 0;
            while (count < length) {
                uint256 check = proof & 0xffff;
                proof >>= 16;
                if (check != 0) {
                    values[count] = 1;
                    ids[count] = check;
                    count += 1;
                    // if (from == address(0)) supply[check / 10] += (1 << check % 10);
                }
            }

            emit TransferBatch(address(0), from, to, ids, values);
        }
    }

    function transferSingle(
        uint256 itemId,
        address from,
        address to
    ) public {
        emit TransferSingle(address(0), from, to, itemId, 1);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == 0xd9b67a26 || //
            interfaceId == 0x0e89341c ||
            interfaceId == type(IERC165).interfaceId;
    }

    function name() public pure returns (string memory) {
        return "Nugg Fungible Items V1";
    }

    function symbol() public pure returns (string memory) {
        return "iNUGGFT";
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory res) {
        // prettier-ignore
        res = string(
            nuggftv1.dotnuggv1().encodeJsonAsBase64(
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

    // function totalSupply(uint256 _id) public view returns (uint256 res) {
    //     res = (supply[_id / 10] >> _id % 10) & 0xffffff;
    // }

    function balanceOf(address _owner, uint256 _id) public view returns (uint256 res) {
        uint256 bal = nuggftv1.balance(_owner);

        while (bal != 0) {
            uint256 proof = nuggftv1.proof(uint24(bal <<= 24));
            while (proof != 0) if ((proof <<= 16) == _id) res++;
        }
    }

    function balanceOfBatch(address[] calldata _owners, uint256[] memory _ids) external view returns (uint256[] memory) {
        for (uint256 i = 0; i < _owners.length; i++) {
            _ids[i] = balanceOf(_owners[i], _ids[i]);
        }

        return _ids;
    }

    function isApprovedForAll(address, address) external pure override returns (bool) {
        return false;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) public {}

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external {}

    function setApprovalForAll(address _operator, bool _approved) external pure {
        revert("whut");
    }
}
