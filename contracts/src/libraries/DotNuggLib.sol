import './ItemLib.sol';
import './ShiftLib.sol';

import '../interfaces/IDotNugg.sol';

library DotNuggLib {
    using ShiftLib for uint256;

    struct Storage {
        bytes collection;
        mapping(uint256 => bytes) items;
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
        bytes[] memory data = new bytes[](5);

        data[0] = s.items[item_memory.base()];
        data[1] = s.items[item_memory.item1()];
        data[2] = s.items[item_memory.item2()];
        data[3] = s.items[item_memory.item3()];
        data[4] = s.items[item_memory.item4()];

        string memory uriName = 'NuggFT {#}';
        string memory uriDesc = 'the description';

        return IDotNugg(dotnugg).nuggify(s.collection, data, resolver, uriName, uriDesc, tokenId, '', '');
    }
}
