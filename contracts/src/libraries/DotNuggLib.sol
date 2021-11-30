import './ItemLib.sol';
import './ShiftLib.sol';

import '../interfaces/IDotNugg.sol';

library DotNuggLib {
    using ShiftLib for uint256;

    struct Storage {
        bytes collection;
        mapping(bytes32 => bytes32) items;
        mapping(bytes32 => bytes) itemsOld;
        uint256 lengths;
        mapping(uint256 => address) resolvers;
    }

    // struct Pointer {

    // }

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
        bytes32[][] memory data = new bytes32[][](5);

        data[0] = loadItem(s, 0, item_memory.base());
        data[1] = loadItem(s, 1, item_memory.item1());
        data[2] = loadItem(s, 2, item_memory.item2());
        data[3] = loadItem(s, 3, item_memory.item3());
        data[4] = loadItem(s, 4, item_memory.item4());

        string memory uriName = 'NuggFT {#}';
        string memory uriDesc = 'the description';

        return IDotNugg(dotnugg).nuggify(s.collection, data, resolver, uriName, uriDesc, tokenId, '', '');
    }

    function addItems(
        Storage storage s,
        uint8 itemType,
        bytes32[][] calldata data
    ) internal {
        require(itemType < 5, 'DNL:AI:1');
        uint256 lengths = s.lengths;
        uint16 len = s.lengths.item(itemType);
        bytes1 itemtypebytes = bytes1(itemType);

        for (uint256 i = 0; i < data.length; i++) {
            uint256 check = uint256(data[i][0]);
            assembly {
                check := and(check, not(0xff))
            }
            s.items[(itemtypebytes << 96) | bytes2(len++)] = data[i][0];
            for (uint256 j = 1; j < data[i].length; j++) {
                s.items[bytes32(check | j)] = data[i][j];
            }
        }
        s.lengths = lengths.item(len, itemType);
    }

    function addItemsOld(
        Storage storage s,
        uint8 itemType,
        bytes[] calldata data
    ) internal {
        require(itemType < 5, 'DNL:AI:1');
        uint256 lengths = s.lengths;
        uint16 len = s.lengths.item(itemType);
        bytes1 itemtypebytes = bytes1(itemType);

        for (uint256 i = 0; i < data.length; i++) {
            s.itemsOld[(itemtypebytes << 96) | bytes2(len++)] = data[i];
            // uint256 check = uint256(data[i][0]);
            // assembly {
            //     check := and(check, not(0xff))
            // }
            // s.items[(itemtypebytes << 96) | bytes2(len++)] = data[i][0];
            // for (uint256 j = 1; j < data[i].length; j++) {
            //     s.items[bytes32(check | j)] = data[i][j];
            // }
        }
        s.lengths = lengths.item(len, itemType);
    }

    function loadItem(
        Storage storage s,
        uint8 itemType,
        uint16 id
    ) internal view returns (bytes32[] memory data) {
        data = new bytes32[](10);
        data[0] = s.items[(bytes1(itemType) << 96) | bytes2(id)];

        bytes32 tmp = data[0];
        uint256 check = uint256(data[0]);
        assembly {
            check := and(check, not(0xff))
        }
        for (uint256 i = 1; (tmp = s.items[bytes32((check) | i)]) != 0; i++) {
            data[i] = tmp;
        }
    }
}
