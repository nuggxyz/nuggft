// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/IDotNugg.sol';

/**
 * @title DotNugg V1 - onchain encoder/decoder for dotnugg files
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice yoU CAN'T HaVe ImAgES oN THe BlOCkcHAIn
 * @dev hold my margarita
 */
contract MockDotNugg is IDotNugg {
    function nuggify(
        bytes memory,
        bytes[] memory,
        address,
        bytes memory
    ) public pure override returns (string memory image) {
        image = 'this is supposed to be an image';
    }
}
