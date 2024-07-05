// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import 'forge-std/Script.sol';

import { ERC1967Proxy } from
    'openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol';

import { ExecutorRegistry } from '../src/skate/common/ExecutorRegistry.sol';

import { MessageBox } from '../src/skate/kernel/MessageBox.sol';
import { IMessageBox } from '../src/skate/kernel/interfaces/IMessageBox.sol';
import { ISkateGateway } from
    '../src/skate/periphery/interfaces/ISkateGateway.sol';
import { SkateGateway } from '../src/skate/periphery/SkateGateway.sol';

import { ISkateNFTPeriphery } from
    '../src/app/periphery/interfaces/ISkateNFTPeriphery.sol';
import { SkateNFTPeriphery } from '../src/app/periphery/SkateNFTPeriphery.sol';

import { ISkateAuction } from '../src/app/kernel/interfaces/ISkateAuction.sol';
import { SkateAuction } from '../src/app/kernel/SkateAuction.sol';

contract PlaceBidScript is Script {
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

    function run() external {
        vm.startBroadcast();
        address auction = address(0x59EC62CED14a0ebE75E7b48b65dA4a0db3F777C5);
        address messageBox = address(0x59090778bD757328c8bBb353341F1209cAE66847);
        SkateAuction(auction).startAuction();
        SkateAuction(auction).setChainToPeripheryContract(
            84_532, address(0xA5fD8531246c2a3446Da44096f3E86d80E5401Df)
        );
        address user = address(0xFa87a9fab7F0222f7d6D190A7C7ce6E48547aef4);
        bytes memory intentCalldata = abi.encodeWithSignature(
            'placeBid(address,uint256,uint256)', user, 5 * (10 ** 18), 84_532
        );

        bytes memory signature = _getSignature(
            IMessageBox(messageBox).getDataHashForUser(
                user, auction, intentCalldata
            ),
            vm.envUint('SKATEUSER1')
        );
        IMessageBox.IntentData memory intentData = IMessageBox.IntentData({
            appAddress: auction,
            intentCalldata: intentCalldata
        });
        IMessageBox.Intent memory intent = IMessageBox.Intent({
            intentData: intentData,
            user: user,
            signature: signature
        });
        SkateAuction(auction).processIntent(intent);
        vm.stopBroadcast();
    }
}
