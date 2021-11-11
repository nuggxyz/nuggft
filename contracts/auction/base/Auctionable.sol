// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '@openzeppelin/contracts/utils/Context.sol';

import '../interfaces/IAuctionable.sol';
import '../../libraries/QuadMath.sol';
import '../../libraries/Exchange.sol';
import '../../base/Mutexable.sol';
import '../../base/Testable.sol';
import '../../base/Exchangeable.sol';
import '../../interfaces/IWETH9.sol';
import 'hardhat/console.sol';

/**
 * @title Auctionable
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice enables children contracts to bidreak themselves into auctions
 */
abstract contract Auctionable is IAuctionable, Mutexable, Exchangeable {
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
    function placeBid(
        uint256 auctionId,
        uint256 amount,
        Currency currency
    ) external payable override {
        _placeBid(msg_sender(), amount, auctionId, currency);
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
    function claim(uint256 auctionId, Currency currency) external override {
        _claim(auctionId, msg_sender(), currency);
    }

    /**
     * @dev #TODO
     */
    function _fallback() internal pure override {
        require(false, 'AUC:ETHF:0');
    }

    /**
     * @dev #TODO
     */
    function _claim(
        uint256 auctionId,
        address account,
        Currency currency
    ) internal lock(global) {
        Auction memory auction;
        auction.auctionId = auctionId;

        Bid memory bid = _optimisticBid(auctionId, account, 0, currency);

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
        uint256 auctionId,
        Currency currency
    ) internal lock(global) {
        require(amount > 0, 'AUC:MSG0:0');

        takeCurrency(account, amount, currency);

        Bid memory bid = _optimisticBid(auctionId, account, amount, currency);
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
        emit BidPlaced(auction.auctionId, auction.top.account, auction.top.amount, auction.top.currency);
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
        giveCurrency(bid.account, bid.amount, bid.currency);
        emit NormalClaim(bid.auctionId, bid.account, bid.amount, bid.currency);
    }

    function _optimisticBid(
        uint256 auctionId,
        address account,
        uint256 amount,
        Currency currency
    ) internal view returns (Bid memory bid) {
        uint256 amt = _bidsAmt[auctionId][account];
        bid.amount = amt + amount;
        bid.account = account;
        bid.auctionId = auctionId;
        bid.currency = currency;
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
