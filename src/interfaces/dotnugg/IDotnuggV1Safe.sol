// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import {IDotnuggV1Resolver} from "./IDotnuggV1Resolver.sol";

interface IDotnuggV1Safe is IDotnuggV1Resolver {
    event Write(uint8 feature, uint8 amount, address sender);

    // function init(bytes[] calldata data) external;

    function read(uint8[8] memory ids) external view returns (uint256[][] memory data);

    function read(uint8 feature, uint8 pos) external view returns (uint256[] memory data);

    function exec(uint8[8] memory ids, bool base64) external view returns (string memory);

    // prettier-ignore
    function exec(uint8 feature, uint8 pos, bool base64) external view returns (string memory);
}
