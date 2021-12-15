// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import {IERC165} from './IERC721.sol';

interface IProcessResolver is IERC165 {
    function process(
        uint256[][] memory files,
        bytes memory data,
        bytes memory preProcessData
    ) external view returns (uint256[] memory file);

    function supportsInterface(bytes4 interfaceId) external view override returns (bool);
}

interface IPreProcessResolver is IERC165 {
    function preProcess(bytes memory data) external view returns (bytes memory preProcessData);

    function supportsInterface(bytes4 interfaceId) external view override returns (bool);
}

interface IPostProcessResolver is IERC165 {
    function postProcess(
        uint256[] memory file,
        bytes memory data,
        bytes memory preProcessData
    ) external view returns (bytes memory res);

    function supportsInterface(bytes4 interfaceId) external view override returns (bool);
}

interface INuggFtProcessor is IERC165, IPostProcessResolver, IProcessResolver, IPreProcessResolver {
    function postProcessor() external view returns (IPostProcessResolver);

    function preProcessor() external view returns (IPreProcessResolver);

    function processor() external view returns (IProcessResolver);

    function supportsInterface(bytes4 interfaceId) external view override(IERC165, IPostProcessResolver, IProcessResolver, IPreProcessResolver) returns (bool);
}
