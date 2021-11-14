// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTestExtended.sol';

import '../../../../contracts/libraries/SwapLib.sol';

contract SwapLibTest is DSTestExtended {
    function test_unit_encodeAuctionData_0() public {
        uint256 _unparsed = SwapLib.encodeAuctionData(msg.sender, 77, true, true);
        emit log_named_bytes32('_unparsed', bytes32(_unparsed));
        assertEq(_unparsed, 0x00000101000000000000004d00a329c0648769a73afac7f9381e08fb43dbea72);
    }

    function test_unit_decodeAuctionData_0() public {
        uint256 _unparsed = 0x00000101000000000000004d00a329c0648769a73afac7f9381e08fb43dbea72;
        (address leader, uint64 epoch, bool claimedByOwner, bool exists) = SwapLib.decodeAuctionData(_unparsed);
        assertEq(leader, msg.sender);
        assertEq(epoch, 77);
        assertTrue(claimedByOwner);
        assertTrue(exists);
    }

    function test_intg_encodeDecodeAuctionData_0() public {
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

        assertTrue(expectedClaimedByOwner ? gotClaimedByOwner : !gotClaimedByOwner, 'claimedByOwner');
        assertTrue(expectedExists ? gotExists : !gotExists, 'exists');
    }
}
