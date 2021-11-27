pragma solidity 0.8.4;

import './IxNUGG.sol';

interface INuggSwap {
    event Mint(address token, uint256 epoch, address account, uint256 eth);

    event Commit(address token, uint256 tokenid, uint256 index, address account, uint256 eth);

    event Offer(address token, uint256 tokenid, uint256 index, address account, uint256 eth);

    event Claim(address token, uint256 tokenid, uint256 index, address account);

    event Swap(address token, uint256 tokenid, address account, uint256 eth);

    function swapItem(
        address token,
        uint256 tokenid,
        uint256 floor,
        uint256 itemid
    ) external;

    function xnugg() external view returns (address payable);

    function genesis() external view returns (uint256 res);

    function epoch() external view returns (uint256 res);

    function delegate(address token, uint256 tokenid) external payable;

    function delegateItem(
        address token,
        uint256 tokenid,
        uint256 itemid,
        uint256 senderTokenId
    ) external payable;

    function mint(address token, uint256 tokenid) external payable;

    function commit(address token, uint256 tokenid) external payable;

    function commitItem(
        address token,
        uint256 tokenid,
        uint256 itemid,
        uint256 senderTokenId
    ) external payable;

    function offer(address token, uint256 tokenid) external payable;

    function offerItem(
        address token,
        uint256 tokenid,
        uint256 itemid,
        uint256 senderTokenId
    ) external payable;

    function claim(
        address token,
        uint256 tokenid,
        uint256 index
    ) external;

    function claimItem(
        address token,
        uint256 tokenid,
        uint256 itemid,
        uint256 index,
        uint256 senderTokenId
    ) external;

    function swap(
        address token,
        uint256 tokenid,
        uint256 floor
    ) external;

    function getOfferByAccount(
        address token,
        uint256 tokenid,
        uint256 index,
        address account
    ) external view returns (uint256 eth);

    function getActiveSwap(address token, uint256 tokenid)
        external
        view
        returns (
            address leader,
            uint256 eth,
            uint256 _epoch,
            bool isOwner
        );
}
