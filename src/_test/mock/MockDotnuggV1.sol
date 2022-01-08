// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '../../interfaces/dotnuggv1/IDotnuggV1.sol';
import '../../interfaces/dotnuggv1/IDotnuggV1Metadata.sol';
import '../../interfaces/dotnuggv1/IDotnuggV1Implementer.sol';
import '../../interfaces/dotnuggv1/IDotnuggV1File.sol';

import {SafeCastLib} from '../../libraries/SafeCastLib.sol';

import '../utils/logger.sol';

library SSTORE2 {
    uint256 internal constant DATA_OFFSET = 1; // We skip the first byte as it's a STOP opcode to ensure the contract can't be called.

    function read2DArray(address pointer, uint256 index) internal view returns (uint256[] memory) {
        return abi.decode(read(pointer), (uint256[][]))[index];
    }

    // function write2DArray(uint256[][] memory data) internal  returns (address pointer) {
    //     return write(abi.encode(data));
    // }

    /*///////////////////////////////////////////////////////////////
                               WRITE LOGIC
    //////////////////////////////////////////////////////////////*/

    function write(uint256[][] calldata data) internal returns (address pointer) {
        // Prefix the bytecode with a STOP opcode to ensure it cannot be called.
        // bytes memory runtimeCode = abi.encodePacked(hex'00', data);

        bytes memory creationCode = abi.encodePacked(
            //---------------------------------------------------------------------------------------------------------------//
            // Opcode  | Opcode + Arguments  | Description  | Stack View                                                     //
            //---------------------------------------------------------------------------------------------------------------//
            // 0x60    |  0x600B             | PUSH1 11     | codeOffset                                                     //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset                                                   //
            // 0x81    |  0x81               | DUP2         | codeOffset 0 codeOffset                                        //
            // 0x38    |  0x38               | CODESIZE     | codeSize codeOffset 0 codeOffset                               //
            // 0x03    |  0x03               | SUB          | (codeSize - codeOffset) 0 codeOffset                           //
            // 0x80    |  0x80               | DUP          | (codeSize - codeOffset) (codeSize - codeOffset) 0 codeOffset   //
            // 0x92    |  0x92               | SWAP3        | codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset)   //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset) //
            // 0x39    |  0x39               | CODECOPY     | 0 (codeSize - codeOffset)                                      //
            // 0xf3    |  0xf3               | RETURN       |                                                                //
            //---------------------------------------------------------------------------------------------------------------//
            hex'60_0B_59_81_38_03_80_92_59_39_F3_00', // Returns all code in the contract except for the first 11 (0B in hex) bytes.
            abi.encode(data)
            // runtimeCode // The bytecode we want the contract to have after deployment. Capped at 1 byte less than the code size limit.
        );

        assembly {
            // Deploy a new contract with the generated creation code.
            // We start 32 bytes into the code to avoid copying the byte length.
            pointer := create(0, add(creationCode, 32), mload(creationCode))
        }

        require(pointer != address(0), 'DEPLOYMENT_FAILED');
    }

    /*///////////////////////////////////////////////////////////////
                               READ LOGIC
    //////////////////////////////////////////////////////////////*/

    function read(address pointer) internal view returns (bytes memory) {
        return readBytecode(pointer, DATA_OFFSET, pointer.code.length - DATA_OFFSET);
    }

    // function read(address pointer, uint256 start) internal view returns (bytes memory) {
    //     start += DATA_OFFSET;

    //     return readBytecode(pointer, start, pointer.code.length - start);
    // }

    // function read(
    //     address pointer,
    //     uint256 start,
    //     uint256 end
    // ) internal view returns (bytes memory) {
    //     start += DATA_OFFSET;
    //     end += DATA_OFFSET;

    //     require(pointer.code.length >= end, 'OUT_OF_BOUNDS');

    //     return readBytecode(pointer, start, end - start);
    // }

    /*///////////////////////////////////////////////////////////////
                         INTERNAL HELPER LOGIC
    //////////////////////////////////////////////////////////////*/

    function readBytecode(
        address pointer,
        uint256 start,
        uint256 size
    ) private view returns (bytes memory data) {
        assembly {
            // Get a pointer to some free memory.
            data := mload(0x40)

            // Update the free memory pointer to prevent overriding our data.
            // We use and(x, not(31)) as a cheaper equivalent to sub(x, mod(x, 32)).
            // Adding 31 to size and running the result through the logic above ensures
            // the memory pointer remains word-aligned, following the Solidity convention.
            mstore(0x40, add(data, and(add(add(size, 32), 31), not(31))))

            // Store the size of the data in the first 32 byte chunk of free memory.
            mstore(data, size)

            // Copy the code into memory right after the 32 bytes we used to store the size.
            extcodecopy(pointer, add(data, 32), start, size)
        }
    }
}

contract DotnuggV1StorageProxy is IDotnuggV1StorageProxy {
    using SafeCastLib for uint256;
    using SafeCastLib for uint16;

    address public immutable dotnuggv1;

    address public implementer;

    modifier requiresTrust() {

        _;
    }

    constructor() {
        dotnuggv1 = msg.sender;
    }

    function init(address _implementer) external {
        require(implementer == address(0) && msg.sender == dotnuggv1, 'C:01');
        implementer = _implementer;
    }

    // Mapping from token ID to owner address
    mapping(uint8 => uint168[]) sstore2Pointers;
    mapping(uint8 => uint8) featureLengths;

    function stored(uint8 feature) public view override returns (uint8 res) {
        return featureLengths[feature];
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                TRUSTED
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function unsafeBulkStore(uint256[][][] calldata data) public override {
        for (uint8 i = 0; i < 8; i++) {
            uint8 len = data[i].length.safe8();


            require(len > 0, 'F:0');

            address ptr = SSTORE2.write(data[i]);

            bool ok = IDotnuggV1Implementer(implementer).dotnuggV1StoreCallback(msg.sender, i, len, ptr);

            require(ok, 'C:0');

            sstore2Pointers[i].push(uint168(uint160(ptr)) | (uint168(len) << 160));

            featureLengths[i] += len;

        }
    }

    function store(uint8 feature, uint256[][] calldata data) public override  returns (uint8 res) {
        uint8 len = data.length.safe8();

        require(len > 0, 'F:0');


        address ptr = SSTORE2.write(data);

        require(IDotnuggV1Implementer(implementer).dotnuggV1StoreCallback(msg.sender, feature, len, ptr), 'C:0');

        sstore2Pointers[feature].push(uint168(uint160(ptr)) | (uint168(len) << 160));

        featureLengths[feature] += len;

        return len;
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                 GET FILES
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function getBatch(uint8[] memory ids) public view returns (uint256[][] memory data) {
        data = new uint256[][](ids.length);

        for (uint8 i = 0; i < ids.length; i++) {
            if (ids[i] == 0) data[i] = new uint256[](0);
            else data[i] = get(i, ids[i]);
        }
    }

    function get(uint8 feature, uint8 pos) public view returns (uint256[] memory data) {
        require(pos != 0, 'F:1');

        pos--;

        uint8 totalLength = featureLengths[feature];

        require(pos < totalLength, 'F:2');

        uint168[] memory ptrs = sstore2Pointers[feature];

        address stor;
        uint8 storePos;

        uint8 workingPos;

        for (uint256 i = 0; i < ptrs.length; i++) {
            uint8 here = uint8(ptrs[i] >> 160);
            if (workingPos + here > pos) {
                stor = address(uint160(ptrs[i]));
                storePos = pos - workingPos;
                break;
            } else {
                workingPos += here;
            }
        }

        require(stor != address(0), 'F:3');

        data = SSTORE2.read2DArray(stor, storePos);
    }
}

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library MinimalProxy {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), 'ERC1167: create failed');
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function deploy(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), 'ERC1167: create2 failed');
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function compute(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function compute(address implementation, bytes32 salt) internal view returns (address predicted) {
        return compute(implementation, salt, address(this));
    }
}



contract MockDotnuggV1 is IDotnuggV1 {


       address public template;

    constructor() {        template = address(new DotnuggV1StorageProxy());
    }

    function register() external override returns (IDotnuggV1StorageProxy proxy) {
        proxy = IDotnuggV1StorageProxy(MinimalProxy.deploy(template, keccak256(abi.encodePacked(msg.sender))));
        proxy.init(msg.sender);
    }

    function proxyOf(address implementer) public view override returns (IDotnuggV1StorageProxy proxy) {
        proxy = IDotnuggV1StorageProxy(MinimalProxy.compute(template, keccak256(abi.encodePacked(implementer))));
        require(address(proxy).code.length != 0, 'P:0');
    }


    function raw(
        address implementer,
        uint256 artifactId,
        address resolver,
        bytes memory data
    ) public view override returns (IDotnuggV1File.Raw memory res) {

        res.metadata = IDotnuggV1Implementer(implementer).dotnuggV1ImplementerCallback(artifactId);

        res.file = proxyOf(implementer).getBatch(res.metadata.ids);
    }

    function proc(
        address implementer,
        uint256 artifactId,
        address resolver,
        bytes memory data
    ) public view override returns (IDotnuggV1File.Processed memory ) {
        IDotnuggV1File.Raw memory _raw = raw(implementer, artifactId, resolver, data);

        for (uint256 i = 0; i < _raw.file.length; i++) {
            logger.log(_raw.file[i], 'files[i]');
        }


    }

    function comp(
        address implementer,
        uint256 artifactId,
        address resolver,
        bytes memory data
    ) public view override returns (IDotnuggV1File.Compressed memory res) {}

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                complex proccessors
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function dat(
        address implementer,
        uint256 artifactId,
        address resolver,
        string memory name,
        string memory desc,
        bool base64,
        bytes calldata data
    ) external view override returns (string memory res) {}

    function img(
        address implementer,
        uint256 artifactId,
        address resolver,
        bool rekt,
        bool background,
        bool stats,
        bool base64,
        bytes memory data
    ) external view override returns (string memory res) {}

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                basic proccessors
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    // function byt(
    //     address implementer,
    //     uint256 artifactId,
    //     address resolver,
    //     bytes memory data
    // ) external view override returns (bytes memory res) {}

    // function str(
    //     address implementer,
    //     uint256 artifactId,
    //     address resolver,
    //     bytes memory data
    // ) external view override returns (string memory res) {}
}
