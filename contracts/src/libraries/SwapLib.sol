pragma solidity 0.8.4;
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import 'hardhat/console.sol';
import './ShiftLib.sol';
import './QuadMath.sol';

library SwapLib {
    using Address for address;
    using ShiftLib for uint256;

    struct Storage {
        uint256 data;
        mapping(uint256 => mapping(uint160 => uint256)) offers;
    }

    function loadStorage(Storage storage s, address account)
        internal
        view
        returns (uint256 swapData, uint256 offerData)
    {
        return loadStorage(s, uint160(account));
    }

    function loadStorage(
        Storage storage s,
        address account,
        uint256 epoch
    ) internal view returns (uint256 swapData, uint256 offerData) {
        return loadStorage(s, uint160(account), epoch);
    }

    function loadStorage(Storage storage s, uint160 account)
        internal
        view
        returns (uint256 swapData, uint256 offerData)
    {
        swapData = s.data;

        offerData = swapData == 0 || account == swapData.account() ? swapData : s.offers[swapData.epoch()][account];
    }

    function loadStorage(
        Storage storage s,
        uint160 account,
        uint256 epoch
    ) internal view returns (uint256 swapData, uint256 offerData) {
        swapData = s.data;

        swapData = swapData.epoch() == epoch ? swapData : 0;

        offerData = swapData != 0 && account == swapData.account() ? swapData : s.offers[epoch][account];
    }

    function checkClaimer(
        uint160 account,
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

    // function moveERC721(
    //     uint256 tokenid,
    //     address from,
    //     address to
    // ) internal {
    //     // require(IERC721(token).ownerOf(tokenid) == from, 'AUC:TT:1');
    //     console.log(to, addressToTokenId(from), isTokenIdAddress(from));

    //     IERC721(token).safeTransferFrom(from, to, tokenid);

    //     require(IERC721(token).ownerOf(tokenid) == to, 'AUC:TT:3');
    // }

    function itemTokenId(uint256 itemid, uint256 tokenid) internal pure returns (uint256 res) {
        res = (tokenid << 8) | itemid;
    }

    function tokenIdToAddress(uint256 tokenid) internal pure returns (address res) {
        res = address(uint160((0x42069 << 140) | tokenid));
    }

    function addressToTokenId(address addr) internal pure returns (uint256 res) {
        res = uint136(uint160(addr));
    }

    function isTokenIdAddress(address addr) internal view returns (bool res) {
        console.logBytes32(bytes32(uint256(uint160(addr) >> 80)));
        console.logBytes32(bytes32(uint256(0x42069 << 60)));
        if (uint160(addr) >> 80 == 0x42069 << 60) return true;
    }

    // function validateSender(
    //     address token,
    //     // uint256 tokenid,
    //     address sender
    // ) internal view {
    //     console.log(sender, addressToTokenId(sender), isTokenIdAddress(sender));
    //     require(msg.sender == sender || IERC721(token).ownerOf(addressToTokenId(sender)) == msg.sender, 'SL:VS:0');
    // }

    // function moveERC1155(
    //     address token,
    //     uint256 itemtokenid,
    //     bool from
    // ) internal {
    //     // require(IERC721(token).ownerOf(tokenid) == from, 'AUC:TT:1');

    //     IERC1155(token).safeBatchTransferFrom(
    //         address(0),
    //         address(0),
    //         new uint256[](0),
    //         new uint256[](0),
    //         abi.encode(uint8(itemtokenid), itemtokenid >> 8, from)
    //     );

    //     // require(moveERC1155(token).ownerOf(tokenid) == to, 'AUC:TT:3');
    // }
}
