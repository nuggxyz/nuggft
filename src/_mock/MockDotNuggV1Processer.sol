// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../interfaces/IdotnuggV1.sol';
import '../_test/utils/Print.sol';

/**
 * @title dotnugg V1 - onchain encoder/decoder for dotnugg files
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice yoU CAN'T HaVe ImAgES oN THe BlOCkcHAIn
 * @dev hold my margarita
 */
contract MockdotnuggV1Processer is IdotnuggV1Processer {
    function process(uint256[][] memory files, IdotnuggV1Data.Data memory) public view override returns (uint256[] memory resp) {
        for (uint256 i = 0; i < files.length; i++) {
            Print.log(files[i], 'files[i]');
        }
        return files[0];
    }

    function resolveBytes(uint256[] memory file, IdotnuggV1Data.Data memory) public pure override returns (bytes memory res) {
        res = abi.encode(file);
    }

    function resolveData(uint256[] memory, IdotnuggV1Data.Data memory data) public pure override returns (IdotnuggV1Data.Data memory res) {
        res = data;
    }

    function resolveString(uint256[] memory file, IdotnuggV1Data.Data memory) public pure override returns (string memory res) {
        res = string(abi.encode(file));
    }

    function resolveRaw(uint256[] memory file, IdotnuggV1Data.Data memory) public pure override returns (uint256[] memory res) {
        res = file;
    }
}
