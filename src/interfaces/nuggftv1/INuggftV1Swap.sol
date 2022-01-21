// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface INuggftV1Swap {
    event Offer(uint160 indexed tokenId, bytes32 agency);
    event OfferItem(uint176 indexed sellingItemId, bytes32 agency);
    event Claim(uint160 indexed tokenId, address user);
    event ClaimItem(uint176 indexed sellingItemId, uint160 nugg);
    event Sell(uint160 indexed tokenId, bytes32 agency);
    event SellItem(uint176 indexed sellingItemId, bytes32 agency);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function offer(uint160 tokenId) external payable;

    function offerItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) external payable;

    function claimItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemid
    ) external;

    function claim(uint160[] calldata tokenIds) external;

    function multiclaimItem(
        uint160[] calldata buyerTokenIds,
        uint160[] calldata sellerTokenIds,
        uint16[] calldata itemIds
    ) external;

    function sell(uint160 tokenId, uint96 floor) external;

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
    /// @param tokenId -> the token to be offerd to
    /// @param sender -> the address of the user who will be delegating
    /// @return canOffer -> instead of reverting this function will return false
    /// @return nextOfferAmount -> the minimum value that must be sent with a offer call
    /// @return senderCurrentOffer ->
    function valueForOffer(address sender, uint160 tokenId)
        external
        view
        returns (
            bool canOffer,
            uint96 nextOfferAmount,
            uint96 senderCurrentOffer
        );
}
