// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SSTORE2} from '../libraries/SSTORE2.sol';

import {Vault} from './VaultStorage.sol';
import {VaultPure} from './VaultPure.sol';


import {Print} from '../_test/utils/Print.sol';

library VaultCore {
    using VaultPure for uint256;
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

    function set(uint256[][][] calldata data) internal {
        require(data.length <= 8 && data.length > 0, 'VAULT:FEAT:0');

        bytes[] memory a = new bytes[](8);

        uint256 ptr;

        for (uint8 i = 0; i < data.length; i++) {
            ptr = ptr.length(i, data[i].length.safe16());
            a[i] = abi.encode(data[i]);
        }

        ptr = ptr.addr(SSTORE2.write(abi.encode(a)));

        Vault.spointer().ptrs.push(ptr);

        Vault.spointer().lengthData = Vault.spointer().lengthData.addLengths(ptr);
    }
   // (uint256[][])
    function get(uint8 feature, uint16 id) internal view returns (uint256[] memory data) {
        uint256 ptrlen = Vault.spointer().ptrs.length;

        uint256 pointer;
        uint256 cumItems;
        uint256 orgid = id;
        for (uint256 i = 0; i < ptrlen; i++) {
            pointer = Vault.spointer().ptrs[i];
            cumItems += pointer.length(feature);
            Print.log(cumItems, "cumItems" , id, "id",feature,"feature",pointer.length(feature), "pointer.length(feature)");

            if (cumItems > orgid) break;
            else if (ptrlen == i + 1) require(false, 'VAULT:GET:1 - ID DOES NOT EXIST');
            id -= pointer.length(feature);
        }

        data = abi.decode(abi.decode(SSTORE2.read(pointer.addr()), (bytes[]))[feature], (uint256[][]))[id];
    }

    function getBatch(uint16[] memory ids) internal view returns (uint256[][] memory data) {
        data = new uint256[][](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            data[i] = get((ids[i] >> 12).safe8(), (ids[i] & ShiftLib.mask(12)).safe16());
        }
    }
}
