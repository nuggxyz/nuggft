// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SSTORE2} from '../libraries/SSTORE2.sol';

import {Vault} from './VaultStorage.sol';
import {VaultPure} from './VaultPure.sol';

library VaultCore {
    using VaultPure for uint256;

    function set(uint256[][][] calldata data) internal {
        require(data.length <= 8 && data.length > 0, 'VAULT:FEAT:0');

        bytes[] memory a = new bytes[](8);

        uint256 ptr;

        for (uint256 i = 0; i < data.length; i++) {
            ptr = ptr.length(i, data[i].length);
            a[i] = abi.encode(data[i]);
        }

        ptr = ptr.addr(SSTORE2.write(abi.encode(a)));

        Vault.ptr().ptrs.push(ptr);

        Vault.ptr().lengthData = Vault.ptr().lengthData.addLengths(ptr);
    }

    function get(uint256 feature, uint256 id) internal view returns (uint256[] memory data) {
        uint256 ptrlen = Vault.ptr().ptrs.length;

        uint256 pointer;
        uint256 cumItems;

        for (uint256 i = 0; i < ptrlen; i++) {
            pointer = Vault.ptr().ptrs[i];
            cumItems += pointer.length(feature);
            if (cumItems > id) break;
            else if (ptrlen == i + 1) require(false, 'VAULT:GET:1 - ID DOES NOT EXIST');
            id -= pointer.length(feature);
        }

        data = abi.decode(abi.decode(SSTORE2.read(pointer.addr()), (bytes[]))[feature], (uint256[][]))[id];
    }

    function getBatch(uint256[] memory ids) internal view returns (uint256[][] memory data) {
        data = new uint256[][](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            data[i] = get(ids[i] >> 12, ids[i] & ShiftLib.mask(12));
        }
    }
}
