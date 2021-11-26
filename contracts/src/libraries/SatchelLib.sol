import 'hardhat/console.sol';

library SatchelLib {
    struct Storage {
        uint256 data;
    }

    function pushFirstEmpty(uint256 input, uint8 itemId) internal pure returns (uint256 res, uint8 index) {
        uint256[] memory _items = items(input);
        for (uint8 i = 0; i < _items.length; i++) {
            if (_items[i] == 0) {
                index = i + 1;
                break;
            }
        }

        require(index > 0, 'SL:PFM:0');

        index--;

        res = pushItem(input, itemId, index);
    }

    function popFirstMatch(uint256 input, uint8 itemId)
        internal
        pure
        returns (
            uint256 res,
            uint8 popped,
            uint8 index
        )
    {
        uint256[] memory _items = items(input);
        for (uint8 i = 0; i < _items.length; i++) {
            if (_items[i] == itemId) {
                index = i + 1;
                break;
            }
        }
        require(index > 0, 'SL:PFM:0');

        index--;

        (res, popped) = popItem(input, index);

        require(popped == itemId, 'SL:PFM:1');
    }

    function items(uint256 input) internal pure returns (uint256[] memory res) {
        uint256 s = size(input);
        res = new uint256[](s);
        input >>= 8;
        for (uint256 i = 0; i < s; i++) {
            input >>= 8;
            res[i] = input & 0xff;
        }
    }

    function itemsWithTokenId(uint256 input, uint256 tokenId) internal pure returns (uint256[] memory res) {
        uint256 s = size(input);
        res = new uint256[](s + 1);
        res[0] = tokenId;
        input >>= 8;
        for (uint256 i = 1; i < res.length; i++) {
            input >>= 8;
            res[i] = input & 0xff;
        }
    }

    function pushItem(
        uint256 input,
        uint8 item,
        uint8 at
    ) internal pure returns (uint256 res) {
        assembly {
            let offset := add(16, mul(8, at))
            res := and(input, not(shl(offset, 0xff)))
            res := or(input, shl(offset, item))
        }
    }

    function popItem(uint256 input, uint8 at) internal pure returns (uint256 res, uint8 item) {
        assembly {
            let offset := add(16, mul(8, at))
            res := and(input, not(shl(offset, 0xff)))
            item := shr(offset, input)
        }
    }

    function size(uint256 input, uint8 update) internal pure returns (uint256 res) {
        assembly {
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00)
            res := or(update, input)
        }
    }

    function size(uint256 input) internal pure returns (uint8 res) {
        assembly {
            res := and(input, 0xff)
        }
    }

    function body(uint256 input) internal pure returns (uint8 res) {
        assembly {
            res := and(shr(0x8, input), 0xff)
        }
    }

    function body(uint256 input, uint8 update) internal pure returns (uint256 res) {
        assembly {
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00ff)
            res := or(shl(0x8, update), input)
        }
    }
}
