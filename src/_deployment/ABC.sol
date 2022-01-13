// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {DotnuggV1} from '../../../dotnugg-core/src/DotnuggV1.sol';

contract PureDeployerCallback {
    address public dotnuggV1;

    constructor(address _dotnugg) {
        dotnuggV1 = _dotnugg;
    }
}

contract ABC {
    address public __dotnugg;
    address public __nuggft;

    function init(
        uint256 nuggftSalt,
        uint256 dotnuggSalt,
        bytes memory nuggftCode,
        bytes memory dotnuggCode,
        bytes memory nuggs
    )
        external
        returns (
            address dotnugg,
            address nuggft,
            address proxy,
            bool success
        )
    {
        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [1] - deploy DotnuggV1
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
        assembly {
            dotnugg := create2(0x0, add(dotnuggCode, 0x20), mload(dotnuggCode), dotnuggSalt)
        }

        require(dotnugg != address(0), 'OOPS:1');

        new PureDeployerCallback(dotnugg);

        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [2] - deploy NuggftV1
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

        assembly {
            nuggft := create2(0x0, add(nuggftCode, 0x20), mload(nuggftCode), nuggftSalt)
        }

        require(nuggft != address(0), 'OOPS:2');

        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [3] - call NuggftV1 "dotnuggV1StorageProxy()"
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

        bytes memory proxy_call = hex'b91b6cbf';

        assembly {
            let ptr := mload(0x40)

            success := staticcall(gas(), nuggft, add(proxy_call, 0x20), mload(proxy_call), ptr, 0x20)

            proxy := mload(ptr)
        }
        require(success, 'OOPS:3');

        require(proxy != address(0), 'OOPS:3/2');

        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [4] - call DotnuggV1StorageProxy "unsafeBulkStore(uint256[][][])"
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

        nuggs = bytes.concat(hex'87ae7031', nuggs);

        assembly {
            success := call(gas(), proxy, 0x0, add(nuggs, 0x20), mload(nuggs), 0x0, 0)
        }

        require(success, 'OOPS:4');

        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [5] - call NuggftV1 "setIsTrusted(address,bool)"
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

        bytes memory remove_trust_call = abi.encodeWithSelector(bytes4(keccak256('setIsTrusted(address,bool)')), address(this), false);

        assembly {
            success := call(gas(), nuggft, 0x0, add(remove_trust_call, 0x20), mload(remove_trust_call), 0x0, 0x0)
        }

        require(success, 'OOPS:5');

        __dotnugg = dotnugg;
        __nuggft = nuggft;
    }
}
