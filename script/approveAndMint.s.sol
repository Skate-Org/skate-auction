// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import 'forge-std/Script.sol';

import { ERC1967Proxy } from
    'openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol';

import { ExecutorRegistry } from '../src/skate/common/ExecutorRegistry.sol';

import { MessageBox } from '../src/skate/kernel/MessageBox.sol';

import { ISkateGateway } from
    '../src/skate/periphery/interfaces/ISkateGateway.sol';
import { SkateGateway } from '../src/skate/periphery/SkateGateway.sol';

import { ISkateNFTPeriphery } from
    '../src/app/periphery/interfaces/ISkateNFTPeriphery.sol';
import { SkateNFTPeriphery } from '../src/app/periphery/SkateNFTPeriphery.sol';

import { ISkateAuction } from '../src/app/kernel/interfaces/ISkateAuction.sol';
import { SkateAuction } from '../src/app/kernel/SkateAuction.sol';
import { SkateAuctionToken } from '../src/app/periphery/SkateAuctionToken.sol';

import { ISkateNFTPeriphery } from
    '../src/app/periphery/interfaces/ISkateNFTPeriphery.sol';
import { SkateNFTPeriphery } from '../src/app/periphery/SkateNFTPeriphery.sol';
import { ISkateAuctionPeriphery } from
    '../src/app/periphery/interfaces/ISkateAuctionPeriphery.sol';
import { SkateAuctionPeriphery } from
    '../src/app/periphery/SkateAuctionPeriphery.sol';

contract MintScript is Script {
    function run() external {
        // vm.startBroadcast();
        vm.startBroadcast(vm.envUint('SKATEUSER1'));
        SkateAuctionToken token =
            SkateAuctionToken(0x00D44864a045AC6eA04bb6EC1B0B4161e7882445);
        token.mint(0xFa87a9fab7F0222f7d6D190A7C7ce6E48547aef4, 10 ** 21);
        // token.approve(address(0x474db0ce37c079b05f8D38F0046581206E38a604), 10**24);
        token.approve(
            address(0xA5fD8531246c2a3446Da44096f3E86d80E5401Df), 10 ** 24
        );
        //token.approve(0x00E3CC76DA72cF673E4429E2d527388956af61ef, 10**24);
        vm.stopBroadcast();
    }
}
