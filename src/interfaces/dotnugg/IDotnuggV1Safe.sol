// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

import {IDotnuggV1Resolver} from "./IDotnuggV1Resolver.sol";

interface IDotnuggV1Safe is IDotnuggV1Resolver {
    event Write(uint8 feature, uint8 amount, address sender);

    function init(bytes[] calldata data) external;

    function read(uint8[8] memory ids) external view returns (uint256[][] memory data);

    function read(uint8 feature, uint8 pos) external view returns (uint256[] memory data);

    function exec(uint256 proof, bool base64) external view returns (string memory);

    function exec(uint8[8] memory ids, bool base64) external view returns (string memory);

    // prettier-ignore
    function exec(uint8 feature, uint8 pos, bool base64) external view returns (string memory);

    function lengthOf(uint8 feature) external view returns (uint8 res);

    function locationOf(uint8 feature) external view returns (address res);

    function randOf(uint8 feature, uint256 seed) external view returns (uint8 res);
}
