pragma solidity 0.8.4;

import '../erc721/IERC721.sol';
import '../erc1155/IERC1155.sol';

import '../erc2981/IERC2981.sol';
import './ShiftLib.sol';
import './Address.sol';
import './QuadMath.sol';
import './StorageLib.sol';
import 'hardhat/console.sol';

library SwapLib {
    using Address for address;
    using ShiftLib for uint256;

    struct Storage {
        uint256 index;
        uint256 data;
        mapping(address => uint256) offers;
    }

    struct Default {
        Storage d;
    }

    function loadStorage(
        address token,
        uint256 tokenid,
        address account,
        uint256 index
    )
        internal
        view
        returns (
            Storage storage s,
            uint256 swapData,
            uint256 offerData
        )
    {
        uint256 ptr = StorageLib.pointer(uint160(token), tokenid, index);

        assembly {
            s.slot := ptr
        }

        swapData = s.data;

        offerData = account != swapData.addr() ? s.offers[account] : swapData;
    }

    function incrementIndex(
        address token,
        uint256 tokenid,
        uint256 curr
    ) internal {
        uint256 ptr = StorageLib.pointer(uint160(token), tokenid, curr + 1);

        Storage storage s;
        assembly {
            s.slot := ptr
        }
        console.log('s.index', s.index);
        uint256 tmp = s.index + 1;
        uint256 ptr2 = StorageLib.pointer(uint160(token), tokenid, tmp);

        assembly {
            sstore(s.slot, ptr2)
        }

        console.log('s.index', s.index);
    }

    function loadStorage(
        address token,
        uint256 tokenid,
        address account
    )
        internal
        returns (
            Storage storage s,
            uint256 swapData,
            uint256 offerData,
            uint256 index
        )
    {
        uint256 ptr = StorageLib.pointer(uint160(token), tokenid);

        assembly {
            s.slot := ptr
        }

        index = s.index;
        swapData = s.data;

        if (index == 0 && swapData == 0) {
            ptr = StorageLib.pointer(uint160(token), tokenid, 0);

            assembly {
                sstore(s.slot, ptr)
            }
        }

        offerData = (account == swapData.addr()) ? swapData : s.offers[account];
    }

    function checkClaimer(
        address account,
        uint256 swapData,
        uint256 offerData,
        uint256 activeEpoch
    ) internal pure returns (bool winner) {
        require(offerData != 0, 'SL:CC:1');

        bool over = activeEpoch > swapData.epoch();

        return swapData.isOwner() || (account == swapData.addr() && over);
    }

    function points(uint256 total, uint256 bps) internal pure returns (uint256 res) {
        res = QuadMath.mulDiv(total, bps, 10000);
    }

    function pointsWith(uint256 total, uint256 bps) internal pure returns (uint256 res) {
        res = points(total, bps) + total;
    }

    function moveERC721(
        address token,
        uint256 tokenid,
        address from,
        address to
    ) internal {
        require(IERC721(token).ownerOf(tokenid) == from, 'AUC:TT:1');

        IERC721(token).safeTransferFrom(from, to, tokenid);

        require(IERC721(token).ownerOf(tokenid) == to, 'AUC:TT:3');
    }
}
