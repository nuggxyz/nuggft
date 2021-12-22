// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface ISwapExternal {
    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                EVENTS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    event DelegateMint(uint256 epoch, address account, uint96 eth);
    event DelegateCommit(uint160 tokenId, address account, uint96 eth);
    event DelegateOffer(uint160 tokenId, address account, uint96 eth);
    event SwapClaim(uint160 tokenId, address account, uint32 epoch);
    event SwapStart(uint160 tokenId, address account, uint96 eth);

    event DelegateCommitItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId, uint96 eth);
    event DelegateOfferItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId, uint96 eth);
    event SwapClaimItem(uint160 sellingTokenId, uint16 itemId, uint160 buyingTokenId, uint32 epoch);
    event SwapItemStart(uint160 sellingTokenId, uint16 itemId, uint96 eth);

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            STATE CHANGING
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function delegate(uint160 tokenId) external payable;

    function delegateItem(
        uint160 sellerTokenId,
        uint16 itemid,
        uint160 buyerTokenId
    ) external payable;

    function claim(uint160 tokenId) external;

    function claimItem(
        uint160 sellerTokenId,
        uint16 itemid,
        uint160 buyerTokenId
    ) external;

    function swap(uint160 tokenId, uint96 floor) external;

    function swapItem(
        uint160 tokenId,
        uint16 itemid,
        uint96 floor
    ) external;

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            VIEW FUNCTIONS
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function verifedDelegateMin(uint160 tokenId) external view returns (uint96 amount);
}
