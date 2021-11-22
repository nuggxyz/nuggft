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
    using Address for address payable;
    using ShiftLib for uint256;

    struct Storage {
        mapping(uint256 => uint256) datas;
        mapping(address => mapping(uint256 => uint256)) users;
    }

    function loadStorage(
        address token,
        uint256 tokenid,
        uint256 swapnum,
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

        swapData = s.datas[swapnum];

        if (swapData == 0) return (s, 0, 0);

        if (account != swapData.addr()) offerData = s.users[account][swapnum];
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

    function checkOwner(address token) internal view returns (bool ok, address owner) {
        bytes memory returnData;
        (ok, returnData) = token.staticcall(abi.encodeWithSignature('owner()'));
        if (!ok) return (false, address(0));
        owner = abi.decode(returnData, (address));
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

        require(offerData != 0 && !offerData.isTokenClaimed(), 'SL:CC:2');
    }

    function checkRoyalties(address token, uint256 tokenid)
        internal
        view
        returns (
            bool ok,
            address res,
            uint256 bps
        )
    {
        bytes memory returnData;
        (ok, returnData) = token.staticcall(
            abi.encodeWithSignature('supportsInterface(bytes4)', type(IERC2981).interfaceId)
        );
        if (!ok) return (false, address(0), 0);

        if (!abi.decode(returnData, (bool))) return (false, address(0), 0);

        (ok, returnData) = token.staticcall(abi.encodeWithSignature('royaltyInfo(uint256,uint256)', tokenid, 10000));
        if (!ok) return (false, address(0), 0);
        (res, bps) = abi.decode(returnData, (address, uint256));
    }

    // function checkRoyalties(
    //     address token,
    //     uint256 tokenid,
    //     uint256 encodedRoyaltyData
    // ) internal view returns (uint16 res) {
    //     // (address receiver, uint256 bps) = ShiftLib.decodeRoyaltyData(encodedRoyaltyData);
    //     // if (bps > 0) return uint16(bps);
    //     if (receiver == address(0)) {
    //         // for projects that indicate no royalties
    //         try IERC165(token).supportsInterface(type(IERC2981).interfaceId) returns (bool support) {
    //             if (support) {
    //                 try IERC2981(token).royaltyInfo(tokenid, 10000) returns (address, uint256 _bps) {
    //                     return uint16(_bps);
    //                 } catch {}
    //             }
    //         } catch {}
    //     } else {}
    // }

    // function takeBPS(uint256 total, uint256 bps) internal pure returns (uint256 res) {
    //     res = QuadMath.mulDiv(total, bps < 1000 ? bps : 1000, 10000);
    // }

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
