pragma solidity 0.8.4;

import '../storage/RoyaltyStorage.sol';
import '../libraries/RoyaltyLib.sol';
import '../libraries/ShiftLib.sol';
import '../libraries/Address.sol';

library RoyaltyModule {
    using RoyaltyLib for uint256;
    using ShiftLib for uint256;
    using Address for address;

    function execute0(
        address staker,
        address token,
        uint256 amount
    ) internal returns (uint256 res) {
        (uint256 value, uint256 royalty, uint256 fee, uint256 stake) = RoyaltyLib.calculate0(amount);

        addFeeAndRoyalty(token, royalty, fee);

        staker.sendValue(stake);

        res = value;
    }

    function execute1(
        address staker,
        address token,
        uint256 amount
    ) internal {
        (uint256 royalty, uint256 fee, uint256 stake) = RoyaltyLib.calculate1(amount);

        addFeeAndRoyalty(token, royalty, fee);

        staker.sendValue(stake);
    }

    function fees() internal view returns (uint256 res) {
        res = RoyaltyStorage.load().fees.unmaskZero();
    }

    function clearFees() internal returns (uint256 res) {
        RoyaltyStorage.Bin storage s = RoyaltyStorage.load();
        uint256 masked = s.fees;
        res = masked.unmaskZero();
        s.fees = uint256(0).maskZero();
    }

    function addFeeAndRoyalty(
        address token,
        uint256 fee,
        uint256 royalty
    ) internal {
        RoyaltyStorage.Bin storage s = RoyaltyStorage.load();
        if (fee > 0) s.fees = s.fees.unmaskZero() + fee;
        if (royalty > 0) s.royalties[token] = s.royalties[token].unmaskZero() + royalty;
    }

    function royalties(address token) internal view returns (uint256 res) {
        res = RoyaltyStorage.load().royalties[token].unmaskZero();
    }

    function clearRoyalties(address token) internal returns (uint256 res) {
        RoyaltyStorage.Bin storage s = RoyaltyStorage.load();
        res = s.royalties[token].unmaskZero();
        s.royalties[token] = uint256(0).maskZero();
    }
}
