// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DSTestPlus as t} from '../utils/DSTestPlus.sol';

import {User} from '../utils/User.sol';

import {MockdotnuggV1Processor} from '../../_mock/MockdotnuggV1Processer.sol';

import {MockNuggFTV1Migrator} from '../../_mock/MockNuggFTV1Migrator.sol';

import {NuggFT} from '../../NuggFT.sol';

contract RiggedNuggft is NuggFT {
    constructor(address processor) NuggFT(processor) {
        globalPointerForTesting().file.lengthData = 0x0303030303030303;
    }
}

contract NuggFatherFix is t {
    MockdotnuggV1Processor public processor;

    MockNuggFTV1Migrator public migrator;

    RiggedNuggft public nuggft;

    User public safe;

    User public frank;
    User public charlie;
    User public dennis;
    User public mac;
    User public dee;

    function reset() public {
        fvm.roll(2);
        processor = new MockdotnuggV1Processor();
        migrator = new MockNuggFTV1Migrator();
        nuggft = new RiggedNuggft(address(processor));

        safe = new User{value: 100 * 10**18}();
        frank = new User{value: 100 * 10**18}();
        charlie = new User{value: 100 * 10**18}();
        dennis = new User{value: 100 * 10**18}();
        mac = new User{value: 100 * 10**18}();
        dee = new User{value: 100 * 10**18}();

        nuggft.setIsTrusted(address(safe), true);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                swap
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function tryCall_delegate(
        User user,
        uint256 eth,
        uint256 tokenId
    ) public payable returns (bool ok) {
        (ok, ) = user.tryCall{value: eth}(address(nuggft), abi.encodeWithSelector(nuggft.delegate.selector, tokenId));
    }

    function call_delegate(
        User user,
        uint256 eth,
        uint256 tokenId
    ) public payable {
        user.tryCall{value: eth}(address(nuggft), abi.encodeWithSelector(nuggft.delegate.selector, tokenId));
    }

    function revertCall_delegate(
        User user,
        uint256 eth,
        string memory message,
        uint256 tokenId
    ) public payable {
        user.revertCall{value: eth}(address(nuggft), message, abi.encodeWithSelector(nuggft.delegate.selector, tokenId));
    }

    function call_claim(User user, uint256 tokenId) public returns (bool ok) {
        (ok, ) = user.tryCall(address(nuggft), abi.encodeWithSelector(nuggft.claim.selector, tokenId));
    }

    function call_swap(
        User user,
        uint256 tokenId,
        uint256 floor
    ) public returns (bool ok) {
        (ok, ) = user.tryCall(address(nuggft), abi.encodeWithSelector(nuggft.swap.selector, tokenId, floor));
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                scenarios
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function scenario_one() public payable {
        call_delegate(frank, 0, nuggft.epoch());
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                view
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    // function epoch() public returns (uint32 res) {
    //     return nuggft.epoch();
    // }
}
