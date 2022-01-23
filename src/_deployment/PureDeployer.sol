// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../interfaces/nuggftv1/INuggftV1.sol';

// import '../_test/utils/DSEmit.sol';

contract PureDeployerCallback {
    address public dotnuggV1;

    constructor(address _dotnugg) {
        dotnuggV1 = _dotnugg;
    }

    function done() external {
        selfdestruct(payable(msg.sender));
    }

    function offerem(address nuggftv1, uint160 id) external payable {
        INuggftV1(nuggftv1).offer{value: msg.value}(id);

        // payable(msg.sender).transfer(address(this).balance);
    }

    // function claimem(address nuggftv1, uint160 id) external {
    //     INuggftV1(nuggftv1).claim(id);

    //     payable(msg.sender).transfer(address(this).balance);
    // }
}

//'init(bytes32,bytes32,bytes,bytes,bytes)'
contract PureDeployer {
    address public __dotnugg;
    address public __nuggft;

    address immutable minterHelper;
    address immutable deployer;

    uint160[] toClaimFromHelper;
    uint160[] toClaim;

    uint256 claimedIndex;
    uint256 claimedFromHelperIndex;

    uint160 index = 500;

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

        // dotnugg = new DotnuggV1()

        assembly {
            dotnugg := create2(0x0, add(dotnuggCode, 0x20), mload(dotnuggCode), dotnuggSalt)
        }

        require(dotnugg != address(0), 'OOPS:1');
        // DSEmit.stopMeasuringGas();

        // DSEmit.startMeasuringGas('B2');
        deployer = msg.sender;

        minterHelper = address(new PureDeployerCallback(dotnugg));

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

        // /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //    [5] - call NuggftV1 "setIsTrusted(address,bool)"
        //    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
        // // DSEmit.startMeasuringGas('C');

        // bytes memory add_trust_call = abi.encodeWithSelector(bytes4(keccak256('setIsTrusted(address,bool)')), address(minter), true);

        // assembly {
        //     success := call(gas(), nuggft, 0x0, add(add_trust_call, 0x20), mload(add_trust_call), 0x0, 0x0)
        // }

        // require(success, 'OOPS:5');

        // // DSEmit.stopMeasuringGas();

        // /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //    [5] - call NuggftV1 "setIsTrusted(address,bool)"
        //    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
        // // DSEmit.startMeasuringGas('C');

        // bytes memory remove_trust_call = abi.encodeWithSelector(bytes4(keccak256('setIsTrusted(address,bool)')), address(this), false);

        // assembly {
        //     success := call(gas(), nuggft, 0x0, add(remove_trust_call, 0x20), mload(remove_trust_call), 0x0, 0x0)
        // }

        // require(success, 'OOPS:5');

        __dotnugg = dotnugg;
        __nuggft = nuggft;

        // pdc.done();
        // // DSEmit.stopMeasuringGas();

        // selfdestruct(payable(msg.sender));
    }

    function trustMint(
        address to,
        uint256 start,
        uint256 amount
    ) external payable {
        for (uint256 i = start; i < start + amount; i++) {
            INuggftV1(__nuggft).trustedMint{value: INuggftV1(__nuggft).msp()}(uint160(i), to);
        }
        payable(msg.sender).transfer(address(this).balance);
    }

    function mint(uint160 amount) external payable {
        for (uint160 i = index; i < index + amount; i++) {
            INuggftV1(__nuggft).mint{value: INuggftV1(__nuggft).msp()}(uint160(i));
            uint96 floor = INuggftV1(__nuggft).eps() * 3;
            INuggftV1(__nuggft).approve(__nuggft, uint160(i));

            INuggftV1(__nuggft).sell(uint160(i), floor);

            (, uint96 amt, ) = INuggftV1(__nuggft).check(minterHelper, uint160(i));

            if (i % 2 == 0) {
                PureDeployerCallback(minterHelper).offerem{value: amt}(__nuggft, i);
                toClaimFromHelper.push(i);
            } else {
                toClaim.push(i);
            }
        }

        index += amount;

        payable(msg.sender).transfer(address(this).balance);
    }
}
