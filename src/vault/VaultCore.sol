// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {SafeCastLib} from '../libraries/SafeCastLib.sol';
import {ShiftLib} from '../libraries/ShiftLib.sol';
import {SSTORE2} from '../libraries/SSTORE2.sol';

import {Vault} from './VaultStorage.sol';
import {VaultPure} from './VaultPure.sol';
import {VaultView} from './VaultView.sol';
import {ProofPure} from '../proof/ProofPure.sol';
import {TokenView} from '../token/TokenView.sol';

import {Print} from '../_test/utils/Print.sol';

library VaultCore {
    using VaultPure for uint256;
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

    function setResolver(uint160 tokenId, address to) internal {
        require(TokenView.isApprovedOrOwner(msg.sender, tokenId), 'T:0');

        Vault.spointer().resolvers[tokenId] = to;
    }

    function trustedSet(uint8 feature, uint256[][] calldata data) internal {
        uint8 len = data.length.safe8();

        require(len > 0, 'VC:0');

        uint168 working = uint168(len) << 160;

        address ptr = SSTORE2.write(abi.encode(data));

        Vault.spointer().ptrs[feature].push(uint160(ptr) | working);

        uint256 cache = Vault.spointer().lengthData;

        uint8[] memory lengths = VaultPure.getLengths(cache);

        lengths[feature] += len;

        Vault.spointer().lengthData = VaultPure.setLengths(cache, lengths);
    }

    function get(uint8 feature, uint8 pos) internal view returns (uint256[] memory data) {
        uint8 totalLength = VaultPure.getLengths(Vault.spointer().lengthData)[feature];

        require(pos < totalLength, 'VC:1');

        uint168[] memory ptrs = Vault.spointer().ptrs[feature];

        address store;
        uint8 storePos;

        uint8 workingPos;

        for (uint256 i = 0; i < ptrs.length; i++) {
            uint8 here = uint8(ptrs[i] >> 160);
            if (workingPos + here > pos) {
                store = address(uint160(ptrs[i]));
                storePos = pos - workingPos;
                break;
            } else {
                workingPos += here;
            }
        }

        require(store != address(0), 'VC:2');

        data = abi.decode(SSTORE2.read(address(uint160(store))), (uint256[][]))[storePos];
    }

    function getBatch(uint8[] memory ids) internal view returns (uint256[][] memory data) {
        data = new uint256[][](ids.length);

        for (uint8 i = 0; i < ids.length; i++) {
            data[i] = get(i, ids[i]);
        }
    }
}
