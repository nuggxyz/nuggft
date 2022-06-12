// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import "../../NuggftV1.test.sol";

contract txgas__NuggftV1Loan is NuggftV1Test {
    uint24 private LOAN_TOKENID;
    uint24 private REBALANCE_TOKENID;
    uint24 private LIQUIDATE_TOKENID;

    function setUp() public {
        reset();

        LOAN_TOKENID = mintable(1499);
        REBALANCE_TOKENID = mintable(1498);
        LIQUIDATE_TOKENID = mintable(1497);

        mintHelper(LOAN_TOKENID, users.frank, 100 ether);

        mintHelper(REBALANCE_TOKENID, users.frank, nuggft.msp());

        forge.vm.deal(users.frank, 40000 ether);
        forge.vm.startPrank(users.frank);
        nuggft.loan(array.b24(REBALANCE_TOKENID));
        forge.vm.stopPrank();

        mintHelper(LIQUIDATE_TOKENID, users.frank, nuggft.msp());

        forge.vm.prank(users.frank);
        nuggft.loan(array.b24(LIQUIDATE_TOKENID));
    }

    function test__txgas__NuggftV1Loan__loan() public {
        forge.vm.prank(users.frank);
        nuggft.loan(array.b24(LOAN_TOKENID));
    }

    // function test__txgas__NuggftV1Loan__mutlirebalance() public {
    //     uint24[] memory a = new uint24[](1);
    //     a[0] = REBALANCE_TOKENID;
    //     nuggft.rebalance{value: 200 ether}(a);
    // }

    function test__txgas__NuggftV1Loan__rebalance() public {
        forge.vm.prank(users.frank);
        nuggft.rebalance{value: 200 ether}(array.b24(REBALANCE_TOKENID));
    }

    function test__txgas__NuggftV1Loan__liquidate() public {
        forge.vm.prank(users.frank);
        nuggft.liquidate{value: 200 ether}(LIQUIDATE_TOKENID);
    }
}
