// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTestExtended.sol';

import '../../../../contracts/src/libraries/ShiftLib.sol';

// import '../mocks/ShiftLib.mock.sol';

contract ShiftLibTest is DSTestExtended {
    using ShiftLib for uint256;

    // leader:          0x0DB143eDe6805F23922535Bad7Acb3e9Aa5D2F7b
    // epoch:           5555555555555 - 50D80EA58E3
    // is1155:          true
    // tokenClaimed:    true
    // royaltyClaimed:  true
    // feeClaimed:      true
    // isActive         ~false
    uint256 swap_sample0 = 0x000001010101050D80EA58E30DB143eDe6805F23922535Bad7Acb3e9Aa5D2F7b; // good
    // leader:          0x829BD824B016326A401d083B33D092293333A830
    // epoch:           6969696
    // is1155:          true
    // tokenClaimed:    false
    // royaltyClaimed:  true
    // feeClaimed:      false
    // isActive         =<6969696
    uint256 swap_sample1 = 0x0000000100010000006A5960829BD824B016326A401d083B33D092293333A830; // good
    // leader:          0xB8001C3eC9AA1985f6c747E25c28324E4A361ec1
    // epoch:           1
    // is1155:          false
    // tokenClaimed:    false
    // royaltyClaimed:  false
    // feeClaimed:      false
    // isActive         =<1
    uint256 swap_sample2 = 0x000000000000000000000001B8001C3eC9AA1985f6c747E25c28324E4A361ec1; // good
    // leader:          0x0DB143eDe6805F23922535Bad7Acb3e9Aa5D2F7b
    // epoch:           5555555555555 - 50D80EA58E3
    // is1155:          false
    // tokenClaimed:    true
    // royaltyClaimed:  false
    // feeClaimed:      true
    // isActive         ~false

    uint256 swap_sample3 = 0x000001000100050D80EA58E30DB143eDe6805F23922535Bad7Acb3e9Aa5D2F7b; // good
    // leader:          0
    // epoch:           0
    // is1155:          false
    // tokenClaimed:    false
    // royaltyClaimed:  false
    // feeClaimed:      false
    // isActive         =0
    uint256 swap_sample4 = 0x0000000000000000000000000000000000000000000000000000000000000000; // good
    // leader:          0
    // epoch:           0
    // is1155:          true
    // tokenClaimed:    true
    // royaltyClaimed:  true
    // feeClaimed:      true
    // isActive         ~false
    uint256 swap_sample5 = 0x0000111111110000000000000000000000000000000000000000000000000000; // good

    // amount:          5555555555555 - 50D80EA58E3
    // isOwner:         false
    // isClaimed:       false
    uint256 offer_sample0 = 0x0000000000000000000000000000000000000000000000000000050D80EA58E3; // good
    // amount:          5555555555555 - 50D80EA58E3
    // isOwner:         true
    // isClaimed:       true
    uint256 offer_sample1 = 0x0000000000000000000000000000010100000000000000000000050D80EA58E3; // good
    // amount:          9238472937423894 - 20D25799B3C416
    // isOwner:         true
    // isClaimed:       false
    uint256 offer_sample2 = 0x0000000000000000000000000000010000000000000000000020D25799B3C416; // good
    // amount:          9238472937423894 - 20D25799B3C416
    // isOwner:         false
    // isClaimed:       true
    uint256 offer_sample3 = 0x0000000000000000000000000000000100000000000000000020D25799B3C416; // good
    // amount:          0 - 0
    // isOwner:         false
    // isClaimed:       false
    uint256 offer_sample4 = 0x0000000000000000000000000000000000000000000000000000000000000000; // good
    // amount:          0 - 0
    // isOwner:         true
    // isClaimed:       true
    uint256 offer_sample5 = 0x0000000000000000000000000000111100000000000000000000000000000000; // good

    function test_isOwner() public {
        assertTrue(!offer_sample0.isOwner(), 'offer_sample0');
        assertTrue(offer_sample1.isOwner(), 'offer_sample1');
        assertTrue(offer_sample2.isOwner(), 'offer_sample2');
        assertTrue(!offer_sample3.isOwner(), 'offer_sample3');
        assertTrue(!offer_sample4.isOwner(), 'offer_sample4');
        assertTrue(offer_sample5.isOwner(), 'offer_sample5');
    }

    function test_isClaimed() public {
        assertTrue(!offer_sample0.isClaimed(), 'offer_sample0');
        assertTrue(offer_sample1.isClaimed(), 'offer_sample1');
        assertTrue(!offer_sample2.isClaimed(), 'offer_sample2');
        assertTrue(offer_sample3.isClaimed(), 'offer_sample3');
        assertTrue(!offer_sample4.isClaimed(), 'offer_sample4');
        assertTrue(offer_sample5.isClaimed(), 'offer_sample5');
    }

    function test_eth() public {
        assertEq(offer_sample0.eth(), 5555555555555, 'offer_sample0');
        assertEq(offer_sample1.eth(), 5555555555555, 'offer_sample1');
        assertEq(offer_sample2.eth(), 9238472937423894, 'offer_sample2');
        assertEq(offer_sample3.eth(), 9238472937423894, 'offer_sample3');
        assertEq(offer_sample4.eth(), 0, 'offer_sample4');
        assertEq(offer_sample5.eth(), 0, 'offer_sample5');
    }

    function test_epoch() public {
        assertEq(swap_sample0.epoch(), 5555555555555, 'swap_sample0');
        assertEq(swap_sample1.epoch(), 6969696, 'swap_sample1');
        assertEq(swap_sample2.epoch(), 1, 'swap_sample2');
        assertEq(swap_sample3.epoch(), 5555555555555, 'swap_sample3');
        assertEq(swap_sample4.epoch(), 0, 'swap_sample4');
        assertEq(swap_sample5.epoch(), 0, 'swap_sample5');
    }

    function test_is1155() public {
        assertTrue(swap_sample0.is1155(), 'swap_sample0');
        assertTrue(swap_sample1.is1155(), 'swap_sample1');
        assertTrue(!swap_sample2.is1155(), 'swap_sample2');
        assertTrue(!swap_sample3.is1155(), 'swap_sample3');
        assertTrue(!swap_sample4.is1155(), 'swap_sample4');
        assertTrue(swap_sample5.is1155(), 'swap_sample5');
    }

    function test_isTokenClaimed() public {
        assertTrue(swap_sample0.isTokenClaimed(), 'swap_sample0');
        assertTrue(!swap_sample1.isTokenClaimed(), 'swap_sample1');
        assertTrue(!swap_sample2.isTokenClaimed(), 'swap_sample2');
        assertTrue(swap_sample3.isTokenClaimed(), 'swap_sample3');
        assertTrue(!swap_sample4.isTokenClaimed(), 'swap_sample4');
        assertTrue(swap_sample5.isTokenClaimed(), 'swap_sample5');
    }

    function test_isRoyaltyClaimed() public {
        assertTrue(swap_sample0.isRoyaltyClaimed(), 'swap_sample0');
        assertTrue(swap_sample1.isRoyaltyClaimed(), 'swap_sample1');
        assertTrue(!swap_sample2.isRoyaltyClaimed(), 'swap_sample2');
        assertTrue(!swap_sample3.isRoyaltyClaimed(), 'swap_sample3');
        assertTrue(!swap_sample4.isRoyaltyClaimed(), 'swap_sample4');
        assertTrue(swap_sample5.isRoyaltyClaimed(), 'swap_sample5');
    }

    function test_isFeeClaimed() public {
        assertTrue(swap_sample0.isFeeClaimed(), 'swap_sample0');
        assertTrue(!swap_sample1.isFeeClaimed(), 'swap_sample1');
        assertTrue(!swap_sample2.isFeeClaimed(), 'swap_sample2');
        assertTrue(swap_sample3.isFeeClaimed(), 'swap_sample3');
        assertTrue(!swap_sample4.isFeeClaimed(), 'swap_sample4');
        assertTrue(swap_sample5.isFeeClaimed(), 'swap_sample5');
    }

    // function test_isActive() public {
    //     assertTrue(!offer_sample0.isActive(69), 'offer_sample0');
    //     assertTrue(offer_sample1.isActive(6969695), 'offer_sample1');
    //     assertTrue(!offer_sample2.isActive(2), 'offer_sample2');
    //     assertTrue(!offer_sample3.isActive(69), 'offer_sample3');
    //     assertTrue(offer_sample4.isActive(0), 'offer_sample4');
    //     assertTrue(!offer_sample5.isActive(69), 'offer_sample5');
    // }

    function test_setAccount() public {
        uint256 one = swap_sample3.setAccount(address(0));
        uint256 two = swap_sample4.setAccount(msg.sender);
        uint256 thr = swap_sample5.setAccount(address(type(uint160).max));

        assertEq(one, 0x000001000100050D80EA58E30000000000000000000000000000000000000000, 'swap_sample3');
        assertEq(two, 0x00000000000000000000000000a329c0648769a73afac7f9381e08fb43dbea72, 'swap_sample4');
        assertEq(thr, 0x000011111111000000000000ffffffffffffffffffffffffffffffffffffffff, 'swap_sample5');
    }

    function test_setEpoch() public {
        uint256 one = swap_sample3.setEpoch(777888);
        uint256 two = swap_sample4.setEpoch(0);
        uint256 thr = swap_sample5.setEpoch(type(uint48).max);

        assertEq(one, 0x0000010001000000000BDEA00DB143eDe6805F23922535Bad7Acb3e9Aa5D2F7b, 'swap_sample3');
        assertEq(two, 0x0000000000000000000000000000000000000000000000000000000000000000, 'swap_sample4');
        assertEq(thr, 0x000011111111ffffffffffff0000000000000000000000000000000000000000, 'swap_sample5');
    }

    function test_setIs1155() public {
        uint256 one = swap_sample3.setIs1155();
        uint256 two = swap_sample4.setIs1155();
        uint256 thr = swap_sample5.setIs1155();

        assertEq(one, 0x000001000101050D80EA58E30DB143eDe6805F23922535Bad7Acb3e9Aa5D2F7b, 'swap_sample3');
        assertEq(two, 0x0000000000010000000000000000000000000000000000000000000000000000, 'swap_sample4');
        assertEq(thr, 0x0000111111010000000000000000000000000000000000000000000000000000, 'swap_sample5');
    }

    function test_setTokenClaimed() public {
        uint256 one = swap_sample3.setTokenClaimed();
        uint256 two = swap_sample4.setTokenClaimed();
        uint256 thr = swap_sample5.setTokenClaimed();

        assertEq(one, 0x000001000100050D80EA58E30DB143eDe6805F23922535Bad7Acb3e9Aa5D2F7b, 'swap_sample3');
        assertEq(two, 0x0000000001000000000000000000000000000000000000000000000000000000, 'swap_sample4');
        assertEq(thr, 0x0000111101110000000000000000000000000000000000000000000000000000, 'swap_sample5');
    }

    function test_setRoyaltyClaimed() public {
        uint256 one = swap_sample3.setRoyaltyClaimed();
        uint256 two = swap_sample4.setRoyaltyClaimed();
        uint256 thr = swap_sample5.setRoyaltyClaimed();

        assertEq(one, 0x000001010100050D80EA58E30DB143eDe6805F23922535Bad7Acb3e9Aa5D2F7b, 'swap_sample3');
        assertEq(two, 0x0000000100000000000000000000000000000000000000000000000000000000, 'swap_sample4');
        assertEq(thr, 0x0000110111110000000000000000000000000000000000000000000000000000, 'swap_sample5');
    }

    function test_setFeeClaimed() public {
        uint256 one = swap_sample3.setFeeClaimed();
        uint256 two = swap_sample4.setFeeClaimed();
        uint256 thr = swap_sample5.setFeeClaimed();

        assertEq(one, 0x000001000100050D80EA58E30DB143eDe6805F23922535Bad7Acb3e9Aa5D2F7b, 'swap_sample3');
        assertEq(two, 0x0000010000000000000000000000000000000000000000000000000000000000, 'swap_sample4');
        assertEq(thr, 0x0000011111110000000000000000000000000000000000000000000000000000, 'swap_sample5');
    }

    function test_setClaimed() public {
        uint256 one = offer_sample3.setClaimed();
        uint256 two = offer_sample4.setClaimed();
        uint256 thr = offer_sample5.setClaimed();

        assertEq(one, 0x0000000000000000000000000000010100000000000000000020D25799B3C416, 'offer_sample3');
        assertEq(two, 0x0000000000000000000000000000010000000000000000000000000000000000, 'offer_sample4');
        assertEq(thr, 0x0000000000000000000000000000011100000000000000000000000000000000, 'offer_sample5');
    }

    function test_setOwner() public {
        uint256 one = offer_sample3.setOwner();
        uint256 two = offer_sample4.setOwner();
        uint256 thr = offer_sample5.setOwner();

        assertEq(one, 0x0000000000000000000000000000000100000000000000000020D25799B3C416, 'offer_sample3');
        assertEq(two, 0x0000000000000000000000000000000100000000000000000000000000000000, 'offer_sample4');
        assertEq(thr, 0x0000000000000000000000000000110100000000000000000000000000000000, 'offer_sample5');
    }

    function test_setEth() public {
        uint256 one = offer_sample3.setEth(0);
        uint256 two = offer_sample4.setEth(453453453453435434657647);
        uint256 thr = offer_sample5.setEth(3);

        assertEq(one, 0x0000000000000000000000000000000100000000000000000000000000000000, 'offer_sample3');
        assertEq(two, 0x000000000000000000000000000000000000000000006005C2CEC8896257676F, 'offer_sample4');
        assertEq(thr, 0x0000000000000000000000000000111100000000000000000000000000000003, 'offer_sample5');
    }

    // function test_setOffer() public {}
}
