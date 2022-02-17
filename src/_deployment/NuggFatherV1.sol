// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {NuggftV1} from '../NuggftV1.sol';

import {DotnuggV1} from '../../../dotnugg-v1-core/src/DotnuggV1.sol';

import {IDotnuggV1StorageProxy} from '../interfaces/dotnuggv1/IDotnuggV1StorageProxy.sol';

contract NuggFatherV1Callback {
    DotnuggV1 public dotnuggV1;

    constructor(DotnuggV1 _dotnugg) {
        dotnuggV1 = _dotnugg;
    }

    function done() external {
        selfdestruct(payable(msg.sender));
    }

    function offerem(NuggftV1 nuggftv1, uint160 id) external payable {
        nuggftv1.offer{value: msg.value}(id);

        // payable(msg.sender).transfer(address(this).balance);
    }

    // function claimem(address nuggftv1, uint160 id) external {
    //     NuggftV1(nuggftv1).claim(id);

    //     payable(msg.sender).transfer(address(this).balance);
    // }
}

//'init(bytes32,bytes32,bytes,bytes,bytes)'
contract NuggFatherV1 {
    DotnuggV1 public dotnugg;
    NuggftV1 public nuggft;
    IDotnuggV1StorageProxy public proxy;

    NuggFatherV1Callback minterHelper;
    address immutable deployer;

    uint160[] toClaimFromHelper;
    uint160[] toClaim;

    uint256 claimedIndex;
    uint256 claimedFromHelperIndex;

    uint160 index = 500;

    constructor(
        bytes32 nuggftSalt,
        bytes32 dotnuggSalt,
        bytes memory nuggs
    ) {
        bool success;

        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [1] - deploy DotnuggV1
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
        // address dn;
        // assembly {
        //     dn := create2(0x0, add(dotnuggCode, 0x20), mload(dotnuggCode), dotnuggSalt)
        // }

        // require(dn != address(0), 'OOPS:1');

        dotnugg = new DotnuggV1{salt: dotnuggSalt}();
        require(address(dotnugg) != address(0), 'OOPS:1');

        deployer = msg.sender;

        minterHelper = new NuggFatherV1Callback(dotnugg);

        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [2] - deploy NuggftV1
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

        nuggft = new NuggftV1{salt: nuggftSalt}();
        require(address(nuggft) != address(0), 'OOPS:2');

        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [3] - call NuggftV1 "dotnuggV1StorageProxy()"
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

        IDotnuggV1StorageProxy _proxy = nuggft.dotnuggV1StorageProxy();

        require(address(_proxy) != address(0), 'OOPS:3/2');

        proxy = _proxy;

        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [4] - call DotnuggV1StorageProxy "unsafeBulkStore(uint256[][][])"
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

        nuggs = bytes.concat(hex'6ce05d4a', nuggs);

        assembly {
            success := call(gas(), _proxy, 0x0, add(nuggs, 0x20), mload(nuggs), 0x0, 0)
        }

        require(success, 'OOPS:4');

        dotnugg = dotnugg;
        nuggft = nuggft;

        // pdc.done();

        // selfdestruct(payable(msg.sender));
    }

    function trustMint(
        address to,
        uint256 start,
        uint256 amount
    ) external payable {
        for (uint256 i = start; i < start + amount; i++) {
            nuggft.trustedMint{value: nuggft.msp()}(uint160(i), to);
        }
        payable(msg.sender).transfer(address(this).balance);
    }

    function mint(uint160 amount) external payable {
        for (uint160 i = index; i < index + amount; i++) {
            nuggft.mint{value: nuggft.msp()}(uint160(i));
            uint96 floor = nuggft.eps() * 3;

            nuggft.sell(uint160(i), floor);

            uint96 amt = nuggft.vfo(address(minterHelper), uint160(i));

            if (i % 2 == 0) {
                minterHelper.offerem{value: amt}(nuggft, i);
                toClaimFromHelper.push(i);
            } else {
                toClaim.push(i);
            }
        }

        index += amount;

        payable(msg.sender).transfer(address(this).balance);
    }
}
