import '../ercs/erc2981/IERC2981.sol';
import '../storage/RoyaltyStorage.sol';
import './ShiftLib.sol';
import './Address.sol';
import './QuadMath.sol';

library RoyaltyLib {
    using ShiftLib for uint256;
    using Address for address;
    using QuadMath for uint256;

    function calculate1(uint256 amount)
        internal
        pure
        returns (
            uint256 roy,
            uint256 fee,
            uint256 stake
        )
    {
        roy = amount.mulDiv(100, 1000);
        fee = amount.mulDiv(25, 1000);
        stake = amount - roy - fee;
    }

    function calculate0(uint256 amount)
        internal
        pure
        returns (
            uint256 value,
            uint256 royalty,
            uint256 fee,
            uint256 stake
        )
    {
        value = amount - amount.mulDiv(200, 105);
        uint256 totalFee = amount - value;
        royalty = totalFee.mulDiv(70, 100);
        fee = totalFee.mulDiv(5, 100);
        stake = totalFee - royalty - fee;
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
