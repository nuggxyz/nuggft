// SPDX-License-Identifier: MIT

import 'hardhat/console.sol';

import './ShiftLib.sol';
import './EpochLib.sol';
import './DotNuggLib.sol';

library ItemLib {
    event PreMint(uint256 tokenId, uint256[] items);
    event PopItem(uint256 tokenId, uint256 itemId);
    event PushItem(uint256 tokenId, uint256 itemId);
    event OpenSlot(uint256 tokenId);

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
        DotNuggLib.Storage storage dns,
        uint256 tokenId,
        uint256 genesis
    ) internal {
        (uint256 itemData, uint256 epoch) = EpochLib.calculateSeed(genesis);

        require(itemData != 0, '721:MINT:0');
        require(epoch == tokenId, '721:MINT:1');

        itemData = itemData;

        uint256[] memory items = mint(s, dns, tokenId, itemData);

        emit PreMint(tokenId, items);

        // uint256[] memory amounts = new uint256[](items.length);
        // for (uint256 i = 0; i < amounts.length; i++) {
        //     amounts[i] = 1;
        // }
    }

    function mint(
        Storage storage s,
        DotNuggLib.Storage storage dns,
        uint256 tokenId,
        uint256 data
    ) internal returns (uint256[] memory items) {
        require(s.tokenData[tokenId] == 0, 'IL:M:0');

        uint256 lendata = dns.lengths;

        data = data
            .size(0x0)
            .base(data.base() % 20)
            .item1(data.item1() % lendata.item1())
            .item2(data.item2() % lendata.item2())
            .item3(data.item3() % lendata.item3())
            .item4(data.item4() % lendata.item4());

        s.tokenData[tokenId] = data;

        return data.items();
    }

    // 1/2 byte - size ---- 0-15
    // 1/2 bytes - base -----  0-15
    // 1/2 byte - traits 0-3
    // 1/2 byte - traits 4-7 --- 2

    // 1.5 bytes - head
    // 1.5 bytes - eyes
    // 1.5 bytes - mouth
    // 1.5 bytes - other
    // 1.5 bytes - other2 ---- 7.5  9.5

    // 1.5 bytes - head
    // 1.5 bytes - eyes
    // 1.5 bytes - mouth
    // 1.5 bytes - other
    // 1.5 bytes - other2 ---- 7.5  17

    // 1.5 bytes - head
    // 1.5 bytes - eyes
    // 1.5 bytes - mouth
    // 1.5 bytes - other
    // 1.5 bytes - other2 ---- 7.5  24.5

    // 1.5 bytes - head
    // 1.5 bytes - eyes
    // 1.5 bytes - mouth
    // 1.5 bytes - other
    // 1.5 bytes - other2 ---- 7.5  32

    function pop(
        Storage storage s,
        uint256 tokenId,
        uint256 itemId
    ) internal {
        uint256 data = s.tokenData[tokenId];

        require(data != 0, '1155:STF:0');

        (data, , ) = data.popFirstMatch(uint16(itemId));

        s.tokenData[tokenId] = data;

        s.protocolItems[itemId]++;

        emit PushItem(tokenId, itemId);
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

        (data, ) = data.pushFirstEmpty(uint16(itemId));

        s.tokenData[tokenId] = data;

        emit PushItem(tokenId, itemId);
    }

    function open(Storage storage s, uint256 tokenId) internal {
        uint256 data = s.tokenData[tokenId];
        require(data != 0, '1155:STF:0');

        data = data.size(data.size() + 1);

        s.tokenData[tokenId] = data;

        emit OpenSlot(tokenId);
    }
}
