import './ShiftLib.sol';
import './Address.sol';
import './QuadMath.sol';
import './StorageLib.sol';

import '../ercs/erc721/IERC721.sol';
import '../ercs/erc1155/IERC1155.sol';

import '../ercs/erc2981/IERC2981.sol';

library TokenLib {
    using ShiftLib for uint256;

    function mintToken(address token, uint256 tokenid) internal view {
        try IERC721(token).ownerOf(tokenid) returns (address addr) {
            require(addr == address(this), 'NS:MT:0');
        } catch {
            require(false, 'TL:MT:0');
            // try IERC1155(token).balanceOf(address(this), tokenid) returns (uint256 amount) {
            //     require(amount > 0, 'NS:MT:1');
            //     return (true);
            // } catch {
            //     require(false, 'NS:MT:0');
            // }
        }
    }

    function move(
        address token,
        uint256 tokenid,
        address from,
        address to,
        bool is1155
    ) internal {
        if (is1155) moveERC1155(token, tokenid, from, to);
        else moveERC721(token, tokenid, from, to);
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

    function validateApproval(
        address token,
        uint256 tokenid,
        address sender,
        bool is1155
    ) internal view {
        if (is1155) {
            require(IERC1155(token).balanceOf(sender, tokenid) >= 1, 'AUC:VA:0');
            require(IERC1155(token).isApprovedForAll(sender, address(this)), 'AUC:VA:1');
        } else {
            require(IERC721(token).getApproved(tokenid) == address(this), 'AUC:VA:2');
        }
    }

    function validateOwnership(
        address token,
        uint256 tokenid,
        address user,
        bool is1155
    ) internal view {
        if (is1155) {
            require(IERC1155(token).balanceOf(user, tokenid) >= 1, 'AUC:VA:0');
        } else {
            require(IERC721(token).ownerOf(tokenid) == user, 'AUC:TT:1');
        }
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
