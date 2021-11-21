// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import './libraries/SwapLib.sol';
import './interfaces/INuggSwap.sol';
// import './interfaces/IERC721Nuggable.sol';
import './libraries/CheapMath.sol';
import './libraries/ShiftLib.sol';

// import './interfaces/INuggSwapable.sol';
import './interfaces/IxNUGG.sol';

import './erc721/IERC721.sol';
import './core/Epochable.sol';
import './erc2981/IERC2981.sol';
import 'hardhat/console.sol';
import './common/Testable.sol';
import './erc721/ERC721Holder.sol';
import './erc1155/ERC1155Holder.sol';

// 80000000071158E460913D050272BE2A172EBEA775FD7ED68C32B0DC1032C55D
contract NuggSwap is INuggSwap, ERC721Holder, ERC1155Holder, Testable, Epochable {
    using Address for address payable;
    using SwapLib for SwapLib.SwapData;
    using CheapMath for uint16;
    using ShiftLib for uint256;

    struct Storage {
        // uint256[] datas;
        mapping(uint256 => uint256) datas;
        mapping(address => mapping(uint256 => uint256)) users;
    }

    mapping(address => uint256) internal _royalty;

    mapping(address => uint256) _royalties;

    IxNUGG public immutable override xnugg;

    constructor(address _xnugg) Epochable(25, uint128(block.number)) {
        xnugg = IxNUGG(_xnugg);
    }

    function submitOffer(
        address token,
        uint256 tokenid,
        uint256 swapnum
    ) external payable override {
        _submitOffer(token, tokenid, swapnum, msg_sender(), msg_sender(), uint128(msg_value()));
    }

    function getSwap(
        address token,
        uint256 tokenid,
        uint256 swapnum
    ) external view override returns (SwapData memory res) {
        // var (, , , ) = loadStorage(token, tokenid, swapnum, address(0));
        // res.swapnum = _swapnum > numSwaps ? numSwaps : _swapnum;
        // res.amount = uint128(leaderData);
    }

    function submitSwap(
        address token,
        uint256 tokenid,
        uint256 swapnum,
        uint48 requestedEpoch,
        uint128 requestedFloor,
        bool is1155
    ) external override {
        _submitSwap(token, tokenid, swapnum, msg_sender(), requestedEpoch, requestedFloor, is1155);
    }

    function submitOfferTo(
        address token,
        uint256 tokenid,
        uint256 swapnum,
        address to
    ) external payable override {
        _submitOffer(token, tokenid, swapnum, msg_sender(), to, uint128(msg_value()));
    }

    function submitClaim(
        address token,
        uint256 tokenid,
        uint256 swapnum
    ) external override {
        _submitClaim(token, tokenid, swapnum, msg_sender(), msg_sender());
    }

    function submitClaimTo(
        address token,
        uint256 tokenid,
        uint256 swapnum,
        address to
    ) external override {
        _submitClaim(token, tokenid, swapnum, msg_sender(), to);
    }

    function _submitSwap(
        address token,
        uint256 tokenid,
        uint256 swapnum,
        address account,
        uint48 requestedEpoch,
        uint256 requestedFloor,
        bool is1155 // uint16 tokenAmount, // uint8 tokenPrecision
    ) internal {
        Storage storage s;
        assembly {
            s.slot := keccak256(token, tokenid)
        }

        uint256 epoch = currentEpochId() + requestedEpoch;

        uint256 swapData = uint256(uint160(account)).setEpoch(epoch).setFeeClaimed();
        // uint256 offerData = requestedFloor.setOwner();

        if (is1155) {
            SwapLib.moveERC1155(token, tokenid, account, address(this));
            swapData.setIs1155();
        } else SwapLib.moveERC721(token, tokenid, account, address(this));

        // s.users[account] = offerData;

        s.datas[swapnum] = swapData;

        emit SubmitSwap(token, tokenid, swapnum, account, requestedFloor, epoch);
    }

    function _submitOffer(
        address token,
        uint256 tokenid,
        uint256 swapnum,
        address account,
        address to,
        uint256 value
    ) internal {
        assert(value <= type(uint128).max); // bc it will always be msg.value

        (Storage storage s, uint256 swapData, uint256 offerData) = loadStorage(token, tokenid, swapnum, account);

        uint256 activeEpoch = currentEpochId();

        if (swapData != 0) {
            console.log(swapData);

            s.users[address(uint160(swapData))][swapnum] = swapData;
        }
        // 8000000007246DDF97976605CD45D2C3D3B277095ECB8C9A7EBA48BE9BF8261A

        if (swapData == 0 && swapnum == 0) {
            bool is1155 = mintToken(token, tokenid, activeEpoch);

            swapData.setEpoch(activeEpoch);

            if (is1155) swapData.setIs1155();
        } else {
            require(swapData != 0, 'SL:HSO:-1');
        }
        console.log(offerData);
        require(!offerData.isFeeClaimed(), 'SL:HSO:0'); // isFeeClaimed == isOwner if in offerData
        require(!offerData.isTokenClaimed(), 'SL:HSO:1');
        // console.log('HERE:', swapData.eth(), offerData.eth(), value);
        // console.log(
        //     'HERE:',
        //     swapData.setEth(swapData.eth() + value).eth(),
        //     offerData.setEth(offerData.eth() + value).eth(),
        //     value
        // );
        // console.log('---------');
        offerData = offerData == 0
            ? swapData.setEth(swapData.eth() + value)
            : offerData.setEth(offerData.eth() + value);
        // console.log('HERE:', swapData.eth(), offerData.eth(), value);
        // console.log(
        //     'HERE:',
        //     swapData.setEth(swapData.eth() + value).eth(),
        //     offerData.setEth(offerData.eth() + value).eth(),
        //     value
        // );
        // 32000000000000000000
        require(activeEpoch <= swapData.epoch() && !swapData.isTokenClaimed(), 'SL:OBP:3');
        require(swapData.eth() < offerData.eth(), 'SL:OBP:4');

        s.datas[swapnum] = swapData.setAccount(account).setEth(offerData.eth());

        emit SubmitOffer(token, tokenid, swapnum, account, value);
    }

    // todo - we need to make sure that if any of this fails the transaction still goes through (sending value to xnugg should never fail)

    // todo - we need to check if they implement erc2981 - if they do not send royalties to owner - if they have no owner than no royalties

    function _submitClaim(
        address token,
        uint256 tokenid,
        uint256 swapnum,
        address account,
        address to
    ) internal {
        (Storage storage s, uint256 swapData, uint256 offerData) = loadStorage(token, tokenid, swapnum, account);

        uint256 activeEpoch = currentEpochId();

        bool winner = SwapLib.checkClaimer(account, swapData, offerData, activeEpoch);

        // s.users[account] = offerData.setClaimed();

        if (winner) {
            SwapLib.moveERC721(token, tokenid, address(this), to);
            s.datas[swapnum] = swapData.setTokenClaimed();
        } else {
            // console.log(offerData.eth());
            s.users[account][swapnum] = swapData.setTokenClaimed();

            payable(to).sendValue(offerData.eth());
        }

        emit SubmitClaim(token, tokenid, swapnum, account);
    }

    function mintToken(
        address token,
        uint256 tokenid,
        uint256 activeEpoch
    ) internal returns (bool res) {
        try IERC721(token).safeTransferFrom(address(0), address(this), tokenid, abi.encode(activeEpoch)) {
            return false;
        } catch {
            try IERC1155(token).safeTransferFrom(address(0), address(this), tokenid, 1, abi.encode(activeEpoch)) {
                return true;
            } catch {
                require(false, 'NS:MT:0');
            }
        }
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
        assembly {
            s.slot := keccak256(token, tokenid)
        }

        swapData = s.datas[swapnum];

        if (swapData == 0) return (s, 0, 0);
        // 8000000007   1158E460913D   05       0272BE2A172EBEA775FD7ED68C32B0DC1032C55D
        if (account != address(uint160(swapData))) offerData = s.users[account][swapnum];
        // else offerData = swapData;
    }
}
