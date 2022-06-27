// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.15;

interface INuggftV1ItemSwap {
    event OfferItem(uint24 indexed sellingTokenId, uint16 indexed itemId, bytes32 agency, bytes32 stake);

    event ClaimItem(uint24 indexed sellingTokenId, uint16 indexed itemId, uint24 indexed buyerTokenId, bytes32 proof);

    event SellItem(uint24 indexed sellingTokenId, uint16 indexed itemId, bytes32 agency, bytes32 proof);

    function offer(
        uint24 buyerTokenId,
        uint24 sellerTokenId,
        uint16 itemId
    ) external payable;

    function sell(
        uint24 sellerTokenId,
        uint16 itemid,
        uint96 floor
    ) external;
}
//  SellItem(uint24,uint16,bytes32,bytes32);
//     OfferItem(uint24,uint16, bytes32,bytes32);
//  ClaimItem(uint24,uint16,uint24,bytes32);
