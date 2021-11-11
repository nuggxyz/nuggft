// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/IAuctionable.sol';

interface IAuctionableImplementer {
    // function onBidPlaced(IAuctionable.Auction memory auction) external payable;

    function onMinterClaim(address minter, uint256 tokenId) external;

    function onBuyerClaim(address buyer, uint256 tokenId) external;

    // function auctionIsActive(IAuctionable.Auction memory auction) external view returns (bool);

    // function auctionIsOver(IAuctionable.Auction memory auction) external view returns (bool);

    // function calculateAuctionData(IAuctionable.Auction memory auction) external view returns (bytes memory res);

    // function calculateCurrentAuctionId() external view returns (uint256 res);

    // function auctionable() external view returns (address);
}
