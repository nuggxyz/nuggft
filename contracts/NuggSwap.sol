// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';

import './interfaces/INuggSwapable.sol';

import './erc721/IERC721.sol';

import './common/Testable.sol';

contract NuggSwap is Testable {
    using Address for address payable;
    using SwapLib for SwapLib.AuctionData;

    mapping(uint256 => address[]) internal _auctionOwners;

    mapping(uint256 => uint256) internal _encodedAuctionData;

    mapping(uint256 => mapping(address => uint256)) internal _encodedBidData;

    event BidPlaced(uint256 auctionId, address account, uint256 amount);

    event AuctionInit(uint256 indexed epoch);

    event Claim(uint256 indexed epoch, address indexed account);

    function startAuction(
        IERC721 nft,
        uint64 tokenId,
        uint32 requestedEpoch,
        uint128 requestedFloor
    ) external {
        _startAuction(nft, tokenId, msg_sender(), requestedEpoch, requestedFloor);
    }

    function placeBid(
        IERC721 nft,
        uint64 tokenId,
        uint32 auctionNum
    ) external {
        _placeBid(nft, tokenId, auctionNum);
    }

    function claim(
        IERC721 nft,
        uint64 tokenId,
        uint32 auctionNum
    ) external {
        _claim(nft, tokenId, auctionNum);
    }

    function _startAuction(
        IERC721 nft,
        uint64 tokenId,
        address account,
        uint32 requestedEpoch,
        uint128 requestedFloor
    ) internal {
        SwapLib.takeToken(nft, tokenId, account);

        address[] storage prevAuctionOwners = _auctionOwners[SwapLib.encodeAuctionListId(nft, tokenId)];

        uint32 auctionNum = uint32(prevAuctionOwners.length);

        (SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) = loadData(nft, tokenId, auctionNum, account);

        auction.handleInitAuction(bid, requestedEpoch, requestedFloor);

        prevAuctionOwners.push(account);

        saveData(auction, bid);
    }

    function _placeBid(
        IERC721 nft,
        uint64 tokenId,
        uint32 auctionNum
    ) internal {
        (SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) = loadData(nft, tokenId, auctionNum, msg_sender());

        if (!auction.exists) {
            SwapLib.mintToken(auction);
            _auctionOwners[SwapLib.encodeAuctionListId(nft, tokenId)].push(address(0));
        }

        auction.handleBidPlaced(bid, msg_value());

        saveData(auction, bid);

        emit BidPlaced(auction.id, bid.account, bid.amount);
    }

    function _claim(
        IERC721 nft,
        uint64 tokenId,
        uint32 auctionNum
    ) internal {
        (SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) = loadData(nft, tokenId, auctionNum, msg_sender());

        auction.handleBidClaim(bid);

        saveData(auction, bid);

        emit Claim(auction.id, bid.account);
    }

    function loadData(
        IERC721 nft,
        uint64 tokenId,
        uint32 auctionNum,
        address account
    ) internal returns (SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) {
        uint256 auctionId = SwapLib.encodeAuctionId(nft, tokenId, auctionNum);
        uint256 auctionListId = SwapLib.encodeAuctionListId(nft, tokenId);

        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = SwapLib.decodeAuctionData(_encodedAuctionData[auctionId]);
        (uint248 leaderAmount, ) = SwapLib.decodeBid(_encodedBidData[auctionId][leader]);

        auction = SwapLib.AuctionData({
            nft: nft,
            tokenId: tokenId,
            num: auctionNum,
            id: auctionId,
            leader: leader,
            leaderAmount: leaderAmount,
            epoch: epoch,
            exists: exists,
            claimedByOwner: claimedByOwner,
            owner: _auctionOwners[auctionListId][auctionNum],
            activeEpoch: INuggSwapable(address(nft)).currentEpoch()
        });

        (uint248 amount, bool claimed) = SwapLib.decodeBid(_encodedBidData[auctionId][account]);

        bid = SwapLib.BidData({claimed: claimed, amount: amount, account: account});
    }

    function saveData(SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) internal {
        _encodedAuctionData[auction.id] = SwapLib.encodeAuctionData(auction.leader, auction.epoch, auction.claimedByOwner, auction.exists);
        _encodedBidData[auction.id][bid.account] = SwapLib.encodeBidData(bid.amount, bid.claimed);
    }
}
