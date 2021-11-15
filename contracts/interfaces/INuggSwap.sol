pragma solidity 0.8.4;

import './IxNUGG.sol';

interface INuggSwap {
    event SubmitOffer(address nft, uint256 tokenid, uint256 swapnum, address account, uint256 amount);

    event SubmitSwap(address nft, uint256 tokenid, uint256 swapnum, address account, uint256 amount, uint64 epoch);

    event SubmitClaim(address nft, uint256 tokenid, uint256 swapnum, address account);

    function xnugg() external view returns (IxNUGG);

    function submitSwap(
        address nft,
        uint256 tokenid,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) external;

    function submitOffer(address nft, uint256 tokenid) external payable;

    function submitClaim(address nft, uint256 tokenid) external;
}
