// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface INuggftV1Swap {
    event Delegate(uint160 indexed tokenId, address user, uint96 lead);
    event DelegateItem(uint176 indexed sellingItemId, uint160 nugg, uint96 lead);
    event Claim(uint160 indexed tokenId, address user);
    event ClaimItem(uint176 indexed sellingItemId, uint160 nugg);
    event Swap(uint160 indexed tokenId, uint96 floor);
    event SwapItem(uint176 indexed sellingItemId, uint96 floor);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function delegate(uint160 tokenId) external payable;

    function delegateItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) external payable;

    function claim(uint160 tokenId) external;

    function claimItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemid
    ) external;

    function swap(uint160 tokenId, uint96 floor) external;

    function swapItem(
        uint160 sellerTokenId,
        uint16 itemid,
        uint96 floor
    ) external;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    /// @notice calculates the minimum eth that must be sent with a delegate call
    /// @dev returns 0 if no delegate can be made for this oken
    /// @param tokenId -> the token to be delegated to
    /// @param sender -> the address of the user who will be delegating
    /// @return canDelegate -> instead of reverting this function will return false
    /// @return nextOfferAmount -> the minimum value that must be sent with a delegate call
    /// @return senderCurrentOffer ->
    function valueForDelegate(address sender, uint160 tokenId)
        external
        view
        returns (
            bool canDelegate,
            uint96 nextOfferAmount,
            uint96 senderCurrentOffer
        );
}
