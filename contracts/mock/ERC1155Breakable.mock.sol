// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

// import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

import '../src/interfaces/INuggSwap.sol';
// import './ERC721Breakable.mock.sol';
import '../src/libraries/SatchelLib.sol';

// import '../src/interfaces/IERC1155Nuggable.sol';

abstract contract MockERC1155Breakable {
    using SatchelLib for uint256;

    address private immutable nuggswap;

    mapping(uint256 => SatchelLib.Storage) private sl_state;
    mapping(uint256 => uint256) private nuggswap_storage;

    constructor(address _nuggswap) {
        // nuggft = msg.sender;
        nuggswap = _nuggswap;
    }

    function set(uint256 tokenId, uint256 data) internal {
        // require(msg.sender == nuggft, '');
        require(sl_state[tokenId].data == 0, '1155:SET:0');
        sl_state[tokenId].data = data;
    }

    function itemsOf(uint256 tokenId) public view returns (uint256[] memory items) {
        require(sl_state[tokenId].data != 0, '1155:IO:0');
        items = sl_state[tokenId].data.items();
    }

    function get(uint256 tokenId) internal view returns (uint256 data) {
        // require(msg.sender == nuggft, '');
        // require(sl_state[tokenId].data == 0, '');
        data = sl_state[tokenId].data;
    }

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    // /**
    //  * @dev See {IERC165-supportsInterface}.
    //  */
    // function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
    //     return
    //         interfaceId == type(IERC1155).interfaceId ||
    //         // interfaceId == type(IERC1155MetadataURI).interfaceId ||
    //         super.supportsInterface(interfaceId);
    // }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _balanceOf(address account, uint256 id) private view returns (uint256 res) {
        uint256 tokenId = uint160(account);
        require(account != address(0), '1155:BO:0');
        // uint256 amount = MockERC721Breakable(nuggft).balanceOf(account);
        // for (uint256 i = 0; i < amount; i++) {
        //     uint256 tokenId = MockERC721Breakable(nuggft).tokenOfOwnerByIndex(account, i);
        uint256[] memory items = sl_state[tokenId].data.items();
        for (uint256 j = 0; j < items.length; j++) {
            if (items[j] == id) res++;
        }
        // }
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, 'ERC1155: accounts and ids length mismatch');

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = _balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    // /**
    //  * @dev See {IERC1155-setApprovalForAll}.
    //  */
    // function setApprovalForAll(address operator, bool approved) public virtual override {
    //     require(false, 'MANAGED:EXTERNALLY');
    // }

    // /**
    //  * @dev See {IERC1155-isApprovedForAll}.
    //  */
    // function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
    //     return nuggft == msg.sender;
    // }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    // function _amountArray(uint256 length) private pure returns (uint256[] memory) {
    //     uint256[] memory array = new uint256[](length);
    //     for (uint256 i = 0; i < length; i++) {
    //         array[i] = 1;
    //     }
    //     return array;
    // }

    function amountArray(uint256 length) internal pure returns (uint256[] memory res) {
        res = new uint256[](length);
        for (uint256 i = 0; i < length; i++) res[i] = 1;
    }

    function _safeMint(uint256 tokenId) internal {
        // uint256 tokenId = abi.decode(_data, (uint256));

        // require(msg.sender == nuggft, '1155:SBTF:0');

        uint256[] memory items = sl_state[tokenId].data.items();

        emit TransferBatch(address(this), address(0), tokenAddress(tokenId), items, amountArray(items.length));
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     * the only time that batch are sent is when a nugg is created, so this can only be called by nuggft
     */
    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory _data
    ) public virtual {
        require(msg.sender == nuggswap, '1155:SBTF:0');

        (uint256 itemId, uint256 tokenId, bool from) = abi.decode(_data, (uint256, uint256, bool));

        // require(amount == 1);
        require(msg.sender == nuggswap, '1155:SBTF:0');

        uint256 data = sl_state[tokenId].data;
        require(data != 0, '1155:STF:0');

        if (from) {
            require(nuggswap_storage[itemId] > 0, '1155:SBTF:1');

            nuggswap_storage[itemId]++;

            (data, ) = data.pushFirstEmpty(uint8(itemId));

            sl_state[tokenId].data = data;
        } else {
            (data, , ) = data.popFirstMatch(uint8(itemId));

            sl_state[tokenId].data = data;

            nuggswap_storage[itemId]++;
        }

        emit TransferBatch(
            nuggswap,
            from ? nuggswap : tokenAddress(tokenId),
            from ? tokenAddress(tokenId) : nuggswap,
            _asSingletonArray(itemId),
            amountArray(1)
        );
    }

    function tokenAddress(uint256 tokenId) internal pure returns (address res) {
        res = address(uint160((0x42069 << 140) | tokenId));
    }
}
