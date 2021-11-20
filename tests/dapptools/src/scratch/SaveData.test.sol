// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTestExtended.sol';

import '../../../../contracts/src/NuggSwap.sol';
import '../../../../contracts/src/xNUGG.sol';

contract MockNuggSwap is NuggSwap {
    constructor() NuggSwap(address(new xNUGG())) {}

    struct SwapDatas {
        address token;
        uint256 tokenid;
        uint256 num;
        address leader;
        uint256 eth;
        uint256 epoch;
        uint256 activeEpoch;
        address owner;
        uint256 bps;
        bool tokenClaimed;
        bool royClaimed;
        bool is1155;
    }

    struct OfferDatas {
        bool claimed;
        address account;
        uint256 eth;
    }
}

contract SaveData is DSTestExtended {
    // IxNUGG _xnugg = ;
    MockNuggSwap mock;

    function setUp() public {
        mock = new MockNuggSwap();
    }

    function test_plain(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) public {
        // saveData(swap, offer);
        assertTrue(true);
    }
}
