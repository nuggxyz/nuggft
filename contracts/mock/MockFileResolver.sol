// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import '../interfaces/IDotNugg.sol';
import '../interfaces/IDotNuggFileResolver.sol';

import '../erc165/IERC165.sol';

import '../libraries/Uint.sol';

contract MockFileResolver is IDotNuggFileResolver {
    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return interfaceId == type(IDotNuggFileResolver).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function resolveFile(IDotNugg.Matrix memory, bytes memory) public pure returns (bytes memory res, string memory fileType) {
        return (hex'0000', 'dotnugg');
    }
}
