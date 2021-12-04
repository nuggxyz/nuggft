// SPDX-License-Identifier: MIT

import './ItemLib.sol';
import './ShiftLib.sol';
import '../types/ItemType.sol';
import '../types/LengthType.sol';

import '../interfaces/IDotNugg.sol';

library DotNuggLib {
    using ItemType for uint256;
    using LengthType for uint256;

    struct Storage {
        uint256[] collection;
        mapping(uint256 => uint256) items;
        uint256 lengths;
        mapping(uint256 => address) resolvers;
    }

    function generateTokenURIDefaultResolver(
        Storage storage s,
        ItemLib.Storage storage item_storage,
        address dotnugg,
        uint256 tokenId,
        address defaultResolver
    ) internal view returns (string memory) {
        address res = s.resolvers[tokenId];
        if (res != address(0)) defaultResolver = res;
        return generateTokenURI(s, item_storage, dotnugg, tokenId, defaultResolver);
    }

    /**
     * @notice calcualtes the token uri for a given epoch
     */
    function generateTokenURI(
        Storage storage s,
        ItemLib.Storage storage item_storage,
        address dotnugg,
        uint256 tokenId,
        address resolver
    ) internal view returns (string memory) {
        uint256 item_memory = item_storage.tokenData[tokenId];
        uint256[][] memory data = new uint256[][](6);

        data[0] = loadItem(s, 0, item_memory.base());
        data[1] = loadItem(s, 1, item_memory.item(ItemType.Index.HEAD, 0));
        data[2] = loadItem(s, 2, item_memory.item(ItemType.Index.EYES, 0));
        data[3] = loadItem(s, 3, item_memory.item(ItemType.Index.MOUTH, 0));
        data[4] = loadItem(s, 4, item_memory.item(ItemType.Index.OTHER, 0));
        data[5] = loadItem(s, 5, item_memory.item(ItemType.Index.SPECIAL, 0));

        bytes32 uriname = 'NuggFT {#}';
        bytes32 descrription = 'the description';

        return IDotNugg(dotnugg).nuggify(s.collection, data, resolver, uriname, descrription, tokenId, '');
    }

    // 50/50 chance of main  being 0

    // 5 le

    //

    function addItems(
        Storage storage s,
        ItemType.Index itemType,
        uint256[][] calldata data
    ) internal {
        uint256 lengths = s.lengths;
        uint16 len = s.lengths.length(itemType);
        uint256 itemtypebytes = uint256(itemType) << 96;
        for (uint256 i = 0; i < data.length; i++) {
            uint256 check = uint256(data[i][0]);
            assembly {
                check := and(check, not(0xff))
            }
            s.items[itemtypebytes | len++] = data[i][0];
            for (uint256 j = 1; j < data[i].length; j++) {
                s.items[check | j] = data[i][j];
            }
        }
        s.lengths = lengths.length(itemType, len);
    }

    function loadItem(
        Storage storage s,
        uint8 itemType,
        uint16 id
    ) internal view returns (uint256[] memory array) {
        uint256[] memory data = new uint256[](10);
        data[0] = s.items[(uint256(itemType) << 96) | id];
        uint256 tmp = data[0];
        uint256 check = uint256(tmp);
        assembly {
            check := and(check, not(0xff))
        }
        // res = abi.encodePacked(tmp);
        for (uint256 i = 1; (tmp = s.items[(check) | i]) != 0; i++) {
            // res = abi.encodePacked(res, tmp);
            array[i] = tmp;
        }
    }
}
