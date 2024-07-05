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

contract PlaceBidScript is Script {
    function run() external {
        // vm.startBroadcast();
        vm.startBroadcast(vm.envUint('SKATEUSER4'));
        SkateAuctionToken token =
            SkateAuctionToken(0x059CD45B8149c79eC40c6Fc2d0E0Ac240a1733Dc);
        token.mint(0x8F34BA87ddFb178A0b1df423CbB077D5db418fAD, 10 ** 19);
        token.approve(
            address(0xbB4f7B5A49cf0f342A9617aCBD93672c620FDe51), 10 ** 24
        );
        vm.stopBroadcast();
    }
}
