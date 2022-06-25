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

    /// @notice calculates the minimum eth that must be sent with a offer call
    /// @dev returns 0 if no offer can be made for this oken
    /// @param buyer -> the token to be offerd to
    /// @param seller -> the address of the user who will be delegating
    /// @param itemId -> the address of the user who will be delegating
    /// @return canOffer -> instead of reverting this function will return false
    /// @return nextMinUserOffer -> the minimum value that must be sent with a offer call
    /// @return currentUserOffer ->
    function check(
        uint24 buyer,
        uint24 seller,
        uint16 itemId
    )
        external
        view
        returns (
            bool canOffer,
            uint96 nextMinUserOffer,
            uint96 currentUserOffer,
            uint96 currentLeaderOffer,
            uint96 incrementBps,
            bool mustClaimBuyer,
            bool mustOfferOnSeller
        );

    function vfo(
        uint24 buyer,
        uint24 seller,
        uint16 itemId
    ) external view returns (uint96 res);
}
//  SellItem(uint24,uint16,bytes32,bytes32);
//     OfferItem(uint24,uint16, bytes32,bytes32);
//  ClaimItem(uint24,uint16,uint24,bytes32);
