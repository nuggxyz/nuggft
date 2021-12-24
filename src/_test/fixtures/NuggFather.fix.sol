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

    function nuggft_call(User user, bytes memory args) public payable {
        nuggft_call(user, args, 0);
    }

    function nuggft_call(
        User user,
        bytes memory args,
        uint96 eth
    ) public payable {
        user.call{value: eth}(address(nuggft), args);
    }

    function nuggft_revertCall(
        string memory message,
        User user,
        bytes memory args
    ) public payable {
        nuggft_revertCall(message, user, args, 0);
    }

    function nuggft_revertCall(
        string memory message,
        User user,
        bytes memory args,
        uint96 eth
    ) public payable {
        user.revertCall{value: eth}(address(nuggft), message, args);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                delegate
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function delegate(address sender, uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.delegate.selector, sender, tokenId);
    }

    function delegateItem(
        uint256 buyerTokenId,
        uint256 sellerTokenId,
        uint256 itemId
    ) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.delegateItem.selector, buyerTokenId, sellerTokenId, itemId);
    }

    function claim(address sender, uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.claim.selector, sender, tokenId);
    }

    function swap(uint256 tokenId, uint96 floor) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.swap.selector, tokenId, floor);
    }

    function swapItem(
        uint256 tokenId,
        uint256 itemId,
        uint96 floor
    ) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.swapItem.selector, tokenId, itemId, floor);
    }

    function claimItem(
        uint256 buyerTokenId,
        uint256 sellerTokenId,
        uint256 itemId
    ) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.claimItem.selector, buyerTokenId, sellerTokenId, itemId);
    }

    function rotateFeature(uint256 tokenId, uint256 feature) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.rotateFeature.selector, tokenId, feature);
    }

    function withdrawStake(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.withdrawStake.selector, tokenId);
    }

    function migrateStake(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.migrateStake.selector, tokenId);
    }

    function setMigrator(address _migrator) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.setMigrator.selector, _migrator);
    }

    function approve(address addr, uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.approve.selector, addr, tokenId);
    }

    function setApprovalForAll(address addr, bool appr) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.setApprovalForAll.selector, addr, appr);
    }

    function mint(uint256 tokenId) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.mint.selector, tokenId);
    }

    function trustedMint(uint256 tokenId, address to) public view returns (bytes memory res) {
        return abi.encodeWithSelector(nuggft.trustedMint.selector, tokenId, to);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                scenarios
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function scenario_dee_has_a_token() public payable returns (uint32 tokenId) {
        tokenId = 2069;
        nuggft_call(dee, mint(tokenId));
    }

    function scenario_dee_has_a_token_2() public payable returns (uint32 tokenId) {
        tokenId = 2400;
        nuggft_call(dee, mint(tokenId));
    }

    function scenario_charlie_has_a_token() public payable returns (uint32 tokenId) {
        tokenId = 2070;
        nuggft_call(charlie, mint(tokenId));
    }

    function scenario_migrator_set() public payable {
        nuggft_call(safe, setMigrator(address(migrator)));
    }

    function scenario_dee_has_swapped_a_token() public payable returns (uint32 tokenId, uint96 floor) {
        tokenId = scenario_dee_has_a_token();
        floor = 10**18;

        nuggft_call(dee, approve(address(nuggft), tokenId));

        nuggft_call(dee, swap(tokenId, floor));
    }

    function scenario_dee_has_swapped_a_token_and_mac_can_claim() public payable returns (uint32 tokenId) {
        (tokenId, ) = scenario_dee_has_swapped_a_token();

        nuggft_call(mac, delegate(address(mac), tokenId), 2 * 10**18);

        fvm.roll(2000);
    }

    function scenario_mac_has_claimed_a_token_dee_swapped() public payable returns (uint32 tokenId) {
        (tokenId) = scenario_dee_has_swapped_a_token_and_mac_can_claim();

        nuggft_call(mac, claim(address(mac), tokenId));
    }

    function scenario_mac_has_swapped_a_token_dee_swapped() public payable returns (uint32 tokenId, uint96 floor) {
        (tokenId) = scenario_mac_has_claimed_a_token_dee_swapped();
        floor = 3 ether;

        nuggft_call(mac, approve(address(nuggft), tokenId));

        nuggft_call(mac, swap(tokenId, floor));
    }

    function scenario_dee_has_swapped_an_item()
        public
        payable
        returns (
            uint32 tokenId,
            uint8 feature,
            uint16 itemId,
            uint96 floor
        )
    {
        (tokenId) = scenario_dee_has_a_token();
        floor = 3 ether;

        (, uint8[] memory items, , , ) = nuggft.parsedProofOf(tokenId);

        feature = 1;
        itemId = items[feature] | (uint16(feature) << 8);

        nuggft_call(dee, rotateFeature(tokenId, feature));

        nuggft_call(dee, swapItem(tokenId, itemId, floor));
    }

    function scenario_dee_has_swapped_an_item_and_charlie_can_claim()
        public
        payable
        returns (
            uint32 charliesTokenId,
            uint32 tokenId,
            uint16 itemId
        )
    {
        uint256 feature;
        uint96 floor;
        (tokenId, feature, itemId, floor) = scenario_dee_has_swapped_an_item();

        charliesTokenId = scenario_charlie_has_a_token();

        nuggft_call(charlie, delegateItem(charliesTokenId, tokenId, itemId), floor + 1 ether);

        fvm.roll(2000);
    }

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

    function scenario_one_2a() public payable returns (uint32 firstEpoch, uint32 secondEpoch) {
        (firstEpoch, secondEpoch) = scenario_one();

        call_claim(dee, firstEpoch);

        call_approve(dee, firstEpoch, address(nuggft));
    }

    function scenario_one_2b() public payable returns (uint32 firstEpoch, uint32 secondEpoch) {
        (firstEpoch, secondEpoch) = scenario_one();

        call_claim(dee, firstEpoch);
    }

    /*━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                scenarios
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/

    function scenario_deeClaimedFirstEpoch() public payable returns (uint32 tokenId) {
        (tokenId, ) = scenario_one();

        call_claim(dee, tokenId);
    }

    function scenario_deeMinted() public payable returns (uint32 tokenId) {
        tokenId = 2069;
        nuggft_call(dee, mint(tokenId));
    }

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
                                view
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━*/
}
