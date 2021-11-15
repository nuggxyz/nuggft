// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';

import './interfaces/INuggSwapable.sol';
import './interfaces/INuggETH.sol';

import 'hardhat/console.sol';
import './erc721/IERC721.sol';
import './core/Epochable.sol';

import './common/Testable.sol';
import './erc721/ERC721Holder.sol';

contract NuggSwap is ERC721Holder, Testable, Epochable {
    using Address for address payable;
    using SwapLib for SwapLib.AuctionData;

    mapping(address => mapping(uint256 => address[])) internal _auctionOwners;

    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) internal _encodedAuctionData;

    mapping(address => mapping(uint256 => mapping(uint256 => mapping(address => uint256)))) internal _encodedBidData;

    event BidPlaced(address nft, uint256 tokenId, uint256 auctionNum, address account, uint256 amount);

    event AuctionInit(uint256 indexed epoch);

    event Claim(address nft, uint256 tokenId, uint256 auctionNum, address indexed account);

    INuggETH immutable nuggeth;

    constructor(INuggETH _nuggeth) Epochable(250, uint128(block.number)) {
        nuggeth = _nuggeth;
    }

    function startAuction(
        address nft,
        uint256 tokenId,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) external {
        _startAuction(nft, tokenId, msg_sender(), requestedEpoch, requestedFloor);
    }

    function placeBid(
        address nft,
        uint256 tokenId,
        uint256 auctionNum
    ) external payable {
        _placeBid(nft, tokenId, auctionNum);
    }

    function claim(
        address nft,
        uint256 tokenId,
        uint256 auctionNum
    ) external {
        _claim(nft, tokenId, auctionNum);
    }

    function _startAuction(
        address nft,
        uint256 tokenId,
        address account,
        uint64 requestedEpoch,
        uint128 requestedFloor
    ) internal {
        SwapLib.takeToken(IERC721(nft), tokenId, account);

        address[] storage prevAuctionOwners = _auctionOwners[nft][tokenId];

        uint256 auctionNum = uint32(prevAuctionOwners.length);

        (SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) = loadData(nft, tokenId, auctionNum, account);

        auction.handleInitAuction(bid, requestedEpoch, requestedFloor);

        prevAuctionOwners.push(account);

        saveData(auction, bid);
    }

    function _placeBid(
        address nft,
        uint256 tokenId,
        uint256 auctionNum
    ) internal {
        (SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) = loadData(
            nft,
            tokenId,
            auctionNum,
            msg_sender()
        );

        if (!auction.exists) {
            SwapLib.mintToken(auction);
            _auctionOwners[nft][tokenId].push(address(0));
        }

        auction.handleBidPlaced(bid, msg_value());

        saveData(auction, bid);

        uint256 increase = bid.amount - auction.leaderAmount;

        (address royAccount, uint256 roy) = IERC2981(auction.nft).royaltyInfo(auction.tokenId, increase);

        if (royAccount == address(nuggeth)) {
            nuggeth.onERC2981Received{value: increase}(
                address(this),
                bid.account,
                auction.nft,
                tokenId,
                address(0),
                0,
                ''
            );
        } else {
            IERC2981Receiver(royAccount).onERC2981Received{value: roy}(
                address(this),
                bid.account,
                auction.nft,
                auction.tokenId,
                address(0),
                0,
                ''
            );
            nuggeth.onERC2981Received{value: increase - roy}(
                address(this),
                bid.account,
                auction.nft,
                tokenId,
                address(0),
                0,
                ''
            );
        }

        emit BidPlaced(auction.nft, auction.tokenId, auction.num, bid.account, bid.amount);
    }

    function _claim(
        address nft,
        uint256 tokenId,
        uint256 auctionNum
    ) internal {
        (SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) = loadData(
            nft,
            tokenId,
            auctionNum,
            msg_sender()
        );

        auction.handleBidClaim(bid);

        saveData(auction, bid);

        emit Claim(auction.nft, auction.tokenId, auction.num, bid.account);
    }

    function loadData(
        address nft,
        uint256 tokenId,
        uint256 auctionNum,
        address account
    ) internal view returns (SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) {
        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = SwapLib.decodeAuctionData(
            _encodedAuctionData[nft][tokenId][auctionNum]
        );

        (uint128 leaderAmount, ) = SwapLib.decodeBidData(_encodedBidData[nft][tokenId][auctionNum][leader]);

        auction = SwapLib.AuctionData({
            nft: nft,
            tokenId: tokenId,
            num: auctionNum,
            leader: leader,
            leaderAmount: leaderAmount,
            epoch: epoch,
            exists: exists,
            claimedByOwner: claimedByOwner,
            owner: _auctionOwners[nft][tokenId].length > auctionNum
                ? _auctionOwners[nft][tokenId][auctionNum]
                : address(0),
            activeEpoch: currentEpochId()
        });

        (uint128 amount, bool claimed) = SwapLib.decodeBidData(_encodedBidData[nft][tokenId][auctionNum][account]);

        bid = SwapLib.BidData({claimed: claimed, amount: amount, account: account});
    }

    function saveData(SwapLib.AuctionData memory auction, SwapLib.BidData memory bid) internal {
        _encodedAuctionData[auction.nft][auction.tokenId][auction.num] = SwapLib.encodeAuctionData(
            auction.leader,
            auction.epoch,
            auction.claimedByOwner,
            auction.exists
        );
        _encodedBidData[auction.nft][auction.tokenId][auction.num][bid.account] = SwapLib.encodeBidData(
            bid.amount,
            bid.claimed
        );
    }
}
