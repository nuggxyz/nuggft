// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

interface INuggftV1ItemSwap {
    event OfferItem(uint160 indexed sellingTokenId, uint16 indexed itemId, bytes32 agency, bytes32 stake);

    event ClaimItem(uint160 indexed sellingTokenId, uint16 indexed itemId, uint160 indexed buyerTokenId, bytes32 proof);

    event SellItem(uint160 indexed sellingTokenId, uint16 indexed itemId, bytes32 agency, bytes32 proof);

    // event TransferItem(uint256 indexed from, uint256 indexed to, uint16 indexed id, bytes32 proof);

    function offer(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) external payable;

    function claim(uint160[] calldata sellingTokenItemIds, uint160[] calldata buyerTokenIds) external;

    function sell(
        uint160 sellerTokenId,
        uint16 itemid,
        uint96 floor
    ) external;

    /// @notice calculates the minimum eth that must be sent with a offer call
    /// @dev returns 0 if no offer can be made for this oken
    /// @param buyer -> the token to be offerd to
    /// @param seller -> the address of the user who will be delegating
    /// @param itemId -> the address of the user who will be delegating
    /// @return canOffer -> instead of reverting this function will return false
    /// @return next -> the minimum value that must be sent with a offer call
    /// @return current ->
    function check(
        uint160 buyer,
        uint160 seller,
        uint16 itemId
    )
        external
        view
        returns (
            bool canOffer,
            uint96 next,
            uint96 current
        );

    function vfo(
        uint160 buyer,
        uint160 seller,
        uint16 itemId
    ) external view returns (uint96 res);
}
//  SellItem(uint24,uint16,bytes32,bytes32);
//     OfferItem(uint24,uint16, bytes32,bytes32);
//  ClaimItem(uint24,uint16,uint24,bytes32);
