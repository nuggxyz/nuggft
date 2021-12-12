// // SPDX-License-Identifier: GPL-3.0-or-later
// pragma solidity ^0.8.4;

// import '../../lib/DSTestExtended.sol';

// import '../../../../contracts/src/NuggSwap.sol';
// import '../../../../contracts/src/xNUGG.sol';

// contract DeffNotReserved is DSTestExtended, NuggSwap {
//     // IxNUGG _xnugg = ;
//     // MockNuggSwap mock;

//     struct Swapper {
//         uint256[] datas;
//         mapping(address => uint256) users;
//     }

//     constructor() NuggSwap(address(new xNUGG())) {}

//     function setUp() public {
//         // mock = new MockNuggSwap();
//         Swapper storage s = dataPtr(address(2222), 3333);
//         s.datas.push(323232);
//         s.users[address(77)] = 42;
//         s.datas.push(323232);
//     }

//     // function test_plain(SwapLib.SwapData memory swap, SwapLib.OfferData memory offer) public {
//     //     ShiftLib.encodeSwapData(swap.leader, swap.epoch, swap.bps, swap.is1155, swap.tokenClaimed, swap.royClaimed);
//     //     assertTrue(true);
//     // }

//     // function test_plains() public {
//     //     SwapLib.SwapData memory swap;
//     //     SwapLib.OfferData memory offer;

//     //     saveData(swap, offer);
//     //     assertTrue(true);
//     // }

//     // function test_encodeSwapData() public {
//     //     SwapLib.SwapData memory swap;
//     //     SwapLib.OfferData memory offer;

//     //     ShiftLib.encodeSwapData(swap.leader, swap.epoch, swap.bps, swap.is1155, swap.tokenClaimed, swap.royClaimed);
//     // }

//     // function test_encodeSwapData_ass() public {
//     //     address leader;
//     //     uint48 epoch;
//     //     uint16 bps;
//     //     bool is1155;
//     //     bool tokenClaimed;
//     //     bool royClaimed;
//     //     uint256 res;
//     //     assembly {

//     //         res := royClaimed

//     //         res := or(shl(8, res), tokenClaimed)

//     //         res := or(shl(8, res), is1155)

//     //         res := or(shl(16, res), bps)

//     //         res := or(shl(48, res), epoch)

//     //         res := or(shl(160, res), leader)
//     //     }
//     // }

//     // function test_loadData() public {
//     //     address token;
//     //     uint256 tokenid;
//     //     address account;
//     //     loadData(token, tokenid, account);
//     // }

//     // function test_loadData2() public {
//     //     address token;
//     //     uint256 tokenid;
//     //     address account;
//     //     loadData2(token, tokenid, account);
//     // }

//     // function test_loadData_none() public {
//     //     address token;
//     //     uint256 tokenid;
//     //     address account;
//     //     uint256 swapnum = _swapOwners[token][tokenid].length;
//     //     uint256 swapData = _encodedSwapData[token][tokenid][swapnum];
//     //     uint256 offerData = _encodedOfferData[token][tokenid][swapnum][account];
//     //     uint256 leaderData = _encodedOfferData[token][tokenid][swapnum][address(uint160(swapData))];
//     // }

//     function dataPtr(address token, uint256 tokenid) internal returns (Swapper storage s) {
//         assembly {
//             s.slot := keccak256(token, tokenid)
//         }
//     }

//     function diamondFunc(
//         address token,
//         uint256 tokenid,
//         address account
//     )
//         internal
//         returns (
//             uint256 swapnum,
//             uint256 swapData,
//             uint256 offerData,
//             uint256 leaderData
//         )
//     {
//         // ms_slot = keccak256("com.mycompany.my.storage")

//         Swapper storage s;

//         assembly {
//             s.slot := keccak256(token, tokenid)
//             swapnum := sload(s.slot)
//         }

//         swapData = s.datas[swapnum - 1];

//         offerData = s.users[account];
//         leaderData = s.users[address(uint160(swapData))];
//     }

//     function test_loadData_diamond_func() public {
//         address token = address(2222);
//         uint256 tokenid = 3333;
//         address account = address(77);
//         (uint256 swapnum, uint256 swapData, uint256 offerData, uint256 leaderData) = diamondFunc(
//             token,
//             tokenid,
//             account
//         );
//         assertEq(offerData, 42);

//         assertEq(swapData, 323232);
//     }

//     function test_loadData_diamond() public {
//         address token = address(2222);
//         uint256 tokenid = 3333;
//         address account = address(77);
//         Swapper storage s;
//         uint256 swapnum;
//         // uint256 swapData;
//         // uint256 offerData;
//         assembly {
//             s.slot := keccak256(token, tokenid)
//             swapnum := sload(s.slot)
//             // offerData := keccak256(swapnum, account)
//             // s.offset := 1
//             // let swapdataslot := add(s.slot, mul(0x20, 2))
//             // // swapData := sload(add(s.slot, sub(swapnum, 1)))
//             // // swapData := sload(shr(s.slot, mul(swapnum, 0x20)))
//             // swapData := sload(swapdataslot)
//         }
//         // assertEq(swapnum, 2);

//         // = myStorage(token, tokenid);
//         uint256 swapData = s.datas[swapnum - 1];

//         uint256 offerData = s.users[account];
//         uint256 leaderData = s.users[address(uint160(swapData))];
//         assertEq(offerData, 42);

//         assertEq(swapData, 323232);
//     }
// }

// // swap - need to know

// // offer - need to know
// // swap.epoch
// //

// // claim
