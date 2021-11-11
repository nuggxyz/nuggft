// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import '../../lib/DSTest.sol';
import '../../../contracts/logic/Decoder.sol';
import '../../../contracts/interfaces/IDotNugg.sol';
import '../../../contracts/libraries/BytesLib.sol';
import '../../../contracts/logic/Rgba.sol';
import '../../../contracts/logic/Matrix.sol';
import '../../../contracts/DotNugg.sol';
import '../../../contracts/SvgNuggIn.sol';

contract ItemTest is DotNugg, DSTest, SvgNuggIn {
    using BytesLib for bytes;

    bytes sample1 =
        hex'6e6e6e6e75676709c800000e002c00f19325e500eb8a12e500f9b042e500c96619e500a84b1ee500f49f35e52121000000001723fe23ff23fd23fa23fc23f923fb23f80f0f0f0f0f0f0f0f0f0f0e5c0f015130633222520f005030653124500f005031653222500f005031663222500e5131651035500e50336436500e50346435500e50346435500e503111306534500e5034651033500e5035641132500e50346633500e50346930500e503569500e503569500f50321169500f50341067510f5034116124500f00504033601026500f0050402032622341500f0050412031622341500f00522031612241510f035a0f0f0f0f0f0f0f0f0f';
    bytes sample2 =
        hex'6e6e6e6e7567670613050010001a003100000000990000eae1991105090500000705140a112211041102122012021f1f1313060a0600000705160a1809122212041101142014011f1f17';

    bytes sample3 =
        hex'6e6e6e6e756767289c030010001a0035000000009900e100e1990a04060200000700130015211221100010211000102110001300130e05080300000700140214001022100210221222142210001022100210221000140214';

    bytes sample4 =
        hex'6e6e6e6e7567672e66030010001f004000f85c0f9900fb1a069900ffdb3c990a04070300000701100310021020021020011020302100203021001020021020010f0507030000070110061004102010041020100210203023001020302300102010041020100410061003';

    bytes sampleCollection =
        hex'6e6e6e6e7567672109000d00456e6e6e6e7567672ab3020010001a002600000000ff00ffffffff0702040100000711021302110b03060100000722042310200420102304226e6e6e6e7567673431060010001a0022000000009900ffffffff03010201000007120501030100000714';

    //  function test_ItemFunTimes() public {
    //      //   IDotNugg.Item memory item = Decoder.parseItem(sample1);

    //      //   assertTrue(item.feature == 0);
    //      //   assertTrue(item.versions.length == 1);
    //      //   assertTrue(item.versions[0].width == 33);

    //      //   for (uint256 i = 0; i < 6; i++) {
    //      //       // emit log_named_bytes(string(abi.encodePacked(i)), item.versions[0].data);
    //      //   }
    //      //   assertTrue(item.pallet.length == 7);
    //      //   IDotNugg.Matrix memory mat = Matrix.create(33, 33);

    //      //   Matrix.set(mat, item.versions[0].data, item.pallet, item.versions[0].width);
    //      //   nuggify(sampleCollection, _items, _resolver, data);

    //      bytes[] memory sampleItems = new bytes[](1);

    //      sampleItems[0] = sample1;
    //      //   sampleItems[1] = sample2;
    //      //   sampleItems[2] = sample3;
    //      //   sampleItems[3] = sample4;

    //      string memory res = nuggify(sampleCollection, sampleItems, address(0), '');
    //      //   assertTrue(22 == 33);
    //      //   IDotNugg.Item memory item = Decoder.parseItem(sample1);
    //  }
}
