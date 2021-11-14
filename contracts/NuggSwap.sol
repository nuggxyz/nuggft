// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';

import './interfaces/INuggSwapable.sol';
import 'hardhat/console.sol';
import './erc721/IERC721.sol';

import './common/Testable.sol';
import './erc721/ERC721Holder.sol';

contract NuggSwap is ERC721Holder, Testable {
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
    ) external payable {
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

        address[] storage prevAuctionOwners = _auctionOwners[SwapLib.encodeAuctionId(address(nft), tokenId, 0)];

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
        (SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) = loadData(
            nft,
            tokenId,
            auctionNum,
            msg_sender()
        );

        if (!auction.exists) {
            SwapLib.mintToken(auction);
            _auctionOwners[SwapLib.encodeAuctionId(address(nft), tokenId, 0)].push(address(0));
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
        (SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) = loadData(
            nft,
            tokenId,
            auctionNum,
            msg_sender()
        );
        console.log('HELLO', bid.amount);

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
        uint256 auctionId = SwapLib.encodeAuctionId(address(nft), tokenId, auctionNum);
        uint256 auctionListId = SwapLib.encodeAuctionId(address(nft), tokenId, 0);

        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = SwapLib.decodeAuctionData(
            _encodedAuctionData[auctionId]
        );
        (uint128 leaderAmount, ) = SwapLib.decodeBidData(_encodedBidData[auctionId][leader]);

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
            owner: _auctionOwners[auctionListId].length > auctionNum
                ? _auctionOwners[auctionListId][auctionNum]
                : address(0),
            activeEpoch: INuggSwapable(address(nft)).currentEpoch()
        });

        (uint128 amount, bool claimed) = SwapLib.decodeBidData(_encodedBidData[auctionId][account]);

        console.log('auction.activeEpoch: ', auction.activeEpoch, claimedByOwner);
        // console.logBytes32(bytes32(_encodedBidData[auctionId][account]));
        bid = SwapLib.BidData({claimed: claimed, amount: amount, account: account});
    }

    function saveData(SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) internal {
        _encodedAuctionData[auction.id] = SwapLib.encodeAuctionData(
            auction.leader,
            auction.epoch,
            auction.claimedByOwner,
            auction.exists
        );
        _encodedBidData[auction.id][bid.account] = SwapLib.encodeBidData(bid.amount, bid.claimed);
    }
}
