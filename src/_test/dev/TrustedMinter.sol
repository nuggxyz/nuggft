// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../../interfaces/nuggftv1/INuggftV1.sol';

contract NuggftV1TrustedMinter {
    address immutable deployer;

    constructor() {
        deployer = msg.sender;
    }

    function mintem(
        address nuggftv1,
        address to,
        uint256 start,
        uint256 amount
    ) external payable {
        for (uint256 i = start; i < start + amount; i++) {
            INuggftV1(nuggftv1).trustedMint{value: INuggftV1(nuggftv1).minSharePrice()}(uint160(i), to);
        }
    }

    function byebye() external {
        require(msg.sender == deployer);
        selfdestruct(payable(msg.sender));
    }
}
