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
        vm.startBroadcast(vm.envUint('SKATEUSER3'));
        SkateAuctionToken token =
            SkateAuctionToken(0x00D44864a045AC6eA04bb6EC1B0B4161e7882445);
        token.mint(0xc314bBE792F2853a39a7B2EcaFbc472CCdE17158, 10 ** 19);
        token.approve(
            address(0x2Fa5Ac9Be2b60cBE823EEab6D989da2832062601), 10 ** 24
        );
        vm.stopBroadcast();
    }
}
