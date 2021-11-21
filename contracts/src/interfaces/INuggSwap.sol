pragma solidity 0.8.4;

import './IxNUGG.sol';
import './IEpochable.sol';

interface INuggSwap is IEpochable {
    event SubmitOffer(address token, uint256 tokenid, uint256 swapnum, address account, uint256 amount);

    event SubmitSwap(address token, uint256 tokenid, uint256 swapnum, address account, uint256 amount, uint256 epoch);

    event SubmitClaim(address token, uint256 tokenid, uint256 swapnum, address account);

    function xnugg() external view returns (IxNUGG);

    function submitClaimSimple(address token, uint256 epoch) external;

    function submitSwap(
        address token,
        uint256 tokenid,
        uint256 swapnum,
        uint48 requestedEpoch,
        uint128 requestedFloor,
        bool is1155
    ) external;

    function submitOffer(
        address token,
        uint256 tokenid,
        uint256 swapnum
    ) external payable;

    function submitOfferSimple(address token) external payable;

    function submitClaim(
        address token,
        uint256 tokenid,
        uint256 swapnum
    ) external;

    struct SwapData {
        uint256 swapnum;
        address leader;
        uint256 amount;
        uint256 epoch;
        uint256 bps;
        bool is1155;
        bool tokenClaimed;
        bool royClaimed;
    }

    function getSwap(
        address token,
        uint256 tokenid,
        uint256 swapnum
    ) external view returns (SwapData memory);
}
