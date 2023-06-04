// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

contract InitCodeHash {
	function run(address nuggftv1, uint24 id)
		external
		returns (
			address eoa__deployer,
			address contract__deployer,
			bytes32 hash__nuggft,
			bytes32 hash__dotnugg
		)
	{
		assembly {
			let addr := mload(0x40)

			mstore(addr, shl(72, or(shl(176, 0xd6), or(shl(168, 0x94), or(shl(8, caller()), 0x02)))))

			addr := keccak256(addr, 23)
		}

		// console.log('export FACTORY="${deployerAddress}"');
		// console.log('export CALLER="${wallet.address}"');
		// console.log('export INIT_CODE_HASH="${initCodeHash}"');

		// payable(msg.sender).transfer(address(this).balance);
	}
}
