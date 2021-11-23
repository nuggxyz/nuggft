pragma solidity 0.8.4;

import '../erc721/IERC721.sol';
import '../erc1155/IERC1155.sol';

import '../erc2981/IERC2981.sol';
import './ShiftLib.sol';
import './Address.sol';
import './QuadMath.sol';
import './StorageLib.sol';

library RoyaltyLib {
    using Address for address;
    using Address for address payable;
    using ShiftLib for uint256;

    struct Storage {
        uint256 fees;
        mapping(address => uint256) royalties;
    }

    function loadStorage() internal pure returns (Storage storage s) {
        uint256 ptr = StorageLib.pointer('fees');
        assembly {
            s.slot := ptr
        }
    }

    function fees() internal view returns (uint256 res) {
        res = loadStorage().fees.unmask();
    }

    function clearFees() internal returns (uint256 res) {
        Storage storage s = loadStorage();
        uint256 masked = s.fees;
        res = masked.unmask();
        s.fees = uint256(0).mask();
    }

    function addFeeAndRoyalty(
        address token,
        uint256 fee,
        uint256 royalty
    ) internal {
        Storage storage s = loadStorage();
        if (fee > 0) s.fees = s.fees.unmask() + fee;
        if (royalty > 0) s.royalties[token] = s.royalties[token].unmask() + royalty;
    }

    function royalties(address token) internal view returns (uint256 res) {
        res = loadStorage().royalties[token].unmask();
    }

    function clearRoyalties(address token) internal returns (uint256 res) {
        Storage storage s = loadStorage();
        res = s.royalties[token].unmask();
        s.royalties[token] = uint256(0).mask();
    }

    function checkOwner(address token) internal view returns (bool ok, address owner) {
        bytes memory returnData;
        (ok, returnData) = token.staticcall(abi.encodeWithSignature('owner()'));
        if (!ok) return (false, address(0));
        owner = abi.decode(returnData, (address));
    }

    function checkOwnerOrRoyalty(address token, uint256 tokenid) internal view returns (bool ok, address res) {
        (ok, res, ) = checkRoyalties(token, tokenid);
        if (!ok) (ok, res) = checkOwner(token);
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
