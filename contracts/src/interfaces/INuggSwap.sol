pragma solidity 0.8.4;

import './IxNUGG.sol';

interface INuggSwap {
    event Mint(address token, uint256 tokenid, address account, uint256 amount);

    event Commit(address token, uint256 tokenid, uint256 index, address account, uint256 amount);

    event Offer(address token, uint256 tokenid, uint256 index, address account, uint256 amount);

    event Claim(address token, uint256 tokenid, uint256 index, address account);

    event Swap(address token, uint256 tokenid, address account, uint256 amount);

    function xnugg() external view returns (IxNUGG);

    function delegate(address token, uint256 tokenid) external payable;

    function mint(address token, uint256 tokenid) external payable;

    function commit(address token, uint256 tokenid) external payable;

    function offer(address token, uint256 tokenid) external payable;

    function claim(
        address token,
        uint256 tokenid,
        uint256 index
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
    ) external view returns (uint256 amount);

    function getOfferLeader(
        address token,
        uint256 tokenid,
        uint256 index
    ) external view returns (address leader, uint256 amount);

    function getActiveSwap(address token, uint256 tokenid)
        external
        view
        returns (
            address leader,
            uint256 amount,
            uint256 epoch,
            bool isOwner
        );
}
