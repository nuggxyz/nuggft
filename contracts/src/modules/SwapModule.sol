pragma solidity 0.8.4;

import '../ercs/erc721/IERC721.sol';
import '../ercs/erc1155/IERC1155.sol';
import '../ercs/erc2981/IERC2981.sol';

import '../libraries/ShiftLib.sol';
import '../libraries/Address.sol';
import '../libraries/QuadMath.sol';
import '../libraries/StorageLib.sol';
import '../libraries/RoyaltyLib.sol';
import '../libraries/TokenLib.sol';

import '../storage/SwapStorage.sol';

library SwapModule {
    using Address for address;
    using TokenLib for address;
    using SwapStorage for uint256;
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
        (SwapStorage.Bin storage s, uint256 data, uint256 offer) = SwapStorage.load(token, tokenid, offerer);

        require(data.account() == user, 'SL:HSO:0');
        require(data.isTraditional(), 'SL:HSO:1');
        require(data.isOwner(), 'SL:HSO:2');

        delete s.offers[offerer];

        SwapStorage.incrementPointer(token, tokenid);

        TokenLib.move(token, tokenid, user, offerer, data.is1155());

        owed = RoyaltyLib.executeFull(staker, token, offer.eth());
    }

    function traditionalOffer(
        address token,
        uint256 tokenid,
        address user
    ) internal returns (uint256 newSwapData) {
        (SwapStorage.Bin storage s, uint256 data, uint256 offer) = SwapStorage.load(token, tokenid, user);

        token.validateOwnership(tokenid, data.account(), data.is1155());

        require(!offer.isOwner(), 'SL:HSO:0');
        require(data.isTraditional());

        (newSwapData, ) = uint256(0).account(user).isTraditional(true).eth(offer.eth() + msg.value);

        s.offers[user] = newSwapData;
    }

    function offer(
        address token,
        uint256 tokenid,
        uint256 activeEpoch,
        address user,
        uint256 value
    )
        internal
        returns (
            uint256 newSwapData,
            uint256 fee0,
            uint256 fee1
        )
    {
        (SwapStorage.Bin storage s, uint256 data, uint256 offer) = SwapStorage.load(token, tokenid, user);

        require(!offer.isOwner(), 'SL:HSO:0');
        require(!data.isTraditional());
        require(activeEpoch <= data.epoch(), 'SL:OBP:3');

        (newSwapData, ) = uint256(0).account(user).eth(offer.eth() + value);

        s.offers[data.account()] = data;

        s.data = newSwapData;

        // IS FIST OFFER ?
        if (data.isOwner()) {
            uint256 fee0 = data.eth().mulDiv(110, 100);

            require(fee0 < newSwapData.eth(), 'SL:OBP:4');

            fee1 = newSwapData.eth() - init;

            TokenLib.move(token, tokenid, user, address(this), data.is1155());
        } else {
            require(data.eth().mulDiv(101, 100) < newSwapData.eth(), 'SL:OBP:4');

            fee1 = newSwapData.eth() - data.eth();
        }
    }

    function claim(
        address token,
        uint256 tokenid,
        address user,
        uint256 index
    ) internal returns (uint256 data) {
        (SwapStorage.Bin storage s, uint256 data, uint256 offer) = SwapStorage.load(token, tokenid, user, index);

        require(data.account() != user, '');
        require(offer != 0);

        delete s.offers[user];

        return offer;
    }

    function claimWin(
        address token,
        uint256 tokenid,
        uint256 activeEpoch,
        address user
    ) internal returns (uint256 data) {
        (, uint256 data, ) = SwapStorage.load(token, tokenid, user);

        require(data.account() == user, '');
        require(activeEpoch > data.epoch(), '');

        SwapStorage.updatePointer(token, tokenid);

        TokenLib.move(token, tokenid, user, address(this), data.is1155());

        return data;
    }

    function startTraditionalSwap(
        address token,
        uint256 tokenid,
        address user,
        uint256 price,
        bool is1155
    ) internal returns (uint256 data) {
        (SwapStorage.Bin storage s, uint256 data, ) = SwapStorage.load(token, tokenid, user);

        require(data == 0);

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
        (SwapStorage.Bin storage s, uint256 data, ) = SwapStorage.load(token, tokenid, user);

        require(data == 0);

        // do not need to validate the token is sendable for traditional, need to validate ownership tho
        token.validateApproval(tokenid, user, is1155);

        (data, ) = uint256(0).account(user).eth(price);

        s.data = data;
    }
}
