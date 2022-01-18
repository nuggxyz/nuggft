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
        uint24 activeEpoch;
        address sender;
    }

    mapping(uint16 => uint256) protocolItems;
    mapping(uint160 => Mapping) swaps;

    uint96 public constant MIN_OFFER = 10 gwei;

    /// scenario
    /// stress
    // -- 8000 people delegate

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  delegate
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Swap
    function delegate(uint160 tokenId) external payable override {
        // require(_isOperatorFor(msg.sender, sender), 'S:0');

        (Storage storage s, Memory memory m) = loadTokenSwap(tokenId, msg.sender);

        // make sure user is not the owner of swap
        // we do not know how much to give them when they call "claim" otherwise

        uint96 lead;

        if (m.activeEpoch == tokenId && m.swapData == 0) {
            // to ensure we at least have enough to increment the offer amount by 2%
            require(msg.value >= MIN_OFFER, 'S:1');

            // we do not need this, could take tokenId out as an argument - but do not want to give users
            // the ability to accidently place an offer for nugg A and end up minting nugg B.
            assert(m.offerData == 0);

            lead = msg.value.safe96();

            (s.data) = NuggftV1AgentType.newAgentType(m.activeEpoch, m.sender, lead, false);

            addStakedShareFromMsgValue(0);

            setProofFromEpoch(tokenId);

            emitTransferEvent(address(0), address(this), tokenId);
        } else {
            require(m.swapData != 0, 'S:4');

            if (m.offerData != 0) {
                // forces user to claim previous swap before acting on this one
                // prevents owner from COMMITTING on their own swap - not offering
                require(m.offerData.epoch() >= m.activeEpoch, 'S:R');

                require(!m.offerData.flag(), 'NOPE'); // always be caught by the require above
            }

            // if the leader "owns" the swap, then it was initated by them - "commit" must be executed
            (lead) = m.swapData.flag() ? commit(s, m) : offer(s, m);
        }

        emit Delegate(tokenId, msg.sender, lead);
    }

    /// @inheritdoc INuggftV1Swap
    function delegateItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) external payable override {
        require(_ownerOf(buyerTokenId) == msg.sender, 'S:6');

        (Storage storage s, Memory memory m) = loadItemSwap(sellerTokenId, itemId, address(buyerTokenId));

        require(m.swapData != 0, 'S:S');

        if (m.offerData != 0) {
            // forces user to claim previous swap before acting on this one
            // prevents owner from COMMITTING on their own swap - not offering
            require(m.offerData.epoch() >= m.activeEpoch, 'S:7');

            require(!m.offerData.flag(), 'NOPE'); // always be caught by the require above
        }

        uint96 lead = m.offerData == 0 && m.swapData.flag() ? commit(s, m) : offer(s, m);

        emit DelegateItem(encodeSellingItemId(sellerTokenId, itemId), buyerTokenId, lead);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  claim
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Swap
    function multiclaim(uint160[] calldata tokenIds) external override {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            claim(tokenIds[i]);
        }
    }

    /// @inheritdoc INuggftV1Swap
    function multiclaimItem(
        uint160[] calldata buyerTokenIds,
        uint160[] calldata sellerTokenIds,
        uint16[] calldata itemIds
    ) external override {
        require(itemIds.length == sellerTokenIds.length && itemIds.length == buyerTokenIds.length, 'S:Y');

        for (uint256 i = 0; i < itemIds.length; i++) {
            claimItem(buyerTokenIds[i], sellerTokenIds[i], itemIds[i]);
        }
    }

    /// @inheritdoc INuggftV1Swap
    function claim(uint160 tokenId) public override {
        // require(_isOperatorFor(msg.sender, sender), 'S:8');

        (Storage storage s, Memory memory m) = loadTokenSwap(tokenId, msg.sender);

        delete s.offers[msg.sender];

        if (checkClaimerIsWinnerOrLoser(m)) {
            delete s.data;

            checkedTransferFromSelf(msg.sender, tokenId);
        } else {
            SafeTransferLib.safeTransferETH(msg.sender, m.offerData.eth());
        }

        emit Claim(tokenId, msg.sender);
    }

    /// @inheritdoc INuggftV1Swap
    function claimItem(
        uint160 buyerTokenId,
        uint160 sellerTokenId,
        uint16 itemId
    ) public override {
        require(_ownerOf(buyerTokenId) == msg.sender, 'S:9');

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

        emit ClaimItem(encodeSellingItemId(sellerTokenId, itemId), buyerTokenId);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  swap
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    /// @inheritdoc INuggftV1Swap
    function swap(uint160 tokenId, uint96 floor) external override {
        require(_ownerOf(tokenId) == msg.sender, 'S:A');

        require(floor >= eps(), 'S:B');

        approvedTransferToSelf(tokenId);

        (Storage storage s, Memory memory m) = loadTokenSwap(tokenId, msg.sender);

        // make sure swap does not exist - this logically should never happen
        require(m.swapData == 0, 'NOPE2');

        // no need to check dust as no value is being transfered
        (s.data) = NuggftV1AgentType.newAgentType(0, msg.sender, floor, true);

        emit Swap(tokenId, floor);
    }

    /// @inheritdoc INuggftV1Swap
    function swapItem(
        uint160 tokenId,
        uint16 itemId,
        uint96 floor
    ) external override {
        require(_ownerOf(tokenId) == msg.sender, 'S:C');

        // will revert if they do not have the item
        removeItem(tokenId, itemId);

        protocolItems[itemId]++;

        (Storage storage s, Memory memory m) = loadItemSwap(tokenId, itemId, address(tokenId));

        // cannot sell two of the same item at same time
        require(m.swapData == 0, 'S:D');

        (s.data) = NuggftV1AgentType.newAgentType(0, address(tokenId), floor, true);

        emit Swap(tokenId, floor);
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
                nextSwapAmount = NuggftV1AgentType.compressEthRoundUp(msp());
            } else {
                // swap does not exist
                return (false, 0, 0);
            }
        } else {
            if (m.offerData.flag() && m.swapData.flag()) canDelegate = false;

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
        }
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                internal
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function commit(Storage storage s, Memory memory m) internal returns (uint96 lead) {
        require(msg.value >= eps(), 'S:5');

        require(m.offerData == 0 && m.swapData != 0, 'NOPE3');

        require(m.swapData.flag(), 'NOPE4');

        // forces a user not to commit on their own swap
        // commented out as the logic is handled by S:R
        // require(!m.offerData.flag()(), 'S:3');

        (uint256 newSwapData, uint96 increment) = updateSwapDataWithEpoch(m.swapData, m.activeEpoch + 1, m.sender, 0);

        s.data = newSwapData;

        s.offers[m.swapData.account()] = m.swapData.flag(false).epoch(m.activeEpoch + 1);

        lead = newSwapData.eth();
        addStakedEth(increment);
    }

    function offer(Storage storage s, Memory memory m) internal returns (uint96 lead) {
        // make sure swap is still active
        require(m.activeEpoch <= m.swapData.epoch(), 'S:F');

        if (m.swapData.account() != m.sender) s.offers[m.swapData.account()] = m.swapData;

        (uint256 newSwapData, uint96 increment) = updateSwapDataWithEpoch(m.swapData, m.swapData.epoch(), m.sender, m.offerData.eth());

        s.data = newSwapData;

        lead = newSwapData.eth();
        addStakedEth(increment);
    }

    function checkClaimerIsWinnerOrLoser(Memory memory m) internal pure returns (bool winner) {
        require(m.offerData != 0, 'S:E');

        bool isOver = m.activeEpoch > m.swapData.epoch();
        bool isLeader = m.offerData.account() == m.swapData.account();
        bool flag = m.swapData.flag() && m.offerData.flag();

        return isLeader && (flag || isOver);
    }

    // @test  unit
    function updateSwapDataWithEpoch(
        uint256 prevSwapData,
        uint24 _epoch,
        address account,
        uint96 currUserOffer
    ) internal view returns (uint256 res, uint96 increment) {
        uint96 baseEth = prevSwapData.eth();

        currUserOffer += msg.value.safe96();

        require(NuggftV1AgentType.addIncrement(baseEth) <= currUserOffer, 'S:G');

        (res) = NuggftV1AgentType.newAgentType(_epoch, account, currUserOffer, false);

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

    function encodeSellingItemId(uint160 tokenId, uint16 itemId) internal pure returns (uint176) {
        return (uint176(itemId) << 160) | tokenId;
    }
}
