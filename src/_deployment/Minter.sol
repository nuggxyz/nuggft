// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.13;

import "../interfaces/nuggftv1/INuggftV1.sol";

contract NuggftV1MinterHelper {
    function offerem(address nuggftv1, uint160 id) external payable {
        INuggftV1(nuggftv1).offer{value: msg.value}(id);

        // payable(msg.sender).transfer(address(this).balance);
    }

    // function claimem(address nuggftv1, uint160 id) external {
    //     INuggftV1(nuggftv1).claim(id);

    //     payable(msg.sender).transfer(address(this).balance);
    // }
}

// contract NuggftV1Minter {
//     address immutable minterHelper;
//     address immutable deployer;

//     uint160[] toClaimFromHelper;
//     uint160[] toClaim;

//     uint256 claimedIndex;
//     uint256 claimedFromHelperIndex;

//     constructor() {
//         minterHelper = address(new NuggftV1MinterHelper());
//         deployer = msg.sender;
//     }

//     function trustMint(
//         address nuggftv1,
//         address to,
//         uint256 start,
//         uint256 amount
//     ) external payable {
//         for (uint256 i = start; i < start + amount; i++) {
//             INuggftV1(nuggftv1).trustedMint{value: INuggftV1(nuggftv1).msp()}(uint160(i), to);
//         }
//         payable(msg.sender).transfer(address(this).balance);
//     }

//     function mint(
//         address nuggftv1,
//         uint160 start,
//         uint160 amount
//     ) external payable {
//         for (uint160 i = start; i < start + amount; i++) {
//             INuggftV1(nuggftv1).mint{value: INuggftV1(nuggftv1).msp()}(uint160(i));
//             uint96 floor = INuggftV1(nuggftv1).eps() * 3;
//             INuggftV1(nuggftv1).approve(nuggftv1, uint160(i));

//             INuggftV1(nuggftv1).sell(uint160(i), floor);

//             (, uint96 amt, ) = INuggftV1(nuggftv1).check(minterHelper, uint160(i));

//             if (i % 2 == 0) {
//                 NuggftV1MinterHelper(minterHelper).offerem{value: amt}(nuggftv1, i);
//                 toClaimFromHelper.push(i);
//             } else {
//                 toClaim.push(i);
//             }
//         }

//         payable(msg.sender).transfer(address(this).balance);
//     }

//     // function claimHelper(address nuggftv1, uint160 amount) external {
//     //     uint256 i = claimedIndex;
//     //     uint256 start = i;
//     //     for (; i < start + amount; i++) {
//     //         NuggftV1MinterHelper(minterHelper).claimem(nuggftv1, toClaim[claimedIndex]);
//     //     }
//     //     claimedIndex = i;
//     //     payable(msg.sender).transfer(address(this).balance);
//     // }

//     // function claimSelf(address nuggftv1, uint160 amount) external {
//     //     uint256 i = claimedIndex;
//     //     uint256 start = i;
//     //     for (; i < start + amount; i++) {
//     //         INuggftV1(nuggftv1).claim(toClaim[claimedIndex]);
//     //     }
//     //     claimedIndex = i;

//     //     payable(msg.sender).transfer(address(this).balance);
//     // }

//     function byebye() external {
//         require(msg.sender == deployer);
//         selfdestruct(payable(msg.sender));
//     }
// }
