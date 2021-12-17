// SPDX-License-Identifier: MIT

import {Global} from '../global/GlobalStorage.sol';

import {Swap} from './SwapStorage.sol';
import {SwapPure} from './SwapPure.sol';

library SwapView {
    using SwapPure for uint256;

    function getActiveSwap(uint256 tokenId)
        internal
        view
        returns (
            address leader,
            uint256 amount,
            uint256 _epoch,
            bool isOwner
        )
    {
        (, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, address(0));
        require(m.swapData != 0, 'NS:GS:0');
        leader = address(m.swapData.account());
        amount = m.swapData.eth();
        _epoch = m.swapData.epoch();
        isOwner = m.swapData.isOwner();
    }

    function getOfferByAccount(uint256 tokenId, address account) internal view returns (uint256 amount) {
        (, Swap.Memory memory m) = Swap.loadTokenSwap(tokenId, account);
        require(m.offerData != 0, 'NS:GS:0');
        amount = m.offerData.eth();
    }
}
