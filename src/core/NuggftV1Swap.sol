// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {INuggftV1Swap} from '../interfaces/nuggftv1/INuggftV1Swap.sol';

import {NuggftV1Stake} from './NuggftV1Stake.sol';

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';

import {NuggftV1AgentType} from '../types/NuggftV1AgentType.sol';

/// @notice mechanism for trading of nuggs between users (and items between nuggs)
/// @dev Explain to a developer any extra details
abstract contract NuggftV1Swap is INuggftV1Swap, NuggftV1Stake {
    using SafeCastLib for uint256;

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
        uint32 activeEpoch;
        address sender;
    }

    mapping(uint16 => uint256) protocolItems;
    mapping(uint160 => Mapping) swaps;

    uint96 public constant MIN_OFFER = 10**13 * 50;

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  delegate
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Swap
    function delegate(address sender, uint160 tokenId) external payable override {
        require(_isOperatorFor(msg.sender, sender), 'S:0');

        (Storage storage s, Memory memory m) = loadTokenSwap(tokenId, sender);

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise

        if (m.activeEpoch == tokenId && m.swapData == 0) {
            // to ensure we at least have enough to increment the offer amount by 2%
            require(msg.value >= MIN_OFFER, 'S:1');

            // we do not need this, could take tokenId out as an argument - but do not want to give users
            // the ability to accidently place an offer for nugg A and end up minting nugg B.
            assert(m.offerData == 0);

            (s.data, ) = NuggftV1AgentType.newAgentType(m.activeEpoch, m.sender, msg.value.safe96(), false);

            addStakedShareFromMsgValue();

            setProofFromEpoch(tokenId);

            emitTransferEvent(address(0), address(this), tokenId);
        } else {
            require(m.swapData != 0, 'S:4');

            if (m.offerData != 0) {
                // forces user to claim previous swap before acting on this one
                // prevents owner from COMMITTING on their own swap - not offering
                require(m.offerData.epoch() >= m.activeEpoch, 'S:R');

                require(!m.offerData.isOwner(), 'NOPE'); // always be caught by the require above
            }

            // if the leader "owns" the swap, then it was initated by them - "commit" must be executed
            m.swapData.isOwner() ? commit(s, m) : offer(s, m);
        }
    }

    /// @inheritdoc INuggftV1Swap
    function delegateItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) external payable override {
        require(_isOperatorForOwner(msg.sender, buyerTokenId), 'S:6');

        (Storage storage s, Memory memory m) = loadItemSwap(sellerTokenId, itemId, address(buyerTokenId));

        require(m.swapData != 0, 'S:S');

        if (m.offerData != 0) {
            // forces user to claim previous swap before acting on this one
            // prevents owner from COMMITTING on their own swap - not offering
            require(m.offerData.epoch() >= m.activeEpoch, 'S:7');

            require(!m.offerData.isOwner(), 'NOPE'); // always be caught by the require above
        }

        m.offerData == 0 && m.swapData.isOwner() ? commit(s, m) : offer(s, m);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  claim
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Swap
    function claim(address sender, uint160 tokenId) external override {
        require(_isOperatorFor(msg.sender, sender), 'S:8');

        (Storage storage s, Memory memory m) = loadTokenSwap(tokenId, sender);

        delete s.offers[sender];

        if (checkClaimerIsWinnerOrLoser(m)) {
            delete s.data;

            checkedTransferFromSelf(sender, tokenId);
        } else {
            SafeTransferLib.safeTransferETH(sender, m.offerData.eth());
        }
    }

    /// @inheritdoc INuggftV1Swap
    function claimItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) external override {
        require(_isOperatorForOwner(msg.sender, buyerTokenId), 'S:9');

        (Storage storage s, Memory memory m) = loadItemSwap(sellerTokenId, itemId, address(buyerTokenId));

        delete s.offers[address(buyerTokenId)];

        if (checkClaimerIsWinnerOrLoser(m)) {
            delete s.data;

            require(protocolItems[itemId] > 0, 'P:3');

            addItem(buyerTokenId, itemId);

            protocolItems[itemId]--;
        } else {
            SafeTransferLib.safeTransferETH(_ownerOf(buyerTokenId), m.offerData.eth());
        }
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  swap
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Swap
    function swap(uint160 tokenId, uint96 floor) external override {
        address sender = _ownerOf(tokenId);

        require(_isOperatorFor(msg.sender, sender), 'S:A');

        require(floor >= ethPerShare(), 'S:B');

        approvedTransferToSelf(tokenId);

        (Storage storage s, Memory memory m) = loadTokenSwap(tokenId, sender);

        // make sure swap does not exist - this logically should never happen
        require(m.swapData == 0, 'NOPE2');

        // no need to check dust as no value is being transfered
        (s.data, ) = NuggftV1AgentType.newAgentType(0, sender, floor, true);
    }

    /// @inheritdoc INuggftV1Swap
    function swapItem(
        uint160 sellerTokenId,
        uint16 itemId,
        uint96 floor
    ) external override {
        require(_isOperatorForOwner(msg.sender, sellerTokenId), 'S:C');

        // will revert if they do not have the item
        removeItem(sellerTokenId, itemId);

        protocolItems[itemId]++;

        (Storage storage s, Memory memory m) = loadItemSwap(sellerTokenId, itemId, address(sellerTokenId));

        // cannot sell two of the same item at same time
        require(m.swapData == 0, 'S:D');

        (s.data, ) = NuggftV1AgentType.newAgentType(0, address(sellerTokenId), floor, true);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                    view
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // / @inheritdoc INuggftV1Swap
    function valueForDelegate(address sender, uint160 tokenId)
        external
        view
        override
        returns (
            bool canDelegate,
            uint96 nextSwapAmount,
            uint96 senderCurrentOffer
        )
    {
        canDelegate = true;

        (, Memory memory m) = loadTokenSwap(tokenId, sender);

        if (m.swapData == 0) {
            if (m.activeEpoch == tokenId) {
                // swap is minting
                nextSwapAmount = NuggftV1AgentType.compressEthRoundUp(minSharePrice());
            } else {
                // swap does not exist
                return (false, 0, 0);
            }
        } else {
            if (m.offerData.isOwner() && m.swapData.isOwner()) canDelegate = false;

            senderCurrentOffer = m.offerData.eth();

            nextSwapAmount = m.swapData.eth();

            if (nextSwapAmount < ethPerShare()) {
                nextSwapAmount = ethPerShare();
            }
        }

        if (nextSwapAmount == 0) {
            nextSwapAmount = MIN_OFFER;
        } else {
            nextSwapAmount = NuggftV1AgentType.addIncrement(nextSwapAmount);
        }
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                internal
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function commit(Storage storage s, Memory memory m) internal returns (uint96 newAmount) {
        require(msg.value >= ethPerShare(), 'S:5');

        require(m.offerData == 0 && m.swapData != 0, 'NOPE3');

        require(m.swapData.isOwner(), 'NOPE4');

        // forces a user not to commit on their own swap
        // commented out as the logic is handled by S:R
        // require(!m.offerData.isOwner()(), 'S:3');

        (uint256 newSwapData, uint96 increment, uint96 dust) = updateSwapDataWithEpoch(m.swapData, m.activeEpoch + 1, m.sender, 0);

        s.data = newSwapData;

        s.offers[m.swapData.account()] = m.swapData.isOwner(false).epoch(m.activeEpoch + 1);

        addStakedEth(increment + dust);

        return newSwapData.eth();
    }

    function offer(Storage storage s, Memory memory m) internal returns (uint96 newAmount) {
        // make sure swap is still active
        require(m.activeEpoch <= m.swapData.epoch(), 'S:F');

        if (m.swapData.account() != m.sender) s.offers[m.swapData.account()] = m.swapData;

        (uint256 newSwapData, uint96 increment, uint96 dust) = updateSwapDataWithEpoch(
            m.swapData,
            m.swapData.epoch(),
            m.sender,
            m.offerData.eth()
        );

        s.data = newSwapData;

        addStakedEth(increment + dust);

        return newSwapData.eth();
    }

    function checkClaimerIsWinnerOrLoser(Memory memory m) internal pure returns (bool winner) {
        require(m.offerData != 0, 'S:E');

        bool isOver = m.activeEpoch > m.swapData.epoch();
        bool isLeader = m.offerData.account() == m.swapData.account();
        bool isOwner = m.swapData.isOwner() && m.offerData.isOwner();

        return isLeader && (isOwner || isOver);
    }

    // @test  unit
    function updateSwapDataWithEpoch(
        uint256 prevSwapData,
        uint32 _epoch,
        address account,
        uint96 currUserOffer
    )
        internal
        view
        returns (
            uint256 res,
            uint96 increment,
            uint96 dust
        )
    {
        uint96 baseEth = prevSwapData.eth();

        currUserOffer += msg.value.safe96();

        require(NuggftV1AgentType.addIncrement(baseEth) <= currUserOffer, 'S:G');

        (res, dust) = NuggftV1AgentType.newAgentType(_epoch, account, currUserOffer, false);

        increment = currUserOffer - baseEth;
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TOKEN SWAP
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function loadTokenSwap(uint160 tokenId, address account) internal view returns (Storage storage s, Memory memory m) {
        s = swaps[tokenId].self;
        m = _load(s, account);
    }

    function loadItemSwap(
        uint160 tokenId,
        uint16 itemId,
        address account
    ) internal view returns (Storage storage s, Memory memory m) {
        s = swaps[tokenId].items[itemId];
        m = _load(s, account);
    }

    function _load(Storage storage ptr, address account) private view returns (Memory memory m) {
        uint256 cache = ptr.data;
        m.swapData = cache;
        m.activeEpoch = epoch();
        m.sender = account;

        if (account == cache.account()) {
            m.offerData = cache;
        } else {
            m.offerData = ptr.offers[account];
        }
    }
}
