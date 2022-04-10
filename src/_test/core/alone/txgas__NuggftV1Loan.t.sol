// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

contract txgas__NuggftV1Loan is NuggftV1Test {
    uint160 private LOAN_TOKENID = mintable(1499);
    uint160 private REBALANCE_TOKENID = mintable(1498);
    uint160 private LIQUIDATE_TOKENID = mintable(1497);

    function setUp() public {
        reset();

        forge.vm.deal(users.frank, 40000 ether);
        forge.vm.startPrank(users.frank);

        nuggft.mint{value: 100 ether}(LOAN_TOKENID);
        nuggft.mint{value: nuggft.msp()}(REBALANCE_TOKENID);
        nuggft.loan(lib.sarr160(REBALANCE_TOKENID));

        nuggft.mint{value: nuggft.msp()}(LIQUIDATE_TOKENID);

        nuggft.loan(lib.sarr160(LIQUIDATE_TOKENID));
        forge.vm.stopPrank();
    }

    function test__txgas__NuggftV1Loan__loan() public {
        forge.vm.prank(users.frank);
        nuggft.loan(lib.sarr160(LOAN_TOKENID));
    }

    // function test__txgas__NuggftV1Loan__mutlirebalance() public {
    //     uint160[] memory a = new uint160[](1);
    //     a[0] = REBALANCE_TOKENID;
    //     nuggft.rebalance{value: 200 ether}(a);
    // }

    function test__txgas__NuggftV1Loan__rebalance() public {
        forge.vm.prank(users.frank);
        nuggft.rebalance{value: 200 ether}(lib.sarr160(REBALANCE_TOKENID));
    }

    function test__txgas__NuggftV1Loan__liquidate() public {
        forge.vm.prank(users.frank);
        nuggft.liquidate{value: 200 ether}(LIQUIDATE_TOKENID);
    }
}
