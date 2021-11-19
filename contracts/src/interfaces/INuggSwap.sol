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
        uint128 requestedFloor
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

    function getSwap(address nft, uint256 tokenid)
        external
        view
        returns (
            uint256 swapnum,
            address leader,
            uint128 leaderAmount,
            uint16 amount,
            uint16 precision,
            uint48 epoch,
            bool tokenClaimed,
            bool exists,
            bool is1155
        );

    function getSwap(
        address nft,
        uint256 tokenid,
        uint256 _swapnum
    )
        external
        view
        returns (
            uint256 swapnum,
            address leader,
            uint128 leaderAmount,
            uint16 amount,
            uint16 precision,
            uint48 epoch,
            bool tokenClaimed,
            bool exists,
            bool is1155
        );
}
