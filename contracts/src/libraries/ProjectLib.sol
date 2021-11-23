import './ShiftLib.sol';
import './Address.sol';
import './QuadMath.sol';
import './StorageLib.sol';

library ProjectLib {
    using ShiftLib for uint256;

    struct Storage {
        uint256 data;
        // uint256 top;
        // uint256 startEpoch;
        // uint256 floor;
        // uint256 startid;
    }

    function loadStorage() internal pure returns (Storage storage s) {
        uint256 ptr = StorageLib.pointer('epoch');
        assembly {
            s.slot := ptr
        }
    }

    function setProjectOwner() internal pure {}

    function createProject(
        address owner,
        bool is1155, // bit
        bool rightToMint, // bit
        bool freeforall, // simple || d
        uint256 floor, // uint32
        uint256 startid, // uint32
        uint256 length, // uint32 - 0 for perpetual,
        uint256 startEpoch // simple
    )
        internal
        returns (
            // freeForAll || epochable
            uint256 res
        )
    {
        res = uint256(0).setAccount(owner).setEpoch(startEpoch).setIs1155(is1155);
    }
}
