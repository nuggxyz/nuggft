// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTestExtended.sol';

import '../../../../contracts/src/libraries/ShiftLib.sol';

import '../mocks/ShiftLib.mock.sol';

contract ShiftLibTest is DSTestExtended {
    function test_unit_encodeSwapData_raw_0() public {
        uint256 res = ShiftLib.encodeSwapData(msg.sender, 77, true, true);
        assertEq(res, 0x00000101000000000000004d00a329c0648769a73afac7f9381e08fb43dbea72);
    }

    function test_unit_encodeSwapData_raw_1() public {
        uint256 res = ShiftLib.encodeSwapData(address(0), 0, true, false);
        emit log_bytes32(bytes32(res));
        assertEq(res, 0x0000000100000000000000000000000000000000000000000000000000000000);
    }

    function test_unit_encodeSwapData_raw_2() public {
        uint256 res = ShiftLib.encodeSwapData(address(0), 0, false, true);
        emit log_bytes32(bytes32(res));

        assertEq(res, 0x0000010000000000000000000000000000000000000000000000000000000000);
    }

    function test_unit_encodeSwapData_mock_0() public {
        uint256 res = ShiftLib.encodeSwapData(msg.sender, 77, true, true);
        uint256 mock_res = MockShiftLib.mock_encodeSwapData(msg.sender, 77, true, true);
        assertEq(res, mock_res);
    }

    function test_unit_decodeSwapData_raw_0() public {
        uint256 input = 0x00000101000000000000004d00a329c0648769a73afac7f9381e08fb43dbea72;
        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = ShiftLib.decodeSwapData(input);
        assertEq(leader, msg.sender);
        assertEq(epoch, 77);
        assertTrue(claimedByOwner);
        assertTrue(exists);
    }

    function test_unit_decodeSwapData_raw_1() public {
        uint256 input = 0x0000000100000000000000000000000000000000000000000000000000000000;
        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = ShiftLib.decodeSwapData(input);
        assertEq(leader, address(0));
        assertEq(epoch, 0);
        assertTrue(claimedByOwner);
        assertTrue(!exists);
    }

    function test_unit_decodeSwapData_raw_2() public {
        uint256 input = 0x0000010000000000000000000000000000000000000000000000000000000000;
        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = ShiftLib.decodeSwapData(input);
        assertEq(leader, address(0));
        assertEq(epoch, 0);
        assertTrue(!claimedByOwner);
        assertTrue(exists);
    }

    function test_unit_decodeSwapData_mock_0() public {
        uint256 _unparsed = 0x00000101000000000000004d00a329c0648769a73afac7f9381e08fb43dbea72;
        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = ShiftLib.decodeSwapData(_unparsed);
        (address mock_leader, uint64 mock_epoch, bool mock_claimedByOwner, bool mock_exists) = MockShiftLib
            .mock_decodeSwapData(_unparsed);

        assertEq(leader, mock_leader);
        assertEq(epoch, mock_epoch);
        assertTrue(claimedByOwner == mock_claimedByOwner);
        assertTrue(exists == mock_exists);
    }

    function test_intg_encodeDecodeSwapData_raw_0() public {
        address expectedLeader = address(uint160(bytes20(hex'00a329c0648769a73afac7f9381e08fb43dbea72')));
        uint64 expectedEpoch = type(uint48).max;
        bool expectedClaimedByOwner = true;
        bool expectedExists = true;

        uint256 _unparsed = ShiftLib.encodeSwapData(
            expectedLeader,
            expectedEpoch,
            expectedClaimedByOwner,
            expectedExists
        );
        (address gotLeader, uint64 gotEpoch, bool gotClaimedByOwner, bool gotExists) = ShiftLib.decodeSwapData(
            _unparsed
        );

        assertEq(expectedLeader, gotLeader, 'leader');
        assertEq(gotEpoch, expectedEpoch, 'epoch');
        assertTrue(expectedClaimedByOwner == gotClaimedByOwner, 'claimedByOwner');
        assertTrue(expectedExists == gotExists, 'exists');
    }

    function test_intg_encodeDecodeSwapData_raw_1() public {
        address expectedLeader = address(0);
        uint64 expectedEpoch = 0;
        bool expectedClaimedByOwner = false;
        bool expectedExists = true;

        uint256 _unparsed = ShiftLib.encodeSwapData(
            expectedLeader,
            expectedEpoch,
            expectedClaimedByOwner,
            expectedExists
        );
        (address gotLeader, uint64 gotEpoch, bool gotClaimedByOwner, bool gotExists) = ShiftLib.decodeSwapData(
            _unparsed
        );

        assertEq(expectedLeader, gotLeader, 'leader');
        assertEq(gotEpoch, expectedEpoch, 'epoch');
        assertTrue(expectedClaimedByOwner == gotClaimedByOwner, 'claimedByOwner');
        assertTrue(expectedExists == gotExists, 'exists');
    }

    function test_intg_encodeDecodeSwapData_raw_0(
        address leader,
        uint64 epoch,
        bool claimedByOwner,
        bool exists
    ) public {
        uint256 _unparsed = ShiftLib.encodeSwapData(leader, epoch, claimedByOwner, exists);
        (address gotLeader, uint64 gotEpoch, bool gotClaimedByOwner, bool gotExists) = ShiftLib.decodeSwapData(
            _unparsed
        );

        assertEq(leader, gotLeader);
        assertEq(gotEpoch, epoch);
        assertTrue(claimedByOwner == gotClaimedByOwner);
        assertTrue(exists == gotExists);
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
    //     (address nft, uint64 tokenId, uint32 swapNum) = ShiftLib.decodeSwapId(input);

    //     assertEq(nft, msg.sender);
    //     assertEq(tokenId, 384823748);
    //     assertEq(swapNum, 3434334356);
    // }

    // function test_unit_decodeSwapId_mock_0() public {
    //     uint256 input = 0xccb3c8940000000016eff1c400a329c0648769a73afac7f9381e08fb43dbea72;
    //     (address nft, uint64 tokenId, uint32 swapNum) = ShiftLib.decodeSwapId(input);
    //     (address mock_nft, uint64 mock_tokenId, uint32 mock_swapNum) = MockShiftLib.mock_decodeSwapId(input);
    //     assertEq(nft, mock_nft);
    //     assertEq(tokenId, mock_tokenId);
    //     assertEq(swapNum, mock_swapNum);
    // }

    // function test_intg_encodeDecodeSwapId_0() public {
    //     address input_nft = msg.sender;
    //     uint64 input_tokenId = 384823748;
    //     uint32 input_swapNum = 3434334356;

    //     uint256 res = ShiftLib.encodeSwapId(msg.sender, 384823748, 3434334356);

    //     (address nft, uint64 tokenId, uint32 swapNum) = ShiftLib.decodeSwapId(res);

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
