import 'hardhat/console.sol';

import './ShiftLib.sol';
import './EpochLib.sol';

library ItemLib {
    event PreMint(uint256 tokenId, uint256[] items);
    event PopItem(uint256 tokenId, uint256 itemId);
    event PushItem(uint256 tokenId, uint256 itemId);

    using ShiftLib for uint256;

    struct Storage {
        mapping(uint256 => uint256) tokenData;
        mapping(uint256 => uint256) protocolItems;
    }

    function infoOf(Storage storage s, uint256 tokenId)
        internal
        view
        returns (
            uint256 base,
            uint256 size,
            uint256[] memory items
        )
    {
        uint256 data = s.tokenData[tokenId];
        items = data.items();
        size = data.size();
        base = data.base();
    }

    function premint(
        Storage storage s,
        uint256 tokenId,
        uint256 genesis
    ) internal {
        (uint256 itemData, uint256 epoch) = EpochLib.calculateSeed(genesis);

        require(itemData != 0, '721:MINT:0');
        require(epoch == tokenId, '721:MINT:1');

        itemData = itemData;

        uint256[] memory items = mint(s, tokenId, itemData);

        emit PreMint(tokenId, items);
    }

    function mint(
        Storage storage s,
        uint256 tokenId,
        uint256 data
    ) internal returns (uint256[] memory items) {
        require(s.tokenData[tokenId] == 0, 'IL:M:0');

        data = data.base(data.base() % 20).size(0x4);

        s.tokenData[tokenId] = data;

        return data.items();
    }

    function pop(
        Storage storage s,
        uint256 tokenId,
        uint256 itemId
    ) internal {
        uint256 data = s.tokenData[tokenId];

        require(data != 0, '1155:STF:0');

        (data, , ) = data.popFirstMatch(uint8(itemId));

        s.tokenData[tokenId] = data;

        s.protocolItems[itemId]++;
    }

    function push(
        Storage storage s,
        uint256 tokenId,
        uint256 itemId
    ) internal {
        uint256 data = s.tokenData[tokenId];
        require(data != 0, '1155:STF:0');

        require(s.protocolItems[itemId] > 0, '1155:SBTF:1');

        s.protocolItems[itemId]++;

        (data, ) = data.pushFirstEmpty(uint8(itemId));

        s.tokenData[tokenId] = data;
    }
}
