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

    function test_unit_encodeAuctionId_raw_0() public {
        uint256 res = SwapLib.encodeAuctionId(msg.sender, 384823748, 3434334356);
        assertEq(bytes32(res), bytes32(0xccb3c8940000000016eff1c400a329c0648769a73afac7f9381e08fb43dbea72));
    }

    function test_unit_encodeAuctionId_mock_0() public {
        uint256 res = SwapLib.encodeAuctionId(msg.sender, 384823748, 3434334356);
        uint256 mock_res = MockSwapLib.mock_encodeAuctionId(msg.sender, 384823748, 3434334356);
        assertEq(res, mock_res);
    }

    function test_unit_decodeAuctionId_raw_0() public {
        uint256 input = 0xccb3c8940000000016eff1c400a329c0648769a73afac7f9381e08fb43dbea72;
        (address nft, uint64 tokenId, uint32 auctionNum) = SwapLib.decodeAuctionId(input);

        assertEq(nft, msg.sender);
        assertEq(tokenId, 384823748);
        assertEq(auctionNum, 3434334356);
    }

    function test_unit_decodeAuctionId_mock_0() public {
        uint256 input = 0xccb3c8940000000016eff1c400a329c0648769a73afac7f9381e08fb43dbea72;
        (address nft, uint64 tokenId, uint32 auctionNum) = SwapLib.decodeAuctionId(input);
        (address mock_nft, uint64 mock_tokenId, uint32 mock_auctionNum) = MockSwapLib.mock_decodeAuctionId(input);
        assertEq(nft, mock_nft);
        assertEq(tokenId, mock_tokenId);
        assertEq(auctionNum, mock_auctionNum);
    }

    function test_intg_encodeDecodeAuctionId_0() public {
        address input_nft = msg.sender;
        uint64 input_tokenId = 384823748;
        uint32 input_auctionNum = 3434334356;

        uint256 res = SwapLib.encodeAuctionId(msg.sender, 384823748, 3434334356);

        (address nft, uint64 tokenId, uint32 auctionNum) = SwapLib.decodeAuctionId(res);

        assertEq(nft, input_nft);
        assertEq(tokenId, input_tokenId);
        assertEq(auctionNum, input_auctionNum);
    }

    function test_unit_encodeBidData_raw_0() public {
        uint256 res = SwapLib.encodeBidData(uint128(3434334356), true);
        assertEq(bytes32(res), bytes32(0x00000000000000000000000000000001000000000000000000000000ccb3c894));
    }

    function test_unit_encodeBidData_mock_0() public {
        uint256 res = SwapLib.encodeBidData(uint128(3434334356), true);
        uint256 mock_res = MockSwapLib.mock_encodeBidData(uint128(3434334356), true);
        assertEq(res, mock_res);
    }

    function test_unit_decodeBidData_raw_0() public {
        uint256 input = 0x00000000000000000000000000000001000000000000000000000000ccb3c894;
        (uint128 amount, bool claimed) = SwapLib.decodeBidData(input);

        assertEq(amount, uint128(3434334356));
        assertTrue(claimed == true);
    }

    function test_unit_decodeBidData_mock_0() public {
        uint256 input = 0x00000000000000000000000000000001000000000000000000000000ccb3c894;
        (uint128 amount, bool claimed) = SwapLib.decodeBidData(input);
        (uint128 mock_amount, bool mock_claimed) = MockSwapLib.mock_decodeBidData(input);
        assertEq(amount, mock_amount);
        assertTrue(claimed == mock_claimed);
    }

    function test_intg_encodeDecodeBid_0() public {
        uint128 input_amount = uint128(3434334356);
        bool input_claimed = true;

        uint256 res = SwapLib.encodeBidData(input_amount, input_claimed);

        (uint128 amount, bool claimed) = SwapLib.decodeBidData(res);

        assertEq(amount, input_amount);
        assertTrue(claimed == input_claimed);
    }
}
