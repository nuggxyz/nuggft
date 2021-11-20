// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTestExtended.sol';

import '../../../../contracts/src/NuggSwap.sol';
import '../../../../contracts/src/libraries/SwapLib.sol';

import '../../../../contracts/src/xNUGG.sol';

import '../../../../contracts/mock/ERC721Ownable.mock.sol';
import '../../../../contracts/mock/ERC721.mock.sol';

contract MockNuggSwapTest is NuggSwap {
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

    // function testSaveData(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) public {
    //     saveData(swap, offer);
    // }
}

contract ExternalTest is DSTestExtended {
    NuggSwap nuggswap;
    MockNuggSwapTest mock_nuggswap;

    MockERC721Ownable ownable;
    MockERC721 normal;

    function setUp() public {
        nuggswap = new NuggSwap(address(new xNUGG()));
        ownable = new MockERC721Ownable();
        normal = new MockERC721();
        mock_nuggswap = new MockNuggSwapTest();
    }

    function test_owner() public {
        bool res = SwapLib.checkOwner(address(ownable), address(this));

        assertTrue(res);
    }

    function test_not_owner() public {
        bool res = SwapLib.checkOwner(address(ownable), msg.sender);
        assertTrue(!res);
    }

    function test_not_implementer() public {
        bool res = SwapLib.checkOwner(address(normal), address(this));
        assertTrue(!res);
    }

    // function test_not_implementers() public {
    //     bool res = SwapLib.checkOwner(address(normal), address(this));
    //     assertTrue(!res);
    // }

    // function test_not_implementer000() public {
    //     nuggswap.submitOffer(msg.sender, 11);
    //     assertTrue(true);
    // }
}
