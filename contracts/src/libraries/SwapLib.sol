pragma solidity 0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/utils/Address.sol';

import './ShiftLib.sol';
import './QuadMath.sol';
import './StorageLib.sol';

library SwapLib {
    using Address for address;
    using ShiftLib for uint256;

    struct Storage {
        uint256 data;
        mapping(uint256 => mapping(address => uint256)) offers;
    }

    function loadStorage(
        address token,
        uint256 tokenid,
        address account
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

        assembly {
            s.slot := ptr
        }

        swapData = s.data;

        offerData = swapData == 0 || account == swapData.account() ? swapData : s.offers[swapData.epoch()][account];
    }

    function loadStorage(
        address token,
        uint256 tokenid,
        address account,
        uint256 epoch
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

        assembly {
            s.slot := ptr
        }

        swapData = s.data;

        swapData = swapData.epoch() == epoch ? swapData : 0;

        offerData = swapData != 0 && account == swapData.account() ? swapData : s.offers[epoch][account];
    }

    function checkClaimer(
        address account,
        uint256 swapData,
        uint256 offerData,
        uint256 activeEpoch
    ) internal pure returns (bool winner) {
        require(offerData != 0, 'SL:CC:1');

        bool over = activeEpoch > swapData.epoch();

        return swapData.isOwner() || (account == swapData.account() && over);
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
        // require(IERC721(token).ownerOf(tokenid) == from, 'AUC:TT:1');

        IERC721(token).safeTransferFrom(from, to, tokenid);

        require(IERC721(token).ownerOf(tokenid) == to, 'AUC:TT:3');
    }
}
