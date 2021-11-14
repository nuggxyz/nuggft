// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTestExtended.sol';

import '../../../../contracts/libraries/SwapLib.sol';
import '../mocks/SwapLib.m.sol';

contract SwapLibTest is DSTestExtended {
    function test_unit_encodeAuctionData_raw_0() public {
        uint256 res = SwapLib.encodeAuctionData(msg.sender, 77, true, true);
        assertEq(res, 0x00000101000000000000004d00a329c0648769a73afac7f9381e08fb43dbea72);
    }

    function test_unit_encodeAuctionData_mock_0() public {
        uint256 res = SwapLib.encodeAuctionData(msg.sender, 77, true, true);
        uint256 mock_res = MockSwapLib.mock_encodeAuctionData(msg.sender, 77, true, true);
        assertEq(res, mock_res);
    }

    function test_unit_decodeAuctionData_raw_0() public {
        uint256 input = 0x00000101000000000000004d00a329c0648769a73afac7f9381e08fb43dbea72;
        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = SwapLib.decodeAuctionData(input);
        assertEq(leader, msg.sender);
        assertEq(epoch, 77);
        assertTrue(claimedByOwner);
        assertTrue(exists);
    }

    function test_unit_decodeAuctionData_mock_0() public {
        uint256 _unparsed = 0x00000101000000000000004d00a329c0648769a73afac7f9381e08fb43dbea72;
        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = SwapLib.decodeAuctionData(_unparsed);
        (address mock_leader, uint64 mock_epoch, bool mock_claimedByOwner, bool mock_exists) = MockSwapLib
            .mock_decodeAuctionData(_unparsed);

        assertEq(leader, mock_leader);
        assertEq(epoch, mock_epoch);
        assertTrue(claimedByOwner == mock_claimedByOwner);
        assertTrue(exists == mock_exists);
    }

    function test_intg_encodeDecodeAuctionData_raw_0() public {
        address expectedLeader = address(uint160(bytes20(hex'00a329c0648769a73afac7f9381e08fb43dbea72')));
        uint64 expectedEpoch = type(uint48).max;
        bool expectedClaimedByOwner = true;
        bool expectedExists = true;

        uint256 _unparsed = SwapLib.encodeAuctionData(
            expectedLeader,
            expectedEpoch,
            expectedClaimedByOwner,
            expectedExists
        );
        (address gotLeader, uint64 gotEpoch, bool gotClaimedByOwner, bool gotExists) = SwapLib.decodeAuctionData(
            _unparsed
        );

        assertEq(expectedLeader, gotLeader, 'leader');
        assertEq(gotEpoch, expectedEpoch, 'epoch');
        assertTrue(expectedClaimedByOwner == gotClaimedByOwner, 'claimedByOwner');
        assertTrue(expectedExists == gotExists, 'exists');
    }
}
