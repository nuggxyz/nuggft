// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTestExtended.sol';

import '../../../../contracts/src/NuggSwap.sol';
import '../../../../contracts/src/libraries/SwapLib.sol';

import '../../../../contracts/src/xNUGG.sol';

import '../../../../contracts/mock/ERC721Ownable.mock.sol';
import '../../../../contracts/mock/ERC721.mock.sol';

contract ExternalTest is DSTestExtended {
    NuggSwap nuggswap;

    MockERC721Ownable ownable;
    MockERC721 normal;

    function setUp() public {
        nuggswap = new NuggSwap(address(new xNUGG()));
        ownable = new MockERC721Ownable();
        normal = new MockERC721();
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
}
