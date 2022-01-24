// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface INuggftV1ItemSwap {
    event OfferItem(uint176 indexed sellingItemId, bytes32 agency);
    event ClaimItem(uint176 indexed sellingItemId, uint160 buyerTokenId);
    event SellItem(uint176 indexed sellingItemId, bytes32 agency);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function offerItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) external payable;

    function claimItem(
        uint160[] calldata buyerTokenIds,
        uint160[] calldata sellerTokenIds,
        uint16[] calldata itemIds
    ) external;

    function sellItem(
        uint160 sellerTokenId,
        uint16 itemid,
        uint96 floor
    ) external;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @notice calculates the minimum eth that must be sent with a offer call
    /// @dev returns 0 if no offer can be made for this oken
    /// @param buyer -> the token to be offerd to
    /// @param seller -> the address of the user who will be delegating
    /// @param itemId -> the address of the user who will be delegating
    /// @return canOffer -> instead of reverting this function will return false
    /// @return nextOfferAmount -> the minimum value that must be sent with a offer call
    /// @return senderCurrentOffer ->
    function checkItemOffer(
        uint160 buyer,
        uint160 seller,
        uint16 itemId
    )
        external
        view
        returns (
            bool canOffer,
            uint96 nextOfferAmount,
            uint96 senderCurrentOffer
        );
}
