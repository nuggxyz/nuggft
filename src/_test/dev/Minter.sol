// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../../interfaces/nuggftv1/INuggftV1.sol';

contract NuggftV1MinterHelper {
    function delegateem(address nuggftv1, uint160 id) external payable {
        INuggftV1(nuggftv1).delegate{value: msg.value}(id);
    }

    function claimem(address nuggftv1, uint160 id) external {
        INuggftV1(nuggftv1).claim(id);

        payable(msg.sender).transfer(address(this).balance);
    }
}

contract NuggftV1Minter {
    address immutable minterHelper;
    address immutable deployer;

    constructor() {
        minterHelper = address(new NuggftV1MinterHelper());
        deployer = msg.sender;
    }

    function trustMint(
        address nuggftv1,
        address to,
        uint256 start,
        uint256 amount
    ) external payable {
        for (uint256 i = start; i < start + amount; i++) {
            INuggftV1(nuggftv1).trustedMint{value: INuggftV1(nuggftv1).minSharePrice()}(uint160(i), to);
        }
    }

    function mint(
        address nuggftv1,
        uint160 start,
        uint160 amount
    ) external payable {
        for (uint160 i = start; i < start + amount; i++) {
            INuggftV1(nuggftv1).mint{value: INuggftV1(nuggftv1).minSharePrice()}(uint160(i));
            uint96 floor = INuggftV1(nuggftv1).ethPerShare() * 3;
            INuggftV1(nuggftv1).approve(nuggftv1, uint160(i));

            INuggftV1(nuggftv1).swap(uint160(i), floor);

            (, uint96 amt, ) = INuggftV1(nuggftv1).valueForDelegate(minterHelper, uint160(i));

            if (i % 2 == 0) NuggftV1MinterHelper(minterHelper).delegateem{value: amt}(nuggftv1, i);
        }
    }

    function claim(
        address nuggftv1,
        uint160 start,
        uint160 amount
    ) external {
        for (uint160 i = start; i < start + amount; i++) {
            NuggftV1MinterHelper(minterHelper).claimem(nuggftv1, i);
        }
    }

    function byebye() external {
        require(msg.sender == deployer);
        selfdestruct(payable(msg.sender));
    }
}
