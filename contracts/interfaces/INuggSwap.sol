pragma solidity 0.8.4;

import './IxNUGG.sol';

interface INuggSwap {
    event Offer(address nft, uint256 tokenid, uint256 swapnum, address account, uint256 amount);

    event SwapInit(uint256 indexed epoch);

    event Claim(address nft, uint256 tokenid, uint256 swapnum, address indexed account);

    function xnugg() external view returns (IxNUGG);

    function submitSwap(
        address nft,
        uint256 tokenid,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) external;

    function submitOffer(
        address nft,
        uint256 tokenid,
        uint256 swapnum
    ) external payable;

    function submitClaim(
        address nft,
        uint256 tokenid,
        uint256 swapnum
    ) external;
}
