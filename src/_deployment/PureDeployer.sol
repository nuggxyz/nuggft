// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

// import '../_test/utils/DSEmit.sol';

contract PureDeployerCallback {
    address public dotnuggV1;

    constructor(address _dotnugg) {
        dotnuggV1 = _dotnugg;
    }

    function done() external {
        selfdestruct(payable(msg.sender));
    }
}

//'init(bytes32,bytes32,bytes,bytes,bytes)'
contract PureDeployer {
    address public __dotnugg;
    address public __nuggft;

    constructor(
        bytes32 nuggftSalt,
        bytes32 dotnuggSalt,
        bytes memory nuggftCode,
        bytes memory dotnuggCode,
        bytes memory nuggs
    ) {
        address dotnugg;
        address nuggft;
        address proxy;
        bool success;
        // }

        // function init(
        //     bytes32 nuggftSalt,
        //     bytes32 dotnuggSalt,
        //     bytes memory nuggftCode,
        //     bytes memory dotnuggCode,
        //     bytes memory nuggs
        // )
        //     external
        //     returns (
        //         address dotnugg,
        //         address nuggft,
        //         address proxy,
        //         bool success
        //     )
        // {
        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [1] - deploy DotnuggV1
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
        // DSEmit.startMeasuringGas('B');

        assembly {
            dotnugg := create2(0x0, add(dotnuggCode, 0x20), mload(dotnuggCode), dotnuggSalt)
        }

        require(dotnugg != address(0), 'OOPS:1');
        // DSEmit.stopMeasuringGas();

        // DSEmit.startMeasuringGas('B2');

        PureDeployerCallback pdc = new PureDeployerCallback(dotnugg);

        // DSEmit.stopMeasuringGas();

        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [2] - deploy NuggftV1
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
        // DSEmit.startMeasuringGas('C');

        assembly {
            nuggft := create2(0x0, add(nuggftCode, 0x20), mload(nuggftCode), nuggftSalt)
        }

        require(nuggft != address(0), 'OOPS:2');
        // DSEmit.stopMeasuringGas();
        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [3] - call NuggftV1 "dotnuggV1StorageProxy()"
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
        // DSEmit.startMeasuringGas('C');

        bytes memory proxy_call = hex'b91b6cbf';

        assembly {
            let ptr := mload(0x40)

            success := staticcall(gas(), nuggft, add(proxy_call, 0x20), mload(proxy_call), ptr, 0x20)

            proxy := mload(ptr)
        }
        require(success, 'OOPS:3');

        require(proxy != address(0), 'OOPS:3/2');

        // DSEmit.stopMeasuringGas();

        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [4] - call DotnuggV1StorageProxy "unsafeBulkStore(uint256[][][])"
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
        // DSEmit.startMeasuringGas('C');

        nuggs = bytes.concat(hex'6ce05d4a', nuggs);

        assembly {
            success := call(gas(), proxy, 0x0, add(nuggs, 0x20), mload(nuggs), 0x0, 0)
        }

        require(success, 'OOPS:4');

        for (uint160 i = 100; i < 200; i += 2) {
            bytes memory trusted_mint = abi.encodeWithSelector(
                bytes4(keccak256('trustedMint(uint160,address)')),
                i,
                0x4E503501C5DEDCF0607D1E1272Bb4b3c1204CC71
            );

            assembly {
                success := call(gas(), nuggft, 0x0, add(trusted_mint, 0x20), mload(trusted_mint), 0x0, 0x0)
            }

            bytes memory trusted_minter = abi.encodeWithSelector(
                bytes4(keccak256('trustedMint(uint160,address)')),
                i + 1,
                0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77
            );

            assembly {
                success := call(gas(), nuggft, 0x0, add(trusted_minter, 0x20), mload(trusted_minter), 0x0, 0x0)
            }

            if (!success) break;
        }

        // DSEmit.stopMeasuringGas();

        /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           [5] - call NuggftV1 "setIsTrusted(address,bool)"
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
        // DSEmit.startMeasuringGas('C');

        bytes memory remove_trust_call = abi.encodeWithSelector(bytes4(keccak256('setIsTrusted(address,bool)')), address(this), false);

        assembly {
            success := call(gas(), nuggft, 0x0, add(remove_trust_call, 0x20), mload(remove_trust_call), 0x0, 0x0)
        }

        require(success, 'OOPS:5');

        __dotnugg = dotnugg;
        __nuggft = nuggft;
        pdc.done();
        // DSEmit.stopMeasuringGas();

        selfdestruct(payable(msg.sender));
    }
}
