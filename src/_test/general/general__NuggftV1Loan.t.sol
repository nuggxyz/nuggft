// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../NuggftV1.test.sol';
import {ShiftLib} from '../../libraries/ShiftLib.sol';
import {NuggftV1Loan} from '../../core/NuggftV1Loan.sol';
import {NuggftV1Token} from '../../core/NuggftV1Token.sol';

contract general__NuggftV1Loan is NuggftV1Test, NuggftV1Loan {
    function dotnuggV1ImplementerCallback(uint256 tokenId) public view override returns (IDotnuggV1Metadata.Memory memory data) {}

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {}

    function trustedMint(uint160 tokenId, address to) external payable override requiresTrust {}

    function mint(uint160 tokenId) public payable override {}

    function burn(uint160 tokenId) public override {}

    function migrate(uint160 tokenId) public override {}

    function safe__calc(uint96 principal, uint96 activeEps)
        internal
        pure
        returns (
            uint96 toLiquidate,
            uint96 fee,
            uint96 earned
        )
    {
        // assert(principal <= activeEps);

        uint96 checkFee = (principal / REBALANCE_FEE_BPS);

        if (activeEps - checkFee > principal) {
            fee = checkFee;
            toLiquidate = principal + fee;
            earned = activeEps - toLiquidate;
        }
    }

    function test__general__NuggftV1Loan__calc__gas__safe() public {
        safe__calc(type(uint96).max, type(uint96).max);
    }

    function test__general__NuggftV1Loan__calc__gas() public {
        calc(type(uint96).max, type(uint96).max);
    }

    function test__general__NuggftV1Loan__calc__safe(uint96 principal, uint96 activeEps) public {
        if (principal > activeEps) return;

        // if (principal > type(uint64).max || activeEps > type(uint64).max) return;

        (uint96 sa, uint256 sb, uint96 sc) = safe__calc(principal, activeEps);
        (uint96 ra, uint256 rb, uint96 rc) = calc(principal, activeEps);

        assertEq(ra, sa);
        assertEq(rb, sb);
        assertEq(rc, sc);
    }

    function test__scratch() public view {
        uint96 principal = 928455029464035206174343168;
        uint96 activeEps = 928455029464035206174343168;

        (uint96 ra, uint96 rb, uint96 rc) = calc(principal, activeEps);

        logger.log(ra, 'toLiquidate', rb, 'fee', rc, 'earned', principal, 'principal', type(uint96).max, 'max');

        unchecked {
            uint96 fee = (principal) / 100;
            logger.log(activeEps - principal - fee, 'check');
            logger.log(activeEps - fee, 'check2');
            console.log(activeEps - fee > principal);
            console.log(fee);
            logger.log(fee, 'fee');

            bool check;
            assembly {
                check := gt(sub(activeEps, fee), principal)
            }
            console.log(check);
        }
    }

    // function calc(uint256 principal, uint256 activeEps)
    //     internal
    //     pure
    //     returns (
    //         uint96 toLiquidate,
    //         uint96 fee,
    //         uint96 earned
    //     )
    // {
    //     // // principal can never be below activeEps
    //     assert(principal <= activeEps);

    //     assembly {
    //         let checkFee := div(mul(principal, REBALANCE_FEE_BPS), 10000)

    //         // (activeEps - fee >= principal)
    //         if gt(sub(activeEps, checkFee), principal) {
    //             fee := checkFee
    //             toLiquidate := add(principal, fee)
    //             earned := sub(activeEps, toLiquidate)
    //         }
    //     }
    // }
}
