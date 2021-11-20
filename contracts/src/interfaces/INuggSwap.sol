pragma solidity 0.8.4;

import './IxNUGG.sol';
import './IEpochable.sol';

interface INuggSwap is IEpochable {
    event SubmitOffer(address nft, uint256 tokenid, uint256 swapnum, address account, uint256 amount);

    event SubmitSwap(address nft, uint256 tokenid, uint256 swapnum, address account, uint256 amount, uint48 epoch);

    event SubmitClaim(address nft, uint256 tokenid, uint256 swapnum, address account);

    function xnugg() external view returns (IxNUGG);

    function submitSwap(
        address nft,
        uint256 tokenid,
        uint48 requestedEpoch,
        uint128 requestedFloor,
        bool is1155
    ) external;

    function submitOffer(address nft, uint256 tokenid) external payable;

    function submitClaim(address nft, uint256 tokenid) external;

    function submitOfferTo(
        address nft,
        uint256 tokenid,
        address to
    ) external payable;

    function submitClaimTo(
        address nft,
        uint256 tokenid,
        address to
    ) external;

    struct SwapData {
        uint256 swapnum;
        address leader;
        uint128 amount;
        uint56 epoch;
        uint16 bps;
        bool is1155;
        bool tokenClaimed;
        bool royClaimed;
    }

    function getSwap(
        address nft,
        uint256 tokenid,
        uint256 swapnum
    ) external view returns (SwapData memory);
}
