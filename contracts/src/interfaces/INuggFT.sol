pragma solidity 0.8.4;

interface INuggFT {
    event PreMint(uint256 tokenId, uint256[] items);

    event PopItem(uint256 tokenId, uint256 itemId);

    event PushItem(uint256 tokenId, uint256 itemId);

    event Mint(uint256 epoch, address account, uint256 eth);

    event Commit(uint256 tokenid, address account, uint256 eth);

    event Offer(uint256 tokenid, address account, uint256 eth);

    event Claim(uint256 tokenid, uint256 endingEpoch, address account);

    event Swap(uint256 tokenid, address account, uint256 eth);

    event CommitItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);

    event OfferItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 eth);

    event ClaimItem(uint256 sellingTokenId, uint256 itemId, uint256 buyingTokenId, uint256 endingEpoch);

    event SwapItem(uint256 sellingTokenId, uint256 itemId, uint256 eth);

    event OpenSlot(uint256 tokenId);

    event Genesis();

    function swapItem(
        uint256 tokenid,
        uint256 floor,
        uint256 itemid
    ) external;

    function xnugg() external view returns (address payable);

    function genesis() external view returns (uint256 res);

    function epoch() external view returns (uint256 res);

    function delegate(uint256 tokenid) external payable;

    function delegateItem(
        uint256 sellerTokenId,
        uint256 itemid,
        uint256 buyerTokenId
    ) external payable;

    function mint(uint256 tokenid) external payable;

    function commit(uint256 tokenid) external payable;

    function commitItem(
        uint256 sellerTokenId,
        uint256 itemid,
        uint256 buyerTokenId
    ) external payable;

    function offer(uint256 tokenid) external payable;

    function offerItem(
        uint256 sellerTokenId,
        uint256 itemid,
        uint256 buyerTokenId
    ) external payable;

    function claim(uint256 tokenid, uint256 endingEpoch) external;

    function claimItem(
        uint256 sellerTokenId,
        uint256 itemid,
        uint256 buyerTokenId,
        uint256 endingEpoch
    ) external;

    function swap(uint256 tokenid, uint256 floor) external;

    function getOfferByAccount(
        uint256 tokenid,
        uint256 index,
        address account
    ) external view returns (uint256 eth);

    function getActiveSwap(uint256 tokenid)
        external
        view
        returns (
            address leader,
            uint256 eth,
            uint256 _epoch,
            bool isOwner
        );
}