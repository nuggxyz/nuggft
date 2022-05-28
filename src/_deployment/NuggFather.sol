// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

import {NuggftV1} from "../NuggftV1.sol";

import {DotnuggV1} from "../../../dotnugg-v1-core/src/DotnuggV1.sol";

contract NuggFather {
    DotnuggV1 public immutable dotnugg;

    // NuggftV1 public immutable nuggft;

    bytes24 internal constant PROXY_INIT_CODE = 0x6f3D356020803603903D363D3D37F533FF3d5260106010f3;
    // bytes16 internal constant PROXY_INIT_CODE = 0x67363d3d37363d34f03d5260086018f3;

    bytes32 internal constant PROXY_INIT_CODE_HASH = 0x5aeb4c9d93f11ba17adc1e4ddc81cde5f92cd424aad117ddcd63637276423d6f;

    constructor(bytes32 seed) {
        dotnugg = new DotnuggV1();

        // nuggft = new NuggftV1(address(dotnugg));

        save(abi.encodePacked(seed, type(NuggftV1).creationCode, abi.encode(address(dotnugg))));
    }

    //693D356020803603903D363D3D37F533FF3d52600f6016f3
    // 0x693D356020803603903D363D3D37F533FF3d5260106010f3
    // +=====+==============+==============+========================================+
    // | pos |    opcode    |   name       |          stack                         |
    // +=====+==============+==============+========================================+
    //  PROXY_INIT_CODE [14 bytes]: 0x69_RUNTIME_3d_52_60_10_60_10_f3
    //   - exectued during "create"
    // +=====+==============+==============+========================================+
    //   00    69 [RUNTIME]   PUSH15         [RUNTIME]
    //   17    3D             RETSIZE        [0] RUNTIME
    //   18    52             MSTORE         {0 RUNTIME} | RUNTIME -> mem[16,32)
    //   19    60 [10]        PUSH1          [16]
    //   21    60 [10]        PUSH1          [16] 16
    //   23    F3             RETURN         {16 16} | mem[16, 32) -> contract code
    // +=====+==============+==============+========================================+
    //  RUNTIME [10 bytes]: 0x3D_35_60_20_80_36_03_90_3D_36_3D_3D_37_F5_33_FF
    //   - executed during "call" // 3D356020803603903D363D3D37F533FF
    //   - saved during "create"
    // +=====+==============+==============+========================================+
    //   01    3D             RETSIZE        [0]
    //   02    35             CALLDATALOAD   {0} -> msg.data[0,32) -> SALT
    //   03    60 [20]        PUSH 1         [32] SALT
    //   05    80             DUP 1          [32] 32 SALT
    //   06    36             CALLDATASIZE   [CDS] 32 32 SALT
    //   07    03             SUB            {CDS-32} -> LEN  ... 32 SALT
    //   08    90             SWAP 1         32 LEN SALT
    //   09    3D             RETSIZE        [0] 32 LEN SALT
    //   10    36             CALLDATASIZE   [CDS] 0 32 LEN SALT
    //   11    3D             RETSIZE        [0] CDS  0 32 LEN SALT
    //   12    3D             RETSIZE        [0] 0 CDS 0 32 LEN SALT
    //   13    37             CALLDATACOPY   {0 0 CDS} | calldata -> mem[0, CDS) ... 0 32 LEN SALT
    //   14    F5             CREATE2        {0 32 LEN SALT} | mem[32, LEN) -> contract code
    //   15    33             CALLER         [msg.sender]
    //   16    FF             SELFDESTRUCT
    // +=====+==============+==============+========================================+

    function save(bytes memory data) internal returns (address) {
        address proxy;

        assembly {
            mstore(0x0, PROXY_INIT_CODE)

            proxy := create(0, 0, 24)
        }

        require(proxy != address(0), "NOPE");

        (bool fileDeployed, ) = proxy.call(data);

        require(fileDeployed, "NOPE2");

        return proxy;
    }

    function location(address safe, uint256 seed) internal pure returns (address res) {
        bytes32 h = PROXY_INIT_CODE_HASH;

        assembly {
            // [======================================================================
            let mptr := mload(0x40)

            // [0x00] 0x00000000000000000000000000000000000000000000000000000000000000
            // [0x20] 0x00000000000000000000000000000000000000000000000000000000000000
            // [0x40] 0x________________________FREE_MEMORY_PTR_______________________
            // =======================================================================]

            // [======================================================================
            mstore8(0x00, 0xff)
            mstore(0x01, shl(96, safe))
            mstore(0x15, seed)
            mstore(0x35, h)

            // [0x00] 0xff>_________________safe__________________>___________________
            // [0x20] 0x________________feature___________________>___________________
            // [0x40] 0x________________PROXY_INIT_CODE_HASH______////////////////////
            // =======================================================================]

            // 1 proxy #1 - dotnugg for nuggft (or a clone of dotnugg)
            // to calculate proxy #2 - address proxy #1 + feature(0-7) + PROXY#2_INIT_CODE
            // 8 proxy #2 - things that get self dest

            // 8 proxy #3 - nuggs
            // to calc proxy #3 = address proxy #2 + [feature(1-8)] = nonce
            // nonces for contracts start at 1

            // bytecode -> proxy #2 -> contract with items (dotnugg file) -> kills itelf

            // [======================================================================
            mstore(0x02, shl(96, keccak256(0x00, 0x55)))
            mstore8(0x00, 0xD6)
            mstore8(0x01, 0x94)
            mstore8(0x16, 0x01)

            // [0x00] 0xD694_________ADDRESS_OF_FILE_CREATOR________01////////////////
            // [0x20] ////////////////////////////////////////////////////////////////
            // [0x40] ////////////////////////////////////////////////////////////////
            // =======================================================================]

            res := shr(96, shl(96, keccak256(0x00, 0x17)))

            // [======================================================================
            mstore(0x00, 0x00)
            mstore(0x20, 0x00)
            mstore(0x40, mptr)

            // [0x00] 0x00000000000000000000000000000000000000000000000000000000000000
            // [0x20] 0x00000000000000000000000000000000000000000000000000000000000000
            // [0x40] 0x________________________FREE_MEMORY_PTR_______________________
            // =======================================================================]
        }
    }
}
