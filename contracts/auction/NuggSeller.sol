// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './base/Auctionable.sol';
import '../common/Launchable.sol';
import '../interfaces/INuggETH.sol';

import '../core/Seedable.sol';
import '../core/Epochable.sol';
import './interfaces/INuggSeller.sol';
import '../interfaces/INuggFT.sol';
import '../erc721/ERC721Holder.sol';

contract NuggSeller is INuggSeller, Auctionable, Launchable, ERC721Holder {
    INuggFT internal _NUGGFT;

    INuggETH internal _NUGGETH;

    uint256 private _counter = 1;

    mapping(uint256 => Sale) _sales;

    mapping(uint256 => uint256) _lastSaleByToken;

    constructor() {}

    function NUGGETH() internal view override returns (INuggETH res) {
        res = _NUGGETH;
    }

    function startSale(
        uint256 tokenId,
        uint256 length,
        uint256 floor
    ) external {
        Sale memory sale = Sale({sold: false, claimed: false, tokenId: tokenId, startblock: block.number, length: length, floor: floor, seller: msg_sender()});

        _NUGGFT.safeTransferFrom(sale.seller, address(this), tokenId);

        require(_NUGGFT.ownerOf(tokenId) == address(this), 'NS:START:0');
        uint256 saleId = _counter++;
        _sales[saleId] = sale;
        _lastSaleByToken[tokenId] = saleId;

        emit SaleStart(saleId, tokenId, length, floor);
    }

    function claimSale(uint256 saleId) external {
        Sale memory sale = _sales[saleId];

        require(block_num() > sale.startblock + sale.length, 'NS:CS:0');
        require(msg_sender() == sale.seller, 'NS:CS:1');
        require(sale.claimed == false, 'NS:CS:2');

        _sales[saleId].claimed = true;

        if (sale.sold) {
            uint256 amount = _bidsAmt[saleId][_topAddr[saleId]];
            uint256 royalties = (amount * 15) / 100;
            _NUGGETH.depositRewards{value: royalties}(address(this));
            Exchange.give_eth(msg_sender(), amount - royalties);
        } else {
            _NUGGFT.safeTransferFrom(address(this), sale.seller, sale.tokenId);
            emit SaleStop(saleId);
        }
    }

    function stopSale(uint256 saleId) public {
        Sale memory sale = _sales[saleId];
        require(msg_sender() == sale.seller, 'NS:SS:0');
        require(!sale.sold, 'NS:SS:1');
        require(!sale.claimed, 'NS:SS:2');

        _sales[saleId].claimed = true;

        _NUGGFT.safeTransferFrom(address(this), sale.seller, sale.tokenId);
        emit SaleStop(saleId);
    }

    /**
     * @notice inializes contract outside of constructor
     * @inheritdoc Launchable
     */
    function launch(bytes memory data) public override {
        super.launch(data);
        (address nuggft, address nuggeth, address weth) = abi.decode(data, (address, address, address));
        _NUGGFT = INuggFT(nuggft);
        _NUGGETH = INuggETH(nuggeth);
        _NUGGFT.setApprovalForAll(nuggft, true);
    }

    /**
     * @notice returns id of last and/or current sale for a given token id
     * @inheritdoc INuggSeller
     */
    function lastSaleByToken(uint256 tokenId) public view override returns (uint256 res) {
        return _lastSaleByToken[tokenId];
    }

    /**
     * @inheritdoc Auctionable
     */
    function _onWinnerClaim(Bid memory bid) internal override {
        super._onWinnerClaim(bid);
        _NUGGFT.onBuyerClaim(bid.account, _sales[bid.auctionId].tokenId);
    }

    /**
     * @inheritdoc Auctionable
     */
    function _onBidPlaced(Auction memory auction) internal override {
        require(auction.top.amount >= _sales[auction.auctionId].floor, 'NS:OBP:0');
        super._onBidPlaced(auction);
        if (auction.last.amount == 0) _sales[auction.auctionId].sold = true;
    }

    /**
     * @inheritdoc Auctionable
     */
    function _auctionIsActive(Auction memory auction) internal view override returns (bool res) {
        Sale memory sale = _sales[auction.auctionId];
        res = block_num() >= sale.startblock && block_num() < sale.startblock + sale.length;
    }

    /**
     * @inheritdoc Auctionable
     */
    function _auctionIsOver(Auction memory auction) internal view override returns (bool res) {
        Sale memory sale = _sales[auction.auctionId];
        res = block_num() > sale.startblock + sale.length;
    }
}
