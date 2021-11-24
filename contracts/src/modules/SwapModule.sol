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

import '../libraries/RoyaltyLib.sol';

import '../storage/SwapStorage.sol';

library SwapModule {
    using Address for address;
    using TokenLib for address;
    using SwapStorage for uint256;
    using RoyaltyLib for uint256;
    using QuadMath for uint256;

    // finish projectmod
    // set up main NuggSwap.sol
    // add comments
    //

    // if swap is finalized basicly :
    // - buyer pays :  execution price (+) 5% fee  - .20 nugglabs - 1.80% to xnugg - 34% royalty
    // - seller gets:  execution price (-) 5% fee - .20 nugglabs - 1.80% to xnugg - 34% royalty

    // requirement for sell off - execution price MUST be >= 110 % of origin price
    // - essentially what happens is that the buyer has a 10% fee
    // - otherwise it is executed under tradtional rules

    // if swap is finalized by sell off  && diff >
    // - buyer pays : execution price (+) 0% fee - -
    // - seller gets: origin price    (-) 0% fee - .
    // - xnugg gets:  execution price (-) fees flip (xnugg gets 90%, 10% to royalties)

    function submitBasicOffer(
        address token,
        uint256 tokenid,
        address user,
        uint256 value
    )
        internal
        returns (
            SwapStorage.Bin storage s,
            uint256 data,
            uint256 offerBefore,
            uint256 offerAfter
        )
    {
        (s, data, offerBefore) = SwapStorage.load(token, tokenid, user);

        token.validateOwnership(tokenid, data.account(), data.is1155());

        require(!offerBefore.isOwner(), 'SL:HSO:0');
        require(data.isBasic());

        (offerAfter, ) = uint256(0).account(user).isBasic(true).eth(offerBefore.eth() + value);

        s.offers[user] = offerAfter;
    }

    function submitCoreOffer(
        address token,
        uint256 tokenid,
        uint256 activeEpoch,
        address user,
        uint256 value
    )
        internal
        returns (
            SwapStorage.Bin storage s,
            uint256 data,
            uint256 offerBefore,
            uint256 offerAfter,
            uint256 fee0,
            uint256 fee1
        )
    {
        (s, data, offerBefore) = SwapStorage.load(token, tokenid, user);

        require(!offerBefore.isOwner(), 'SL:HSO:0');
        require(!data.isBasic());
        require(activeEpoch <= data.epoch(), 'SL:OBP:3');

        (offerAfter, ) = uint256(0).account(user).eth(offerBefore.eth() + value);

        s.offers[data.account()] = data;

        s.data = offerAfter;

        // IS FIST OFFER ?
        if (data.isOwner()) {
            fee0 = data.eth().mulDiv(110, 100);

            require(fee0 < offerAfter.eth(), 'SL:OBP:4');

            fee1 = offerAfter.eth() - fee0;

            TokenLib.move(token, tokenid, user, address(this), data.is1155());
        } else {
            require(data.eth().mulDiv(101, 100) < offerAfter.eth(), 'SL:OBP:4');

            fee1 = offerAfter.eth() - data.eth();
        }
    }

    function acceptBasicOffer(
        address token,
        uint256 tokenid,
        address offerer,
        address user
    )
        internal
        returns (
            SwapStorage.Bin storage s,
            uint256 data,
            uint256 offer
        )
    {
        (s, data, offer) = SwapStorage.load(token, tokenid, offerer);

        require(offer != 0, 'SL:HSO:0');
        require(data.account() == user, 'SL:HSO:0');
        require(data.isBasic(), 'SL:HSO:1');
        require(data.isOwner(), 'SL:HSO:2');

        delete s.offers[offerer];

        SwapStorage.incrementPointer(token, tokenid);

        TokenLib.move(token, tokenid, user, offerer, data.is1155());
    }

    function claim(
        address token,
        uint256 tokenid,
        address user,
        uint256 index
    )
        internal
        returns (
            SwapStorage.Bin storage s,
            uint256 data,
            uint256 offer
        )
    {
        (s, data, offer) = SwapStorage.load(token, tokenid, user, index);

        require(data.account() != user, '');
        require(offer != 0);

        delete s.offers[user];
    }

    function claimWin(
        address token,
        uint256 tokenid,
        uint256 activeEpoch,
        uint256 index,
        address user
    )
        internal
        returns (
            SwapStorage.Bin storage s,
            uint256 data,
            uint256 offer
        )
    {
        (, data, ) = SwapStorage.load(token, tokenid, user);

        require(data.account() == user, '');
        require(activeEpoch > data.epoch(), '');

        SwapStorage.incrementPointer(token, tokenid);

        data = data.claimed(true);

        s.data = data;

        TokenLib.move(token, tokenid, user, address(this), data.is1155());
    }

    function rescueSwap(
        address token,
        uint256 tokenid,
        address user,
        uint256 value,
        uint256 activeEpoch
    ) internal returns (SwapStorage.Bin storage s, uint256 data) {
        (s, data, ) = SwapStorage.load(token, tokenid, user);

        require(data == 0);

        TokenLib.mintToken(token, tokenid);

        (data, ) = uint256(0).account(user).epoch(activeEpoch).eth(value);

        s.data = data;
    }

    function startBasicSwap(
        address token,
        uint256 tokenid,
        address user,
        uint256 price,
        bool is1155
    ) internal returns (SwapStorage.Bin storage s, uint256 data) {
        (s, data, ) = SwapStorage.load(token, tokenid, user);

        require(data == 0);

        // do not need to validate the token is sendable for basic, need to validate ownership tho
        token.validateOwnership(tokenid, user, is1155);

        (data, ) = uint256(0).account(user).isBasic(true).eth(price);

        s.data = data;
    }

    function startCoreSwap(
        address token,
        uint256 tokenid,
        address user,
        uint256 price,
        bool is1155
    ) internal returns (SwapStorage.Bin storage s, uint256 data) {
        (s, data, ) = SwapStorage.load(token, tokenid, user);

        require(data == 0);

        // do not need to validate the token is sendable for basic, need to validate ownership tho
        token.validateApproval(tokenid, user, is1155);

        (data, ) = uint256(0).account(user).eth(price);

        s.data = data;
    }
}
