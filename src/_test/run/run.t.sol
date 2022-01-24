// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

contract runner {
    function safe__calc(uint96 principal, uint96 activeEps)
        internal
        pure
        returns (
            uint96 toLiquidate,
            uint96 fee,
            uint96 earned
        )
    {
        assert(principal <= activeEps);

        uint96 checkFee = (principal * 100) / 10000;

        if (activeEps - checkFee > principal) {
            fee = checkFee;
            toLiquidate = principal + fee;
            earned = activeEps - toLiquidate;
        }
    }

    function test__general__NuggftV1Loan__calc__safe(uint64 principal, uint64 activeEps) public {
        if (principal > activeEps) return;

        if (principal > type(uint64).max || activeEps > type(uint64).max) return;

        (uint96 sa, uint256 sb, uint96 sc) = safe__calc(principal, activeEps);
        (uint96 ra, uint256 rb, uint96 rc) = calc(principal, activeEps);

        // assertEq(ra, sa);
        // assertEq(rb, sb);
        // assertEq(rc, sc);
    }

    function run() public view {
        assembly {
            mstore(0, 0x69)
            revert(31, 1)
        }

        uint96 principal = 15492382718154506240;
        uint96 activeEps = 15492382718154506241;

        (uint96 ra, uint96 rb, uint96 rc) = safe__calc(principal, activeEps);

        // logger.log(ra, 'toLiquidate', rb, 'fee', rc, 'earned', principal, 'principal', activeEps, 'activeEps');

        unchecked {
            uint96 fee = (principal * 100) / 10000;
            // // logger.log(activeEps - principal - fee, 'check');
            // // logger.log(activeEps - fee, 'check2');
            // console.log(activeEps - fee > principal);

            bool check;
            assembly {
                check := gt(sub(activeEps, fee), principal)
            }
            // console.log(check);
        }
    }

    function calc(uint256 principal, uint256 activeEps)
        internal
        pure
        returns (
            uint96 toLiquidate,
            uint96 fee,
            uint96 earned
        )
    {
        // // principal can never be below activeEps
        assert(principal <= activeEps);

        assembly {
            let checkFee := div(mul(principal, 100), 10000)

            // (activeEps - fee >= principal)
            if gt(sub(activeEps, checkFee), principal) {
                fee := checkFee
                toLiquidate := add(principal, fee)
                earned := sub(activeEps, toLiquidate)
            }
        }
    }
}
