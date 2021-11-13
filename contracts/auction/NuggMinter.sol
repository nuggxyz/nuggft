// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './base/Auctionable.sol';
import '../common/Launchable.sol';
import '../core/Seedable.sol';
import '../core/Epochable.sol';
import '../interfaces/INuggETH.sol';
import './interfaces/INuggMinter.sol';

import './periphery/IAuctionableImplementer.sol';

contract NuggMinter is INuggMinter, Auctionable, Launchable, Epochable, Seedable {
    IAuctionableImplementer internal _NUGGFT;

    INuggETH internal _NUGGETH;

    // uint256 private constant _OFFSET = 42069;

    // uint256 private _pendingReward = _OFFSET;

    constructor() Epochable(25) {}

    function NUGGETH() internal view returns (INuggETH res) {
        res = _NUGGETH;
    }

    // function calculateCurrentAuctionId() internal view virtual returns (uint256 res);

    /**
     * @notice inializes contract outside of constructor
     * @inheritdoc Launchable
     */
    function launch(bytes memory data) public override {
        super.launch(data);
        (address nuggft, address nuggeth) = abi.decode(data, (address, address));
        _NUGGFT = IAuctionableImplementer(nuggft);
        _NUGGETH = INuggETH(nuggeth);
    }

    /**
     * @inheritdoc Auctionable
     */
    function _onWinnerClaim(Bid memory bid) internal override {
        super._onWinnerClaim(bids);
        _NUGGFT.onMinterClaim(bid.accountwsss, bid.auctionId);
    }

    /**
     * @inheritdoc Auctionable
     */
    function _onBidPlaced(Auction memory auction) internal override {
        super._onBidPlaced(auction);
        if (!seedExists(auction.auctionId)) {
            setSeed(auction.auctionId, calculateCurrentSeed());
        }
        _NUGGETH.depositRewards{value: auction.top.amount - auction.last.amount}(address(this));
    }

    /**
     * @inheritdoc Auctionable
     */
    function _auctionIsActive(Auction memory auction) internal view override returns (bool res) {
        return epochStatus(auction.auctionId) == EpochMath.Status.ACTIVE;
    }

    /**
     * @inheritdoc Auctionable
     */
    function _auctionIsOver(Auction memory auction) internal view override returns (bool res) {
        return epochStatus(auction.auctionId) == EpochMath.Status.OVER;
    }

    function currentAuction() public view virtual override returns (Auction memory res) {
        uint256 auctionId = currentEpochId();
        res = getAuction(auctionId);
    }

    /**
     * @notice gets unique base based on given epoch and converts encoded bytes to object that can be merged
     * Note: by using the block hash no one knows what a nugg will look like before it's epoch.
     * We considered making this harder to manipulate, but we decided that if someone were able to
     * pull it off and make their own custom nugg, that would be really fucking cool.
     */
    function calculateCurrentSeed() public view override returns (bytes32 res) {
        uint256 num = blocknumFromId(currentEpochId()) - 1;
        res = block_hash(num);
        require(res != 0, 'EPC:SBL');
        res = keccak256(abi.encodePacked(res, num));
    }
}
