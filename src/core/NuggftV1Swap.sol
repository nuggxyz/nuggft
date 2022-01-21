// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggftV1Swap} from '../interfaces/nuggftv1/INuggftV1Swap.sol';
import {NuggftV1Stake} from './NuggftV1Stake.sol';
import {CastLib} from '../libraries/CastLib.sol';
import {TransferLib} from '../libraries/TransferLib.sol';

import {NuggftV1AgentType} from '../types/NuggftV1AgentType.sol';
import '../_test/utils/forge.sol';

/// @notice mechanism for trading of nuggs between users (and items between nuggs)
/// @dev Explain to a developer any extra details
abstract contract NuggftV1Swap is INuggftV1Swap, NuggftV1Stake {
    using CastLib for uint256;

    using NuggftV1AgentType for uint256;

    struct Mapping {
        Storage self;
        mapping(uint16 => Storage) items;
    }

    struct Storage {
        uint256 data;
        mapping(address => uint256) offers;
    }

    struct Memory {
        uint256 swapData;
        uint256 offerData;
        uint24 activeEpoch;
        address sender;
    }

    mapping(uint16 => uint256) protocolItems;
    mapping(uint160 => Mapping) swaps;

    uint96 public constant MIN_OFFER = 100 gwei;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  offer
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Swap
    function offer(uint160 tokenId) external payable override {
        uint256 swapData = agency[tokenId];
        uint24 activeEpoch = epoch();

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise

        uint256 currUserOffer;

        // logger.log(m.activeEpoch, 'm.activeEpoch', tokenId, 'tokenId', m.swapData, 'm.swapData');

        if (activeEpoch == tokenId && swapData == 0) {
            // to ensure we at least have enough to increment the offer amount by 2%
            require(msg.value >= MIN_OFFER, hex'21');

            // we do not need this, could take tokenId out as an argument - but do not want to give users
            // the ability to accidently place an offer for nugg A and end up minting nugg B.
            // assert(offerData == 0);

            // updatedAgency = NuggftV1AgentType.create(m.activeEpoch, m.sender, uint96(msg.value), NuggftV1AgentType.Flag.SWAP);

            assembly {
                currUserOffer := div(callvalue(), 1000000000)
                // updatedAgency := or(caller(), or(shl(160, div(callvalue(), 1000000000)), or(shl(230, activeEpoch), shl(254, 0x1))))
            }

            addStakedShareFromMsgValue(0);

            setProofFromEpoch(tokenId);

            emit Transfer(address(0), address(this), tokenId);
        } else {
            require(swapData.flag() == NuggftV1AgentType.Flag.SWAP, hex'24');

            uint256 offerData;

            if (uint160(msg.sender) == uint160(swapData)) {
                offerData = swapData;
            } else {
                offerData = swaps[tokenId].self.offers[msg.sender];
            }

            // require((swapData >> 254) == uint256(NuggftV1AgentType.Flag.SWAP, hex'24');

            if (offerData != 0) {
                // forces user to claim previous swap before acting on this one
                // prevents owner from COMMITTING on their own swap - not offering
                require(offerData.epoch() >= activeEpoch, hex'0F');

                // assert(!offerData.flag()); // always be caught by the require above
            }

            // if the leader "owns" the swap, then it was initated by them - "commit" must be executed
            if (swapData.epoch() == 0) {
                emit Transfer(address(uint160(swapData)), address(this), tokenId);

                // agency[tokenId] = agency[tokenId].account(address(this));
                require(msg.value >= eps(), hex'25');

                unchecked {
                    activeEpoch++;
                }

                swaps[tokenId].self.offers[address(uint160(swapData))] = swapData.epoch(activeEpoch);
            } else {
                assembly {
                    let ep := and(shr(230, swapData), 0xffffff)

                    if lt(ep, activeEpoch) {
                        mstore(0x00, 0x2f)
                        revert(31, 0x01)
                    }

                    activeEpoch := ep
                }
                // require(activeEpoch <= swapData.epoch(), hex'2F');

                swaps[tokenId].self.offers[swapData.account()] = swapData;
            }

            uint256 currSwapOffer;

            assembly {
                let mask := sub(shl(70, 1), 1)
                currSwapOffer := and(shr(160, swapData), mask)
                currUserOffer := and(shr(160, offerData), mask)
                currUserOffer := add(currUserOffer, div(callvalue(), 1000000000))
                // let inc := div(mul(baseEth, 10200), 10000)
                if gt(div(mul(currSwapOffer, 10200), 10000), currUserOffer) {
                    mstore(0x00, 0x26)
                    revert(0x19, 0x01)
                }

                currSwapOffer := mul(sub(currUserOffer, currSwapOffer), 1000000000)
            }

            addStakedEth(uint96(currSwapOffer));
        }

        uint256 updatedAgency;

        assembly {
            updatedAgency := or(caller(), or(shl(160, currUserOffer), or(shl(230, activeEpoch), shl(254, 0x1))))

            // agency[tokenId] = updatedAgency;
            mstore(0, tokenId)
            mstore(0x20, agency.slot)
            sstore(keccak256(0, 64), updatedAgency)
        }

        emit Offer(tokenId, bytes32(updatedAgency));
    }

    /// @inheritdoc INuggftV1Swap
    function offerItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) external payable override {
        require(isAgent(msg.sender, buyerTokenId), hex'26');

        uint256 swapData = swaps[sellerTokenId].items[itemId].data;
        uint24 activeEpoch = epoch();

        require(swapData != 0, hex'22');

        uint256 offerData;

        if (buyerTokenId == uint160(swapData)) {
            offerData = swapData;
        } else {
            offerData = swaps[sellerTokenId].items[itemId].offers[address(buyerTokenId)];
        }

        if (offerData != 0) {
            // forces user to claim previous swap before acting on this one
            // prevents owner from COMMITTING on their own swap - not offering
            require(offerData.epoch() >= activeEpoch, hex'27');

            // assert(!m.offerData.flag()); // always be caught by the require above
        }

        if (offerData == 0 && (swapData.epoch() == 0)) {
            require(msg.value >= eps(), hex'25');

            unchecked {
                activeEpoch++;
            }

            swaps[sellerTokenId].items[itemId].offers[swapData.account()] = swapData.epoch(activeEpoch);
        } else {
            assembly {
                let ep := and(shr(230, swapData), 0xffffff)

                if lt(ep, activeEpoch) {
                    mstore(0x00, 0x2f)
                    revert(31, 0x01)
                }

                activeEpoch := ep
            }

            swaps[sellerTokenId].items[itemId].offers[swapData.account()] = swapData;
        }

        uint256 currSwapOffer;
        uint256 currUserOffer;

        assembly {
            let mask := sub(shl(70, 1), 1)
            currSwapOffer := and(shr(160, swapData), mask)
            currUserOffer := and(shr(160, offerData), mask)
            currUserOffer := add(currUserOffer, div(callvalue(), 1000000000))

            if gt(div(mul(currSwapOffer, 10200), 10000), currUserOffer) {
                mstore(0x00, 0x26)
                revert(0x19, 0x01)
            }

            currSwapOffer := mul(sub(currUserOffer, currSwapOffer), 1000000000)
        }

        addStakedEth(uint96(currSwapOffer));

        uint256 updatedAgency;

        assembly {
            updatedAgency := or(buyerTokenId, or(shl(160, currUserOffer), or(shl(230, activeEpoch), shl(254, 0x1))))
        }

        swaps[sellerTokenId].items[itemId].data = updatedAgency;

        emit OfferItem(encodeSellingItemId(sellerTokenId, itemId), bytes32(updatedAgency));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  claim
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Swap
    function claim(uint160 tokenId) external override {
        TransferLib.give(msg.sender, _claim(tokenId));
    }

    /// @inheritdoc INuggftV1Swap
    function multiclaim(uint160[] calldata tokenIds) external override {
        uint256 acc;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            acc += _claim(tokenIds[i]);
        }

        TransferLib.give(msg.sender, acc);
    }

    function _claim(uint160 tokenId) internal returns (uint96 value) {
        (Storage storage s, Memory memory m) = loadTokenSwap(tokenId, msg.sender);

        delete s.offers[msg.sender];

        if (checkClaimerIsWinnerOrLoser(m)) {
            // agency[tokenId] = NuggftV1AgentType.create(0, msg.sender, 0, NuggftV1AgentType.Flag.OWN);
            assembly {
                mstore(0, tokenId)
                mstore(0x20, agency.slot)
                sstore(keccak256(0, 64), or(caller(), shl(254, 0x3)))
            }

            emit Transfer(address(this), msg.sender, tokenId);
        } else {
            value = m.offerData.eth();
        }

        emit Claim(tokenId, msg.sender);
    }

    /// @inheritdoc INuggftV1Swap
    function claimItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) public override {
        TransferLib.give(msg.sender, _claimItem(buyerTokenId, sellerTokenId, itemId));
    }

    /// @inheritdoc INuggftV1Swap
    function multiclaimItem(
        uint160[] calldata buyerTokenIds,
        uint160[] calldata sellerTokenIds,
        uint16[] calldata itemIds
    ) external override {
        require(itemIds.length == sellerTokenIds.length && itemIds.length == buyerTokenIds.length, hex'23');

        uint96 acc;

        for (uint256 i = 0; i < itemIds.length; i++) {
            acc += _claimItem(buyerTokenIds[i], sellerTokenIds[i], itemIds[i]);
        }

        TransferLib.give(msg.sender, acc);
    }

    function _claimItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) internal returns (uint96 value) {
        require(isAgent(msg.sender, buyerTokenId), hex'29');

        (Storage storage s, Memory memory m) = loadItemSwap(sellerTokenId, itemId, address(buyerTokenId));

        delete s.offers[address(buyerTokenId)];

        if (checkClaimerIsWinnerOrLoser(m)) {
            delete s.data;

            assert(protocolItems[itemId] > 0);

            addItem(buyerTokenId, itemId);

            protocolItems[itemId]--;
        } else {
            value = m.offerData.eth();
        }

        emit ClaimItem(encodeSellingItemId(sellerTokenId, itemId), buyerTokenId);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  sell
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Swap
    function sell(uint160 tokenId, uint96 floor) external override {
        require(isOwner(msg.sender, tokenId), hex'2A');

        require(floor >= eps(), hex'2B');

        // uint256 updatedAgency = NuggftV1AgentType.create(0, msg.sender, floor, NuggftV1AgentType.Flag.SWAP);
        uint256 updatedAgency;

        assembly {
            updatedAgency := or(caller(), or(shl(160, div(floor, 1000000000)), or(shl(230, 0), shl(254, 0x1))))

            mstore(0, tokenId)
            mstore(0x20, agency.slot)
            sstore(keccak256(0, 64), updatedAgency)
        }

        emit Sell(tokenId, bytes32(updatedAgency));
    }

    /// @inheritdoc INuggftV1Swap
    function sellItem(
        uint160 tokenId,
        uint16 itemId,
        uint96 floor
    ) external override {
        require(isAgent(msg.sender, tokenId), hex'2C');

        // will revert if they do not have the item
        removeItem(tokenId, itemId);

        unchecked {
            protocolItems[itemId]++;
        }

        (Storage storage s, Memory memory m) = loadItemSwap(tokenId, itemId, address(tokenId));

        // cannot sell two of the same item at same time
        require(m.swapData == 0, hex'2D');

        uint256 updatedAgency = NuggftV1AgentType.create(0, address(tokenId), floor, NuggftV1AgentType.Flag.SWAP);
        (s.data) = updatedAgency;
        emit Sell(tokenId, bytes32(updatedAgency));
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    view
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // / @inheritdoc INuggftV1Swap
    function valueForOffer(address sender, uint160 tokenId)
        external
        view
        override
        returns (
            bool canOffer,
            uint96 nextSwapAmount,
            uint96 senderCurrentOffer
        )
    {
        canOffer = true;

        (, Memory memory m) = loadTokenSwap(tokenId, sender);

        if (m.swapData == 0) {
            if (m.activeEpoch == tokenId) {
                // swap is minting
                nextSwapAmount = NuggftV1AgentType.compressEthRoundUp(msp());
            } else {
                // swap does not exist
                return (false, 0, 0);
            }
        } else {
            if (m.swapData.epoch() == 0 && m.offerData == m.swapData) canOffer = false;

            senderCurrentOffer = m.offerData.eth();

            nextSwapAmount = m.swapData.eth();

            if (nextSwapAmount < eps()) {
                nextSwapAmount = eps();
            }
        }

        if (nextSwapAmount == 0) {
            nextSwapAmount = MIN_OFFER;
        } else {
            nextSwapAmount = NuggftV1AgentType.addIncrement(nextSwapAmount);

            // console.log('2', nextSwapAmount);
        }
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                internal
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // function commit(Storage storage s, Memory memory m) internal returns (uint256 updatedAgency) {
    //     require(msg.value >= eps(), hex'25');

    //     // require(m.offerData == 0 && m.swapData.epoch() == 0, hex'03');

    //     // require(m.swapData.flag() == NuggftV1AgentType.Flag.SWAP, hex'04');

    //     // forces a user not to commit on their own swap
    //     //commented out as the logic is handled by S:R
    //     // require(!m.offerData.flag()(), 0x23);

    //     uint24 newEpoch;

    //     unchecked {
    //         newEpoch = m.activeEpoch + 1;
    //     }

    //     updatedAgency = updateSwapDataWithEpoch(m.swapData, newEpoch, m.sender, 0);

    //     s.offers[m.swapData.account()] = m.swapData.epoch(newEpoch);
    // }

    // function carry(Storage storage s, Memory memory m) internal returns (uint256 updatedAgency) {
    //     // make sure swap is still active
    //     require(m.activeEpoch <= m.swapData.epoch(), hex'2F');

    //     if (m.swapData.account() != m.sender) s.offers[m.swapData.account()] = m.swapData;

    //     updatedAgency = updateSwapDataWithEpoch(
    //         m.swapData, //
    //         m.swapData.epoch(),
    //         m.sender,
    //         m.offerData.eth()
    //     );
    // }

    // @scenario - leader claims in the middle of a swap

    function checkClaimerIsWinnerOrLoser(Memory memory m) internal pure returns (bool winner) {
        require(m.offerData != 0, hex'2E');

        bool isLeader = uint160(m.offerData) == uint160(m.swapData);

        if (isLeader) {
            bool isOver = m.activeEpoch > m.swapData.epoch();
            bool isOwner = m.swapData.epoch() == 0 && m.offerData == m.swapData;

            require(isOver || isOwner, hex'67');

            return true;
        }

        // return isLeader && (isOwner || isOver);
    }

    // // @test  unit
    // function updateSwapDataWithEpoch(
    //     uint256 prevSwapData,
    //     uint256 _epoch,
    //     address account,
    //     uint256 currUserOffer
    // ) internal returns (uint256 res) {
    //     uint96 baseEth = prevSwapData.eth();

    //     assembly {
    //         currUserOffer := add(currUserOffer, callvalue())
    //         // let inc := div(mul(baseEth, 10200), 10000)
    //         if gt(div(mul(baseEth, 10200), 10000), currUserOffer) {
    //             mstore(0x00, 0x26)
    //             revert(0x19, 0x01)
    //         }

    //         res := or(account, or(shl(160, div(currUserOffer, 1000000000)), or(shl(230, _epoch), shl(254, 0x1))))

    //         baseEth := sub(currUserOffer, baseEth)
    //     }

    //     addStakedEth(baseEth);
    // }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TOKEN SWAP
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function loadTokenSwap(uint160 tokenId, address account) internal view returns (Storage storage s, Memory memory m) {
        s = swaps[tokenId].self;
        m = _load(agency[tokenId], s, account);
    }

    function loadItemSwap(
        uint160 tokenId,
        uint16 itemId,
        address account
    ) internal view returns (Storage storage s, Memory memory m) {
        s = swaps[tokenId].items[itemId];
        m = _load(s.data, s, account);
    }

    function _load(
        uint256 cache,
        Storage storage ptr,
        address account
    ) private view returns (Memory memory m) {
        // uint256 cache = ptr.data;
        m.swapData = cache;
        m.activeEpoch = epoch();
        m.sender = account;

        if (account == cache.account()) {
            m.offerData = cache;
        } else {
            m.offerData = ptr.offers[account];
        }
    }

    function encodeSellingItemId(uint160 tokenId, uint16 itemId) internal pure returns (uint176) {
        return (uint176(itemId) << 160) | tokenId;
    }
}

//  assembly {
//                 let ptr := mload(0x40)
//                 // Store num in memory scratch space (note: lookup "free memory pointer" if you need to allocate space)
//                 mstore(ptr, tokenId)
//                 // Store slot number in scratch space after num
//                 mstore(add(ptr, 0x20), agency.slot)
//                 // Create hash from previously stored num and slot
//                 let hash := keccak256(0, 64)
//                 // Load mapping value using the just calculated hash
//                 cache := sload(hash)
//             }
//         } else {
