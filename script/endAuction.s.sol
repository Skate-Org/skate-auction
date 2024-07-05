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

contract EndAuctionScript is Script {
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
        address auction = address(0xA82c5042225B4fa90662e8588A15FD1C3aFA584E);
        address messageBox = address(0x59090778bD757328c8bBb353341F1209cAE66847);
        console2.log('Hi');
        //SkateGateway(gateway).setSigner(0x1ec3E56cbE71Db52A44ff2A635c468CAF1Bc77B7);
        //ISkateAuction(auction).startAuction();
        //SkateAuction(auction).setChainToPeripheryContract(84532, address(0x6bd1a2c15eCB4901208DCC4133D10836f0CDE927));
        address user = address(0x00E3CC76DA72cF673E4429E2d527388956af61ef);
        bytes memory intentCalldata =
            abi.encodeWithSignature('stopAuction(address)', user);

        bytes32 dataHash = IMessageBox(messageBox).getDataHashForUser(
            user, auction, intentCalldata
        );
        console2.logBytes32(dataHash);
        bytes memory signature = _getSignature(
            IMessageBox(messageBox).getDataHashForUser(
                user, auction, intentCalldata
            ),
            vm.envUint('DEPLOYER')
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
        console.logBytes(signature);
        ISkateAuction(auction).processIntent(intent);
        console.log('Auction ended');

        vm.stopBroadcast();
    }
}
