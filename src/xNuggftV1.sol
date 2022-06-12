// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import {IERC1155, IERC165, IERC1155Metadata_URI} from "./interfaces/IERC721.sol";

import {IxNuggftV1} from "./interfaces/nuggftv1/IxNuggftV1.sol";
import {DotnuggV1Lib} from "dotnugg-v1-core/DotnuggV1Lib.sol";
import {IDotnuggV1} from "dotnugg-v1-core/IDotnuggV1.sol";

import {NuggftV1} from "./NuggftV1.sol";

/// @author nugg.xyz - danny7even and dub6ix - 2022
contract xNuggftV1 is IERC1155, IERC1155Metadata_URI, IxNuggftV1 {
    using DotnuggV1Lib for IDotnuggV1;

    NuggftV1 immutable nuggftv1;

    constructor() {
        nuggftv1 = NuggftV1(msg.sender);
    }

    /// @inheritdoc IxNuggftV1
    function imageURI(uint256 tokenId) public view override returns (string memory res) {
        (uint8 feature, uint8 position) = DotnuggV1Lib.parseItemId(tokenId);
        res = nuggftv1.dotnuggv1().exec(feature, position, true);
    }

    /// @inheritdoc IxNuggftV1
    function imageSVG(uint256 tokenId) public view override returns (string memory res) {
        (uint8 feature, uint8 position) = DotnuggV1Lib.parseItemId(tokenId);
        res = nuggftv1.dotnuggv1().exec(feature, position, false);
    }

    function transferBatch(
        uint256 proof,
        address from,
        address to
    ) public payable {
        require(msg.sender == address(nuggftv1));

        unchecked {
            uint256 tmp = proof;

            uint256 length = 1;

            while (tmp != 0) if ((tmp >>= 16) & 0xffff != 0) length++;

            uint256[] memory ids = new uint256[](length);
            uint256[] memory values = new uint256[](length);

            ids[0] = proof & 0xffff;
            values[0] = 1;

            while (proof != 0)
                if ((tmp = ((proof >>= 16) & 0xffff)) != 0) {
                    ids[--length] = tmp;
                    values[length] = 1;
                }

            emit TransferBatch(address(0), from, to, ids, values);
        }
    }

    function transferSingle(
        uint256 itemId,
        address from,
        address to
    ) public payable {
        require(msg.sender == address(nuggftv1));
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
        return "xNUGGFT";
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory res) {
        // prettier-ignore
        res = string(
            nuggftv1.dotnuggv1().encodeJson(
                abi.encodePacked(
                     '{"name":"',         name(),
                    '","description":"',  DotnuggV1Lib.itemIdToString(uint16(tokenId),
                            ["base", "eyes", "mouth", "hair", "hat", "background", "scarf", "hold"]),
                    '","image":"',        imageURI(tokenId),
                    '}'
                ), true
            )
        );
    }

    function totalSupply() public view returns (uint256 res) {
        for (uint8 i = 0; i < 8; i++) res += featureSupply(i);
    }

    function featureSupply(uint8 feature) public view override returns (uint256 res) {
        res = nuggftv1.dotnuggv1().lengthOf(feature);
    }

    function rarity(uint256 tokenId) public view returns (uint16 res) {
        (uint8 feature, uint8 position) = DotnuggV1Lib.parseItemId(tokenId);
        res = nuggftv1.dotnuggv1().rarity(feature, position);
    }

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

    function setApprovalForAll(address, bool) external pure {
        revert("whut");
    }
}
