pragma solidity 0.8.4;

import '../ercs/erc721/IERC721.sol';
import '../ercs/erc1155/IERC1155.sol';

import '../ercs/erc2981/IERC2981.sol';
import '../libraries/ShiftLib.sol';
import '../libraries/Address.sol';
import '../libraries/QuadMath.sol';
import '../libraries/StorageLib.sol';

library SwapStorage {
    using Address for address;
    using ShiftLib for uint256;

    struct Storage {
        uint256 info;
        uint256 data;
        mapping(address => uint256) offers;
    }

    function load(
        address token,
        uint256 tokenid,
        address user
    )
        internal
        view
        returns (
            Storage storage s,
            uint256 swapData,
            uint256 offerData
        )
    {
        uint256 ptr = StorageLib.pointer(uint160(token), tokenid);

        return loadPtr(ptr, user);
    }

    function load(
        address token,
        uint256 tokenid,
        address user,
        uint256 i
    )
        internal
        view
        returns (
            Storage storage s,
            uint256 swapData,
            uint256 offerData
        )
    {
        uint256 ptr = StorageLib.pointer(uint160(token), tokenid, i);

        return loadPtr(ptr, user);
    }

    function loadPtr(uint256 ptr, address user)
        internal
        view
        returns (
            Storage storage s,
            uint256 swapData,
            uint256 offerData
        )
    {
        assembly {
            s.slot := ptr
        }

        swapData = s.data;
        if (swapData == 0) return (s, 0, 0);
        if (user != account(swapData)) offerData = s.offers[user];
        else offerData = swapData;
    }

    function incrementPointer(address token, uint256 tokenid) internal {
        Storage storage s;

        uint256 defaultPtr = StorageLib.pointer(uint160(token), tokenid);

        assembly {
            s.slot := defaultPtr
        }

        uint256 info = index(s.info) + 1;

        uint256 ptr2 = StorageLib.pointer(uint160(token), tokenid, info);

        assembly {
            sstore(s.slot, ptr2)
        }

        s.info = info;
    }

    function is1155(uint256 input) internal pure returns (bool res) {
        res = input.getBool(252);
    }

    function is1155(uint256 input, bool to) internal pure returns (uint256 res) {
        res = input.setBool(252, to);
    }

    function isClaimed(uint256 input) internal pure returns (bool res) {
        res = input.getBool(253);
    }

    function isClaimed(uint256 input, bool to) internal pure returns (uint256 res) {
        res = input.setBool(253, to);
    }

    function isTraditional(uint256 input) internal pure returns (bool res) {
        res = input.getBool(254);
    }

    function isTraditional(uint256 input, bool to) internal pure returns (uint256 res) {
        res = input.setBool(254, to);
    }

    function isOwner(uint256 input) internal pure returns (bool res) {
        res = input.getBool(255);
    }

    function isOwner(uint256 input, bool to) internal pure returns (uint256 res) {
        res = input.setBool(255, to);
    }

    function endedByOwner(uint256 input) internal pure returns (bool res) {
        res = isOwner(input) && isClaimed(input);
    }

    function eth(uint256 input) internal pure returns (uint256 res) {
        res = input.getCint(160, 48, 0xE8D4A51000);
    }

    function eth(uint256 input, uint256 update) internal pure returns (uint256 res, uint256 rem) {
        (res, rem) = input.setCint(160, 48, 0xE8D4A51000, update);
    }

    function epoch(uint256 input) internal pure returns (uint256 res) {
        res = input.getUint(208, 40);
    }

    function epoch(uint256 input, uint256 update) internal pure returns (uint256 res) {
        res = input.setUint(208, 40, update);
    }

    function account(uint256 input, address update) internal pure returns (uint256 res) {
        res = input.setAddress(0, update);
    }

    function account(uint256 input) internal pure returns (address res) {
        res = input.getAddress(0);
    }

    function index(uint256 input) internal pure returns (uint256 res) {
        res = input.getUint(0, 160);
    }

    function index(uint256 input, uint256 update) internal pure returns (uint256 res) {
        res = input.setUint(0, 160, update);
    }
}
