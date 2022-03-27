// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "../../NuggftV1.test.sol";

contract txgas__NuggftV1Swap is NuggftV1Test {
    uint160 private MINT_TOKENID = mintable(3004);
    uint160 private COMMIT_TOKENID = mintable(1498);
    uint160 private CARRY_TOKENID = mintable(1300);

    uint160 private SELL_TOKENID = mintable(1496);
    uint160 private CLAIM_TOKENID = mintable(1497);

    function setUp() public {
        reset();
        forge.vm.deal(users.dee, 40000 ether);
        forge.vm.startPrank(users.dee);
        nuggft.mint{value: 100 ether}(COMMIT_TOKENID);
        nuggft.mint{value: nuggft.msp()}(CARRY_TOKENID);
        nuggft.sell(COMMIT_TOKENID, nuggft.eps() + LOSS * 2);
        nuggft.sell(CARRY_TOKENID, nuggft.eps() + LOSS * 2);

        forge.vm.stopPrank();

        forge.vm.deal(users.frank, 40000 ether);
        forge.vm.startPrank(users.frank);
        nuggft.mint{value: nuggft.msp()}(SELL_TOKENID);
        forge.vm.stopPrank();

        forge.vm.startPrank(users.mac);
        uint96 val = nuggft.vfo(users.mac, CARRY_TOKENID);
        nuggft.offer{value: val}(CARRY_TOKENID);
        forge.vm.stopPrank();
    }

    function test__txgas__NuggftV1Swap__offer__mint() public {
        nuggft.offer{value: 200 ether}(nuggft.epoch());
    }

    function test__txgas__NuggftV1Swap__offer__commit() public {
        nuggft.offer{value: 200 ether}(COMMIT_TOKENID);
    }

    function test__txgas__NuggftV1Swap__offer__carry() public {
        nuggft.offer{value: 200 ether}(CARRY_TOKENID);
    }

    // function test__txgas__NuggftV1Swap__sell() public {
    //     nuggft.rebalance{value: 200 ether}(REBALANCE_TOKENID);
    // }

    // function test__txgas__NuggftV1Swap__claim() public {
    //     nuggft.liquidate{value: 200 ether}(LIQUIDATE_TOKENID);
    // }
}
