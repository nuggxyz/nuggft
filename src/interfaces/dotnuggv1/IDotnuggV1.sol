// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Metadata as Metadata} from './IDotnuggV1Metadata.sol';
import {IDotnuggV1File as File} from './IDotnuggV1File.sol';
import {IDotnuggV1StorageProxy} from './IDotnuggV1StorageProxy.sol';

interface IDotnuggV1 {
    function register() external returns (IDotnuggV1StorageProxy proxy);

    function proxyOf(address implementer) external view returns (IDotnuggV1StorageProxy proxy);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                core processors
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function raw(
        address implementer,
        uint256 artifactId,
        address resolver,
        bytes calldata data
    ) external view returns (File.Raw memory res);

    function proc(
        address implementer,
        uint256 artifactId,
        address resolver,
        bytes calldata data
    ) external view returns (File.Processed memory res);

    function comp(
        address implementer,
        uint256 artifactId,
        address resolver,
        bytes calldata data
    ) external view returns (File.Compressed memory res);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            basic resolved processors
    //    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    // function byt(
    //     address implementer,
    //     uint256 id,
    //     address resolver,
    //     bytes calldata data
    // ) external view returns (bytes memory res);

    // function str(
    //     address implementer,
    //     uint256 id,
    //     address resolver,
    //     bytes calldata data
    // ) external view returns (string memory res);

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            complex resolved processors
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
    function dat(
        address implementer,
        uint256 id,
        address resolver,
        bytes calldata data
    ) external view returns (string memory res);

    function img(
        address implementer,
        uint256 id,
        address resolver,
        bool rekt,
        bool background,
        bool base64,
        bool stats,
        bytes calldata data
    ) external view returns (string memory res);
}
