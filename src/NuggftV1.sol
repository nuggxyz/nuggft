// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.15;

import {INuggftV1, INuggftV1Execute, INuggftV1Lens} from "@nuggft-v1-core/src/interfaces/INuggftV1.sol";
import {IERC165} from "@nuggft-v1-core/src/interfaces/IERC165.sol";
import {IERC721, IERC721Metadata} from "@nuggft-v1-core/src/interfaces/IERC721.sol";

import {INuggftV1Migrator} from "@nuggft-v1-core/src/interfaces/INuggftV1Migrator.sol";

import {IDotnuggV1} from "@dotnugg-v1-core/src/IDotnuggV1.sol";

import {DotnuggV1Lib} from "@dotnugg-v1-core/src/DotnuggV1Lib.sol";

import {decodeMakingPrettierHappy} from "@nuggft-v1-core/src/libraries/BigOleLib.sol";

import {NuggftV1Loan} from "@nuggft-v1-core/src/core/NuggftV1Loan.sol";
import {NuggftV1Globals} from "@nuggft-v1-core/src/core/NuggftV1Globals.sol";

/// @title NuggftV1
/// @author nugg.xyz - danny7even and dub6ix - 2022
contract NuggftV1 is NuggftV1Loan {
	constructor() payable NuggftV1Globals() {}

	/// @inheritdoc INuggftV1Execute
	function extract() external requiresTrust {
		uint256 cache = stake;

		payable(msg.sender).transfer((cache << 160) >> 160);

		cache = (cache >> 96) << 96;

		emit Stake(bytes32(cache));
	}

	/* ///////////////////////////////////////////////////////////////////
                            MIGRATION
    /////////////////////////////////////////////////////////////////// */

	/// @inheritdoc INuggftV1Execute
	function setMigrator(address _migrator) external requiresTrust {
		migrator = _migrator;

		emit MigratorV1Updated(_migrator);
	}

	/// @inheritdoc INuggftV1Execute
	function migrate(uint24 tokenId) external {
		if (migrator == address(0)) _panic(Error__0x81__MigratorNotSet);

		// stores the proof before deleting the nugg
		uint256 proof = proofOf(tokenId);

		uint96 ethOwed = subStakedShare(tokenId);

		INuggftV1Migrator(migrator).nuggftMigrateFromV1{value: ethOwed}(tokenId, proof, msg.sender);

		emit MigrateV1Sent(migrator, tokenId, bytes32(proof), msg.sender, ethOwed);
	}

	/// @notice removes a staked share from the contract,
	/// @dev this is the only way to remove a share
	/// @dev caculcates but does not handle dealing the eth - which is handled by the two helpers above
	/// @dev ensures the user is the owner of the nugg
	/// @param tokenId the id of the nugg being unstaked
	/// @return ethOwed -> the amount of eth owed to the unstaking user - equivilent to "ethPerShare"
	function subStakedShare(uint24 tokenId) internal returns (uint96 ethOwed) {
		uint256 cache = agency[tokenId];

		if (address(uint160(cache)) != msg.sender || uint8(cache >> 254) != 0x01) {
			_panic(Error__0x77__NotOwner);
		}

		cache = stake;

		// handles all logic not related to staking the nugg
		delete agency[tokenId];
		delete proof[tokenId];

		ethOwed = calculateEthPerShare(cache);

		cache -= 1 << 192;
		cache -= uint256(ethOwed) << 96;

		stake = cache;

		emit Stake(bytes32(cache));
		emit Transfer(msg.sender, address(0), tokenId);
	}

	/* ///////////////////////////////////////////////////////////////////
                           ERC165 SUPPORT
    /////////////////////////////////////////////////////////////////// */

	/// @inheritdoc IERC165
	function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
		return
			interfaceId == type(IERC721).interfaceId || //
			interfaceId == type(IERC721Metadata).interfaceId ||
			interfaceId == type(IERC165).interfaceId;
	}

	/* ///////////////////////////////////////////////////////////////////
                            ERC721 METADATA
    /////////////////////////////////////////////////////////////////// */

	/// @inheritdoc IERC721Metadata
	function name() public pure override returns (string memory) {
		return "Nugg Fungible Token V1";
	}

	/// @inheritdoc IERC721Metadata
	function symbol() public pure override returns (string memory) {
		return "NUGGFT";
	}

	/// @inheritdoc IERC721Metadata
	function tokenURI(uint256 tokenId) public view virtual override returns (string memory res) {
		res = string(
			dotnuggv1.encodeJson(
				abi.encodePacked(
					'{"name":"NUGGFT","description":"Nugg Fungible Token V1","image":"',
					imageURI(tokenId),
					'","properites":',
					xnuggftv1.ploop(uint24(tokenId)),
					"}"
				),
				true
			)
		);
	}

	/* ///////////////////////////////////////////////////////////////////
                            SUPPLEMENTAL METADATA
    /////////////////////////////////////////////////////////////////// */

	/// @inheritdoc INuggftV1Lens
	function imageURI(uint256 tokenId) public view override returns (string memory res) {
		res = dotnuggv1.exec(decodedCoreProofOf(uint24(tokenId)), true);
	}

	/// @inheritdoc INuggftV1Lens
	function imageSVG(uint256 tokenId) public view override returns (string memory res) {
		res = dotnuggv1.exec(decodedCoreProofOf(uint24(tokenId)), false);
	}

	/// @inheritdoc INuggftV1Lens
	/// @dev this may seem like the dumbest function of all time - and it is
	/// it allows us to break up the "gas" usage over multiple view calls
	/// it increases the chance that services like the graph will compute the dotnugg image
	function image123(
		uint256 tokenId,
		bool base64,
		uint8 chunk,
		bytes calldata prev
	) public view override returns (bytes memory res) {
		if (chunk == 1) {
			res = abi.encode(dotnuggv1.read(decodedCoreProofOf((uint24(tokenId)))));
		} else if (chunk == 2) {
			(uint256[] memory calced, uint256 dat) = dotnuggv1.calc(decodeMakingPrettierHappy(prev));
			res = abi.encode(calced, dat);
		} else if (chunk == 3) {
			(uint256[] memory calced, uint256 dat) = abi.decode(prev, (uint256[], uint256));
			res = bytes(dotnuggv1.svg(calced, dat, base64));
		}
	}

	function tokensOf(address you) external view override returns (uint24[] memory res) {
		res = new uint24[](10000);

		uint24 iter = 0;

		uint24 epoch = epoch();

		for (uint24 i = 1; i < epoch; i++) if (you == _ownerOf(i, epoch)) res[iter++] = i;

		(uint24 start, uint24 end) = premintTokens();

		for (uint24 i = start; i < end; i++) if (you == _ownerOf(i, epoch)) res[iter++] = i;

		assembly {
			mstore(res, iter)
		}
	}

	/// @notice prefromance function returns the owner of the nugg given the epoch
	function _ownerOf(uint256 tokenId, uint24 epoch) internal view returns (address res) {
		uint256 cache = agencyOf(uint24(tokenId));

		if (cache == 0) return address(0);

		if (cache >> 254 == 0x03 && (cache << 2) >> 232 >= epoch) {
			return address(this);
		}

		return address(uint160(cache));
	}

	/* ///////////////////////////////////////////////////////////////////
                            ERC721 SUPPORT
    /////////////////////////////////////////////////////////////////// */

	/// @inheritdoc IERC721
	function ownerOf(uint256 tokenId) public view override returns (address res) {
		res = _ownerOf(uint24(tokenId), epoch());

		// revert as per EIP-721 specificaition
		if (res == address(0)) _panic(Error__0x78__TokenDoesNotExist);
	}

	/// @inheritdoc IERC721
	function balanceOf(address you) external view override returns (uint256 acc) {
		return this.tokensOf(you).length;
	}

	/// @inheritdoc IERC721
	function approve(address, uint256) external payable override {
		_panic(Error__0x69__Wut);
	}

	/// @inheritdoc IERC721
	function setApprovalForAll(address, bool) external pure override {
		_panic(Error__0x69__Wut);
	}

	/// @inheritdoc IERC721
	function getApproved(uint256 tokenId) external view override returns (address) {
		// if token does not exist: revert as per EIP-721 specificaition
		if (agencyOf(uint24(tokenId)) == 0) _panic(Error__0x78__TokenDoesNotExist);

		// if token does exist: return 0 address to indicate no approval
		return address(0);
	}

	/// @inheritdoc IERC721
	function isApprovedForAll(address, address) external pure override returns (bool) {
		return false;
	}

	//prettier-ignore
	/// @inheritdoc IERC721
	function transferFrom(address, address, uint256) external payable override {
        _panic(Error__0x69__Wut);
    }

	//prettier-ignore
	/// @inheritdoc IERC721
	function safeTransferFrom(address, address, uint256) external payable override {
        _panic(Error__0x69__Wut);
    }

	//prettier-ignore
	/// @inheritdoc IERC721
	function safeTransferFrom(address, address, uint256, bytes memory) external payable override {
        _panic(Error__0x69__Wut);
    }
}
