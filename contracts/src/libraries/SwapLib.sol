pragma solidity 0.8.4;

import '../erc721/IERC721.sol';
import '../erc1155/IERC1155.sol';

import '../erc2981/IERC2981.sol';
import './ShiftLib.sol';
import './Address.sol';
import './QuadMath.sol';
import './StorageLib.sol';
import './RoyaltyLib.sol';
import './TokenLib.sol';

import '../modules/Swap.mod.sol';

library SwapLib {
    using Address for address;
    using TokenLib for address;
    using SwapMod for uint256;
    using RoyaltyLib for uint256;
    using QuadMath for uint256;

    // if swap is finalized traditionally :
    // - buyer pays :  execution price (+) 5% fee  - .20 nugglabs - 1.80% to xnugg - 34% royalty
    // - seller gets:  execution price (-) 5% fee - .20 nugglabs - 1.80% to xnugg - 34% royalty

    // requirement for sell off - execution price MUST be >= 110 % of origin price
    // - essentially what happens is that the buyer has a 10% fee
    // - otherwise it is executed under tradtional rules

    // if swap is finalized by sell off  && diff >
    // - buyer pays : execution price (+) 0% fee - -
    // - seller gets: origin price    (-) 0% fee - .
    // - xnugg gets:  execution price (-) fees flip (xnugg gets 90%, 10% to royalties)

    function acceptOffer(
        address token,
        uint256 tokenid,
        address user,
        address offerer,
        address staker
    ) internal returns (uint256 owed) {
        (, uint256 swapData, uint256 offerData) = SwapMod.loadStorage(token, tokenid, offerer);

        require(swapData.account() == user, 'SL:HSO:0');
        require(swapData.isTraditional(), 'SL:HSO:1');
        require(swapData.isOwner(), 'SL:HSO:2');

        SwapMod.updatePointer(token, tokenid);

        TokenLib.move(token, tokenid, user, offerer, swapData.is1155());

        owed = RoyaltyLib.executeFull(staker, token, offerData.eth());
    }

    function traditionalOffer(
        address token,
        uint256 tokenid,
        address user
    ) internal returns (uint256 newSwapData) {
        (SwapMod.Storage storage s, uint256 swapData, uint256 offerData) = SwapMod.loadStorage(token, tokenid, user);

        token.validateOwnership(tokenid, swapData.account(), swapData.is1155());

        require(!offerData.isOwner(), 'SL:HSO:0');
        require(swapData.isTraditional());

        (newSwapData, ) = uint256(0).account(user).isTraditional(true).eth(offerData.eth() + msg.value);

        s.users[user] = newSwapData;
    }

    function offer(
        address token,
        uint256 tokenid,
        uint256 activeEpoch,
        address user,
        address staker
    ) internal returns (uint256 newSwapData) {
        (SwapMod.Storage storage s, uint256 swapData, uint256 offerData) = SwapMod.loadStorage(token, tokenid, user);

        require(!offerData.isOwner(), 'SL:HSO:0');
        require(!swapData.isTraditional());
        require(activeEpoch <= swapData.epoch(), 'SL:OBP:3');

        (newSwapData, ) = uint256(0).account(user).eth(offerData.eth() + msg.value);

        s.users[swapData.account()] = swapData;

        s.data = newSwapData;

        // IS FIST OFFER ?
        if (swapData.isOwner()) {
            uint256 init = swapData.eth().mulDiv(110, 100);
            require(init < newSwapData.eth(), 'SL:OBP:4');

            RoyaltyLib.executeFull(staker, token, init);
            RoyaltyLib.executeIncrement(staker, token, newSwapData.eth() - init);

            token.move(tokenid, user, address(this), swapData.is1155());
        } else {
            uint256 init = swapData.eth().mulDiv(101, 100);
            require(init < newSwapData.eth(), 'SL:OBP:4');
            RoyaltyLib.executeIncrement(staker, token, newSwapData.eth() - swapData.eth());
        }
    }

    function claim(
        address token,
        uint256 tokenid,
        address user
    ) internal returns (uint256 data) {
        (SwapMod.Storage storage s, uint256 swapData, uint256 offerData) = SwapMod.loadStorage(token, tokenid, user);

        require(swapData.account() != user, '');
        require(offerData != 0);

        delete s.users[user];

        return offerData;
    }

    function claimWin(
        address token,
        uint256 tokenid,
        uint256 activeEpoch,
        address user
    ) internal returns (uint256 data) {
        (, uint256 swapData, ) = SwapMod.loadStorage(token, tokenid, user);

        require(swapData.account() == user, '');
        require(activeEpoch > swapData.epoch(), '');

        SwapMod.updatePointer(token, tokenid);

        TokenLib.move(token, tokenid, user, address(this), swapData.is1155());

        return swapData;
    }

    function startTraditionalSwap(
        address token,
        uint256 tokenid,
        address user,
        uint256 price,
        bool is1155
    ) internal returns (uint256 data) {
        (SwapMod.Storage storage s, uint256 swapData, ) = SwapMod.loadStorage(token, tokenid, user);

        require(swapData == 0);

        // do not need to validate the token is sendable for traditional, need to validate ownership tho

        token.validateOwnership(tokenid, user, is1155);

        (data, ) = uint256(0).account(user).isTraditional(true).eth(price);

        s.data = data;
    }

    function startSwap(
        address token,
        uint256 tokenid,
        address user,
        uint256 price,
        bool is1155
    ) internal returns (uint256 data) {
        (SwapMod.Storage storage s, uint256 swapData, ) = SwapMod.loadStorage(token, tokenid, user);

        require(swapData == 0);

        // do not need to validate the token is sendable for traditional, need to validate ownership tho
        token.validateApproval(tokenid, user, is1155);

        (data, ) = uint256(0).account(user).eth(price);

        s.data = data;
    }
}
