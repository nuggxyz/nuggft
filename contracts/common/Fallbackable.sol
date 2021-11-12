// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/**
 * @title Testable
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice commonly used and current exec context functions that sometimes require simple overriding in testing
 */
abstract contract Fallbackable {
    receive() external payable {
        if (_fallback_ok()) _fallback();
    }

    fallback() external payable {
        if (_fallback_ok()) _fallback();
    }

    function _fallback() internal virtual;

    function _fallback_ok() internal virtual returns (bool);
}
