// // SPDX-License-Identifier: MIT

// import '../auction/base/Auctionable.sol';
// import '../base/Epochable.sol';

// pragma solidity 0.8.4;

// contract Auctionable_Test is Auctionable, Epochable {
//     uint8 constant _PERCENT = 15;

//     mapping(uint256 => bool) _winnerHasClaimed;
//     mapping(uint256 => uint256) _highestBid;

//     constructor(uint256 floor_, uint8 _newIncrease) Auctionable() Epochable(255) {}

//     // fallback() external payable {}

//     // receive() external payable {}

//     function _auctionIsActive(Auction memory auction) internal view override returns (bool) {
//         return epochStatus(auction.auctionId) == EpochMath.Status.ACTIVE;
//     }

//     function _auctionIsOver(Auction memory auction) internal view override returns (bool) {
//         return epochStatus(auction.auctionId) == EpochMath.Status.OVER;
//     }

//     // function test__placeBid(
//     //     address user,
//     //     uint256 amount,
//     //     uint256 epoch
//     // ) external payable {
//     //     super._placeBid(user, amount, epoch);
//     // }

//     function test__claim(uint256 epoch, address user) external {
//         super._claim(epoch, user);
//     }

//     function test__biddableChecks(Auction memory auction) external payable {
//         super._biddableChecks(auction);
//     }

//     function test__claimableChecks(Auction memory auction, Bid memory bid) external view {
//         super._claimableChecks(auction, bid);
//     }

//     // function test__floor() external view returns (uint256) {
//     //     return _DEFAULT_FLOOR;
//     // }

//     // function test__newIncrease() external view returns (uint8) {
//     //     return _DEFAULT_MIN_BID_PERCENT;
//     // }

//     function rig__auctions(uint256 epoch) external view returns (Auction memory) {
//         return _auctions[epoch];
//     }

//     function rig__bids(uint256 epoch, address account) external view returns (Bid memory) {
//         return _bids[bidhash(epoch, account)];
//     }

//     // function test__checkBidAccount(Auction memory auction) external {
//     //     super._checkBidAccount(auction);
//     // }

//     // function test__checkBidAmount(Auction memory auction) external view {
//     //     super._checkBidAmount(auction);
//     // }

//     function test__onWinnerClaim(Bid memory bid) external {
//         _onWinnerClaim(bid);
//     }

//     function test__onBidPlaced(Auction memory auction) external {
//         _onBidPlaced(auction);
//     }

//     function rig__setUserAuctionAsClaimed(uint256 epoch, address account) external {
//         _bids[bidhash(epoch, account)].claimed = true;
//     }

//     function rig__setAuctionHighestBid(
//         uint256 epoch,
//         address account,
//         uint256 amount
//     ) external {
//         _auctions[epoch].top.amount = amount;
//         _auctions[epoch].top.account = account;
//     }

//     function rig__setUserAuctionAmount(
//         uint256 epoch,
//         address account,
//         uint256 amount
//     ) external {
//         _bids[bidhash(epoch, account)].amount = amount;
//     }

//     //
//     function _onNormalClaim(Bid memory bid) internal override {
//         super._onNormalClaim(bid);
//         _winnerHasClaimed[bid.auctionId] = true;
//     }

//     function _onWinnerClaim(Bid memory bid) internal override {
//         super._onWinnerClaim(bid);
//         _winnerHasClaimed[bid.auctionId] = true;
//     }

//     function _onBidPlaced(Auction memory auction) internal override {
//         super._onBidPlaced(auction);
//         _highestBid[auction.auctionId] += auction.top.amount - auction.last.amount;
//     }

//     function rig__getWinnerHasClaimed(uint256 epoch) external view returns (bool) {
//         return _winnerHasClaimed[epoch];
//     }

//     function rig__getHighestBid(uint256 epoch) external view returns (uint256) {
//         return _highestBid[epoch];
//     }
// }
