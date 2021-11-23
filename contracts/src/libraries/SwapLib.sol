pragma solidity 0.8.4;

import '../erc721/IERC721.sol';
import '../erc1155/IERC1155.sol';

import '../erc2981/IERC2981.sol';
import './ShiftLib.sol';
import './Address.sol';
import './QuadMath.sol';
import './StorageLib.sol';

library SwapLib {
    using Address for address;
    using ShiftLib for uint256;

    struct Storage {
        uint256 index;
        mapping(uint256 => uint256) datas;
        mapping(uint256 => mapping(address => uint256)) users;
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
        uint256 ptr = StorageLib.pointer(uint160(token), tokenid);

        assembly {
            s.slot := ptr
        }

        swapData = s.datas[index];

        if (swapData == 0) return (s, 0, 0);

        if (account != swapData.addr()) offerData = s.users[index][account];
        else offerData = swapData;
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
            uint256 offerData,
            uint256 index
        )
    {
        uint256 ptr = StorageLib.pointer(uint160(token), tokenid);

        assembly {
            s.slot := ptr
        }

        index = s.index;

        swapData = s.datas[index];

        if (swapData == 0) return (s, 0, 0, 0);

        if (account != swapData.addr()) offerData = s.users[index][account];
        else offerData = swapData;
    }

    function mintToken(address token, uint256 tokenid) internal view returns (bool is1155) {
        try IERC721(token).ownerOf(tokenid) returns (address addr) {
            require(addr == address(this), 'NS:MT:0');
            return (false);
        } catch {
            try IERC1155(token).balanceOf(address(this), tokenid) returns (uint256 amount) {
                require(amount > 0, 'NS:MT:1');
                return (true);
            } catch {
                require(false, 'NS:MT:0');
            }
        }
    }

    function checkClaimer(
        address account,
        uint256 swapData,
        uint256 offerData,
        uint256 activeEpoch
    ) internal pure returns (bool winner) {
        require(swapData != 0 && !offerData.isTokenClaimed(), 'SL:CC:1');

        if (swapData.isFeeClaimed() && offerData == 0) {
            return true;
        }

        bool over = activeEpoch > swapData.epoch();

        if (account == swapData.addr()) {
            require(over && !swapData.isTokenClaimed(), 'SL:CC:0');
            return true;
        }

        require(offerData != 0, 'SL:CC:2');
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

    function moveERC1155(
        address token,
        uint256 tokenid,
        address from,
        address to
    ) internal {
        uint256 toStart = IERC1155(token).balanceOf(to, tokenid);

        require(IERC1155(token).balanceOf(from, tokenid) >= 1, 'AUC:TT:1');

        IERC1155(token).safeTransferFrom(from, to, tokenid, 1, '');

        require(IERC1155(token).balanceOf(to, tokenid) - toStart == 1, 'AUC:TT:3');
    }
}
