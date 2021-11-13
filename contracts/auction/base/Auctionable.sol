// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/IAuctionable.sol';
import '../../libraries/QuadMath.sol';
import '../../libraries/Exchange.sol';
import '../../common/Mutexable.sol';
import '../../common/Testable.sol';
import '../../interfaces/IWETH9.sol';

/**
 * @title Auctionable
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice enables children contracts to bidreak themselves into auctions
 */
abstract contract Auctionable is IAuctionable, Mutexable, Testable {
    using Address for address payable;
    using QuadMath for uint256;

    Mutex private local;

    mapping(uint256 => address) internal _topAddr;
    mapping(uint256 => mapping(address => uint256)) internal _bidsAmt;
    mapping(uint256 => mapping(address => bool)) internal _bidsBool;

    constructor() {
        local = initMutex();
    }

    /**
     * @dev #TODO
     */
    function placeBid(uint256 auctionId, uint256 amount) external payable override {
        _placeBid(msg_sender(), amount, auctionId);
    }

    function getBid(uint256 auctionId, address account) public view override returns (Bid memory res) {
        res.amount = _bidsAmt[auctionId][account];
        res.account = account;
        res.claimed = _bidsBool[auctionId][account];
        res.auctionId = auctionId;
    }

    function getAuction(uint256 auctionId) public view override returns (Auction memory res) {
        res.auctionId = auctionId;
        res.top = getBid(auctionId, _topAddr[auctionId]);
        res.init = res.top.amount > 0;
    }

    /**
     * @dev #TODO
     */
    function claim(uint256 auctionId) external override {
        _claim(auctionId, msg_sender());
    }

    /**
     * @dev #TODO
     */
    function _claim(uint256 auctionId, address account) internal lock(global) {
        Auction memory auction;
        auction.auctionId = auctionId;

        Bid memory bid = _optimisticBid(auctionId, account, 0);

        _claimableChecks(auction, bid);

        _bidsBool[auctionId][account] = true;

        if (_topAddr[auctionId] == account) {
            _onWinnerClaim(bid);
        } else {
            _onNormalClaim(bid);
        }
    }

    /**
     * @dev #TODO
     */
    function _placeBid(
        address account,
        uint256 amount,
        uint256 auctionId
    ) internal lock(global) {
        require(amount > 0, 'AUC:MSG0:0');

        Exchange.take_eth(account, amount);

        Bid memory bid = _optimisticBid(auctionId, account, amount);
        Auction memory auction = _optimisticAuction(bid);

        _biddableChecks(auction);

        _onBidPlaced(auction);

        _bidsAmt[auctionId][account] = bid.amount;
        if (_topAddr[auctionId] != account) _topAddr[auctionId] = account;
    }

    function _optimisticAuction(Bid memory bid) internal view returns (Auction memory auction) {
        auction.auctionId = bid.auctionId;
        auction.last.amount = _bidsAmt[bid.auctionId][_topAddr[bid.auctionId]];
        auction.top = bid;
    }

    /**
     * @notice mints erc721 to auction winner
     */
    function _onBidPlaced(Auction memory auction) internal virtual {
        emit BidPlaced(auction.auctionId, auction.top.account, auction.top.amount);
    }

    /**
     * @dev #TODO
     */
    function _onWinnerClaim(Bid memory bid) internal virtual {
        emit WinningClaim(bid.auctionId, bid.account, bid.amount);
    }

    /**
     * @notice mints erc721 to auction winner
     */
    function _onNormalClaim(Bid memory bid) internal virtual {
        Exchange.give_eth(payable(bid.account), bid.amount);
        emit NormalClaim(bid.auctionId, bid.account, bid.amount);
    }

    function _optimisticBid(
        uint256 auctionId,
        address account,
        uint256 amount
    ) internal view returns (Bid memory bid) {
        uint256 amt = _bidsAmt[auctionId][account];
        bid.amount = amt + amount;
        bid.account = account;
        bid.auctionId = auctionId;
    }

    /**
     * @dev #TODO
     */
    function _biddableChecks(Auction memory auction) internal view {
        require(_auctionIsActive(auction), 'AUC:BC:0');
        require(auction.last.amount < auction.top.amount, 'AUC:RVA:0');
        require(auction.top.account != 0x0000000000000000000000000000006269746368, 'AUC:WUT:0');
    }

    /**
     * @dev #TODO
     */
    function _claimableChecks(Auction memory auction, Bid memory bid) internal view {
        // require(_auctionIsOver(auction) || auction.top.account != bid.account, 'AUC:CC:0');
        require(_auctionIsOver(auction), 'AUC:CC:0');
        require(bid.claimed == false, 'AUC:CC:1');
        require(bid.amount > 0, 'AUC:CC:2');
    }

    function _auctionIsActive(Auction memory auction) internal view virtual returns (bool);

    function _auctionIsOver(Auction memory auction) internal view virtual returns (bool);

    function bidhash(uint256 auctionId, address account) internal view returns (bytes32 res) {
        res = keccak256(abi.encodePacked('bidhash', address(this), auctionId, account));
    }
}
