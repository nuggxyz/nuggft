// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface INuggftV1Swap {
    event Offer(uint160 indexed tokenId, bytes32 agency);
    event Claim(uint160 indexed tokenId, address indexed account);
    event Sell(uint160 indexed tokenId, bytes32 agency);

    event Repayment(address indexed account, uint96 amount);

    event OfferItem(uint160 indexed sellingTokenId, bytes2 indexed itemId, bytes32 agency);
    event ClaimItem(uint160 indexed sellingTokenId, bytes2 indexed itemId, uint160 indexed buyerTokenId);
    event SellItem(uint160 indexed sellingTokenId, bytes2 indexed itemId, bytes32 agency);

    event TransferItem(uint256 indexed from, uint256 indexed to, bytes2 indexed id, bytes32 proof);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function offer(uint160 tokenId) external payable;

    function claim(uint160[] calldata tokenIds, address[] calldata accounts) external;

    function sell(uint160 tokenId, uint96 floor) external;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function pull(address user) external view returns (uint96 res);

    /// @notice calculates the minimum eth that must be sent with a offer call
    /// @dev returns 0 if no offer can be made for this oken
    /// @param tokenId -> the token to be offerd to
    /// @param sender -> the address of the user who will be delegating
    /// @return canOffer -> instead of reverting this function will return false
    /// @return nextOfferAmount -> the minimum value that must be sent with a offer call
    /// @return senderCurrentOffer ->
    function check(address sender, uint160 tokenId)
        external
        view
        returns (
            bool canOffer,
            uint96 nextOfferAmount,
            uint96 senderCurrentOffer
        );

    function vfo(address sender, uint160 tokenId) external view returns (uint96 res);
}

//  ├─ [458] RiggedNuggft::staked()
//     │   └─ ← 61951385498220000
//     ├─ [452] RiggedNuggft::proto()
//     │   └─ ←61951385498220000/ 2749575201780000
