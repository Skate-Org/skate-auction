// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import 'forge-std/Test.sol';
import { Vm } from 'forge-std/Vm.sol';

contract Utils is Test {
    function _getSignature(
        bytes32 hash,
        uint256 privKey
    )
        internal
        pure
        returns (bytes memory)
    {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey, hash);
        return abi.encodePacked(r, s, v);
    }

    function _getWallet(uint256 idx) internal returns (Vm.Wallet memory) {
        return vm.createWallet(uint256(keccak256(abi.encode('user', idx))));
    }
}
