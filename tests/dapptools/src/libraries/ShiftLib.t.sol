// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTestExtended.sol';

import '../../../../contracts/src/libraries/ShiftLib.sol';

import '../mocks/ShiftLib.mock.sol';

contract ShiftLibTest is DSTestExtended {
    function test_unit_encodeSwapData_raw_0() public {
        uint256 res = ShiftLib.encodeSwapData(msg.sender, 77, 0, 9, true, true, true);
        assertEq(res, 0x01010109000000000000004d00a329c0648769a73afac7f9381e08fb43dbea72);
    }

    function test_unit_encodeSwapData_raw_1() public {
        uint256 res = ShiftLib.encodeSwapData(address(0), 0, 0, 0, true, false, false);
        emit log_bytes32(bytes32(res));
        assertEq(res, 0x0000010000000000000000000000000000000000000000000000000000000000);
    }

    function test_unit_encodeSwapData_raw_2() public {
        uint256 res = ShiftLib.encodeSwapData(address(0), 0, 0, 0, false, true, false);
        emit log_bytes32(bytes32(res));

        assertEq(res, 0x0001000000000000000000000000000000000000000000000000000000000000);
    }

    // function test_unit_encodeSwapData_mock_0() public {
    //     uint256 res = ShiftLib.encodeSwapData(msg.sender, 77, 6969, 12, true, true, true);
    //     uint256 mock_res = MockShiftLib.mock_encodeSwapData(msg.sender, 77, true, true);
    //     assertEq(res, mock_res);
    // }

    function test_unit_decodeSwapData_raw_0() public {
        uint256 input = 0x01010109000000000000004d00a329c0648769a73afac7f9381e08fb43dbea72;
        (
            address leader,
            uint48 epoch,
            uint16 amount,
            uint8 precision,
            bool tokenClaimed,
            bool exists,
            bool is1155
        ) = ShiftLib.decodeSwapData(input);

        assertEq(leader, msg.sender);
        assertEq(epoch, 77);
        assertEq(amount, 0);
        assertEq(precision, 9);
        assertTrue(is1155);
        assertTrue(tokenClaimed);
        assertTrue(exists);
    }

    function test_unit_decodeSwapData_raw_1() public {
        uint256 input = 0x0000010000000000000000000000000000000000000000000000000000000000;
        (
            address leader,
            uint48 epoch,
            uint16 amount,
            uint8 precision,
            bool tokenClaimed,
            bool exists,
            bool is1155
        ) = ShiftLib.decodeSwapData(input);
        assertEq(leader, address(0));
        assertEq(epoch, 0);
        assertEq(amount, 0);
        assertEq(precision, 0);
        assertTrue(!is1155);
        assertTrue(tokenClaimed);
        assertTrue(!exists);
    }

    function test_unit_decodeSwapData_raw_2() public {
        uint256 input = 0x0001000000000000000000000000000000000000000000000000000000000000;
        (
            address leader,
            uint48 epoch,
            uint16 amount,
            uint8 precision,
            bool tokenClaimed,
            bool exists,
            bool is1155
        ) = ShiftLib.decodeSwapData(input);

        emit log_named_uint('exists: ', exists ? 1 : 0);
        emit log_named_uint('tokenClaimed: ', tokenClaimed ? 1 : 0);
        emit log_named_uint('is1155: ', is1155 ? 1 : 0);

        assertEq(leader, address(0), 'leader');
        assertEq(epoch, 0, 'epoch');
        assertEq(amount, 0, 'amount');
        assertEq(precision, 0, 'precision');
        assertTrue(!is1155, 'is1155');
        assertTrue(!tokenClaimed, 'tokenClaimed');
        assertTrue(exists, 'exists');
    }

    // function test_unit_decodeSwapData_mock_0() public {
    //     uint256 _unparsed = 0x00000101000000000000004d00a329c0648769a73afac7f9381e08fb43dbea72;
    //     (
    //         address leader,
    //         uint48 epoch,
    //         uint16 amount,
    //         uint8 precision,
    //         bool tokenClaimed,
    //         bool exists,
    //         bool is1155
    //     ) = ShiftLib.decodeSwapData(_unparsed);
    //     (
    //         address mock_leader,
    //         uint48 mock_epoch,
    //         uint16 mock_amount,
    //         uint8 mock_precision,
    //         bool mock_tokenClaimed,
    //         bool mock_exists,
    //         bool mock_is1155
    //     ) = MockShiftLib.mock_decodeSwapData(_unparsed);

    //     assertEq(leader, mock_leader);
    //     assertEq(epoch, mock_epoch);
    //     assertEq(amount, mock_amount);
    //     assertEq(precision, 0);
    //     assertTrue(!is1155);
    //     assertTrue(tokenClaimed == mock_tokenClaimed);
    //     assertTrue(exists == mock_exists);
    // }

    function test_intg_encodeDecodeSwapData_raw_0() public {
        address expected_leader = address(uint160(bytes20(hex'00a329c0648769a73afac7f9381e08fb43dbea72')));
        uint48 expected_epoch = type(uint48).max;
        uint16 expected_amount = type(uint16).max;
        uint8 expected_precision = type(uint8).max;
        bool expected_tokenClaimed = true;
        bool expected_exists = true;
        bool expected_is1155 = true;

        uint256 _unparsed = ShiftLib.encodeSwapData(
            expected_leader,
            expected_epoch,
            expected_amount,
            expected_precision,
            expected_tokenClaimed,
            expected_exists,
            expected_is1155
        );
        (
            address got_leader,
            uint48 got_epoch,
            uint16 got_amount,
            uint8 got_precision,
            bool got_tokenClaimed,
            bool got_exists,
            bool got_is1155
        ) = ShiftLib.decodeSwapData(_unparsed);

        assertEq(expected_leader, got_leader, 'leader');
        assertEq(got_epoch, expected_epoch, 'epoch');
        assertEq(got_amount, expected_amount, 'amount');
        assertEq(got_precision, expected_precision, 'precision');
        assertTrue(expected_is1155 == got_is1155, 'is1155');
        assertTrue(expected_tokenClaimed == got_tokenClaimed, 'tokenClaimed');
        assertTrue(expected_exists == got_exists, 'exists');
    }

    function test_intg_encodeDecodeSwapData_raw_1() public {
        address expected_leader = address(0);
        uint48 expected_epoch = 0;
        uint16 expected_amount = 6969;
        uint8 expected_precision = 16;
        bool expected_tokenClaimed = false;
        bool expected_exists = true;
        bool expected_is1155 = true;

        uint256 _unparsed = ShiftLib.encodeSwapData(
            expected_leader,
            expected_epoch,
            expected_amount,
            expected_precision,
            expected_tokenClaimed,
            expected_exists,
            expected_is1155
        );
        (
            address got_leader,
            uint48 got_epoch,
            uint16 got_amount,
            uint8 got_precision,
            bool got_tokenClaimed,
            bool got_exists,
            bool got_is1155
        ) = ShiftLib.decodeSwapData(_unparsed);

        assertEq(expected_leader, got_leader, 'leader');
        assertEq(got_epoch, expected_epoch, 'epoch');
        assertEq(got_amount, expected_amount, 'amount');
        assertEq(got_precision, expected_precision, 'precision');
        assertTrue(expected_is1155 == got_is1155, 'is1155');
        assertTrue(expected_tokenClaimed == got_tokenClaimed, 'tokenClaimed');
        assertTrue(expected_exists == got_exists, 'exists');
    }

    function test_intg_encodeDecodeSwapData_raw_0(
        address expected_leader,
        uint48 expected_epoch,
        uint16 expected_amount,
        uint8 expected_precision,
        bool expected_tokenClaimed,
        bool expected_exists,
        bool expected_is1155
    ) public {
        uint256 _unparsed = ShiftLib.encodeSwapData(
            expected_leader,
            expected_epoch,
            expected_amount,
            expected_precision,
            expected_tokenClaimed,
            expected_exists,
            expected_is1155
        );
        (
            address got_leader,
            uint48 got_epoch,
            uint16 got_amount,
            uint8 got_precision,
            bool got_tokenClaimed,
            bool got_exists,
            bool got_is1155
        ) = ShiftLib.decodeSwapData(_unparsed);

        assertEq(expected_leader, got_leader, 'leader');
        assertEq(got_epoch, expected_epoch, 'epoch');
        assertEq(got_amount, expected_amount, 'amount');
        assertEq(got_precision, expected_precision, 'precision');
        assertTrue(expected_is1155 == got_is1155, 'is1155');
        assertTrue(expected_tokenClaimed == got_tokenClaimed, 'tokenClaimed');
        assertTrue(expected_exists == got_exists, 'exists');
    }

    // function test_unit_encodeSwapId_raw_0() public {
    //     uint256 res = ShiftLib.encodeSwapId(msg.sender, 384823748, 3434334356);
    //     assertEq(bytes32(res), bytes32(0xccb3c8940000000016eff1c400a329c0648769a73afac7f9381e08fb43dbea72));
    // }

    // function test_unit_encodeSwapId_mock_0() public {
    //     uint256 res = ShiftLib.encodeSwapId(msg.sender, 384823748, 3434334356);
    //     uint256 mock_res = MockShiftLib.mock_encodeSwapId(msg.sender, 384823748, 3434334356);
    //     assertEq(res, mock_res);
    // }

    // function test_unit_decodeSwapId_raw_0() public {
    //     uint256 input = 0xccb3c8940000000016eff1c400a329c0648769a73afac7f9381e08fb43dbea72;
    //     (address nft, uint48 tokenId, uint32 swapNum) = ShiftLib.decodeSwapId(input);

    //     assertEq(nft, msg.sender);
    //     assertEq(tokenId, 384823748);
    //     assertEq(swapNum, 3434334356);
    // }

    // function test_unit_decodeSwapId_mock_0() public {
    //     uint256 input = 0xccb3c8940000000016eff1c400a329c0648769a73afac7f9381e08fb43dbea72;
    //     (address nft, uint48 tokenId, uint32 swapNum) = ShiftLib.decodeSwapId(input);
    //     (address mock_nft, uint48 mock_tokenId, uint32 mock_swapNum) = MockShiftLib.mock_decodeSwapId(input);
    //     assertEq(nft, mock_nft);
    //     assertEq(tokenId, mock_tokenId);
    //     assertEq(swapNum, mock_swapNum);
    // }

    // function test_intg_encodeDecodeSwapId_0() public {
    //     address input_nft = msg.sender;
    //     uint48 input_tokenId = 384823748;
    //     uint32 input_swapNum = 3434334356;

    //     uint256 res = ShiftLib.encodeSwapId(msg.sender, 384823748, 3434334356);

    //     (address nft, uint48 tokenId, uint32 swapNum) = ShiftLib.decodeSwapId(res);

    //     assertEq(nft, input_nft);
    //     assertEq(tokenId, input_tokenId);
    //     assertEq(swapNum, input_swapNum);
    // }

    function test_unit_encodeOfferData_raw_0() public {
        uint256 res = ShiftLib.encodeOfferData(uint128(3434334356), true);
        assertEq(bytes32(res), bytes32(0x00000000000000000000000000000001000000000000000000000000ccb3c894));
    }

    function test_unit_encodeOfferData_mock_0() public {
        uint256 res = ShiftLib.encodeOfferData(uint128(3434334356), true);
        uint256 mock_res = MockShiftLib.mock_encodeOfferData(uint128(3434334356), true);
        assertEq(res, mock_res);
    }

    function test_unit_decodeOfferData_raw_0() public {
        uint256 input = 0x00000000000000000000000000000001000000000000000000000000ccb3c894;
        (uint128 amount, bool claimed) = ShiftLib.decodeOfferData(input);

        assertEq(amount, uint128(3434334356));
        assertTrue(claimed == true);
    }

    function test_unit_decodeOfferData_mock_0() public {
        uint256 input = 0x00000000000000000000000000000001000000000000000000000000ccb3c894;
        (uint128 amount, bool claimed) = ShiftLib.decodeOfferData(input);
        (uint128 mock_amount, bool mock_claimed) = MockShiftLib.mock_decodeOfferData(input);
        assertEq(amount, mock_amount);
        assertTrue(claimed == mock_claimed);
    }

    function test_intg_encodeDecodeOffer_0() public {
        uint128 input_amount = uint128(3434334356);
        bool input_claimed = true;

        uint256 res = ShiftLib.encodeOfferData(input_amount, input_claimed);

        (uint128 amount, bool claimed) = ShiftLib.decodeOfferData(res);

        assertEq(amount, input_amount);
        assertTrue(claimed == input_claimed);
    }
}
