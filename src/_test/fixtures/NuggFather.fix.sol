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

    User public any;

    function reset() public {
        fvm.roll(1);
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

        any = new User();

        nuggft.setIsTrusted(address(safe), true);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                delegate
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function tryCall_delegate(
        User user,
        uint256 eth,
        uint256 tokenId
    ) public payable returns (bool ok) {
        (ok, ) = user.tryCall{value: eth}(address(nuggft), abi.encodeWithSelector(nuggft.delegate.selector, address(user), tokenId));
    }

    function call_delegate(
        User user,
        uint256 eth,
        uint256 tokenId
    ) public payable {
        user.call{value: eth}(address(nuggft), abi.encodeWithSelector(nuggft.delegate.selector, address(user), tokenId));
    }

    function revertCall_delegate(
        User user,
        uint256 eth,
        string memory message,
        uint256 tokenId
    ) public payable {
        user.revertCall{value: eth}(address(nuggft), message, abi.encodeWithSelector(nuggft.delegate.selector, address(user), tokenId));
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                claim
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function tryCall_claim(User user, uint256 tokenId) public returns (bool ok) {
        (ok, ) = user.tryCall(address(nuggft), abi.encodeWithSelector(nuggft.claim.selector, address(user), tokenId));
    }

    function call_claim(User user, uint256 tokenId) public {
        user.call(address(nuggft), abi.encodeWithSelector(nuggft.claim.selector, address(user), tokenId));
    }

    function revertCall_claim(
        User user,
        string memory message,
        uint256 tokenId
    ) public {
        user.revertCall(address(nuggft), message, abi.encodeWithSelector(nuggft.claim.selector, address(user), tokenId));
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                swap
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function tryCall_swap(
        User user,
        uint256 tokenId,
        uint256 floor
    ) public returns (bool ok) {
        (ok, ) = user.tryCall(address(nuggft), abi.encodeWithSelector(nuggft.swap.selector, tokenId, floor));
    }

    function call_swap(
        User user,
        uint256 tokenId,
        uint256 floor
    ) public {
        user.call(address(nuggft), abi.encodeWithSelector(nuggft.swap.selector, tokenId, floor));
    }

    function revertCall_swap(
        User user,
        string memory message,
        uint256 tokenId,
        uint256 floor
    ) public {
        user.revertCall(address(nuggft), message, abi.encodeWithSelector(nuggft.swap.selector, tokenId, floor));
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                approve
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function tryCall_approve(
        User user,
        uint256 tokenId,
        address to
    ) public returns (bool ok) {
        (ok, ) = user.tryCall(address(nuggft), abi.encodeWithSelector(nuggft.approve.selector, to, tokenId));
    }

    function call_approve(
        User user,
        uint256 tokenId,
        address to
    ) public {
        user.call(address(nuggft), abi.encodeWithSelector(nuggft.approve.selector, to, tokenId));
    }

    function revertCall_approve(
        User user,
        string memory message,
        uint256 tokenId,
        address to
    ) public {
        user.revertCall(address(nuggft), message, abi.encodeWithSelector(nuggft.approve.selector, to, tokenId));
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                valueForDelegate
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function tryCall_valueForDelegate(
        User user,
        uint256 tokenId,
        address to
    ) public returns (bool ok) {
        (ok, ) = user.tryCall(address(nuggft), abi.encodeWithSelector(nuggft.valueForDelegate.selector, tokenId, to));
    }

    function call_valueForDelegate(
        User user,
        uint256 tokenId,
        address to
    ) public {
        user.call(address(nuggft), abi.encodeWithSelector(nuggft.valueForDelegate.selector, tokenId, to));
    }

    function revertCall_valueForDelegate(
        User user,
        string memory message,
        uint256 tokenId,
        address to
    ) public {
        user.revertCall(address(nuggft), message, abi.encodeWithSelector(nuggft.valueForDelegate.selector, tokenId, to));
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                scenarios
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function scenario_one() public payable returns (uint32 firstEpoch, uint32 secondEpoch) {
        firstEpoch = nuggft.epoch();

        call_delegate(mac, 5 * 10**15, firstEpoch);
        call_delegate(dee, 9 * 10**15, firstEpoch);

        fvm.roll(2000);

        secondEpoch = nuggft.epoch();

        require(secondEpoch > firstEpoch, 'BLOCK NUMBER NOT HIGH ENOUGH');
    }

    function scenario_one_2() public payable returns (uint32 firstEpoch, uint32 secondEpoch) {
        (firstEpoch, secondEpoch) = scenario_one();

        call_claim(dee, firstEpoch);

        call_approve(dee, firstEpoch, address(nuggft));

        call_swap(dee, firstEpoch, 12 * 10**15);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                view
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/
}
