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

contract DeployScript is Script {
    function run() external {
        // polygon amoy
        console2.log('========= AMOY DEPLOYMENTS =========');
        vm.createSelectFork(vm.rpcUrl('AMOY_RPC'));
        vm.startBroadcast();

        ExecutorRegistry executorRegistryAmoy = new ExecutorRegistry();
        executorRegistryAmoy.addExecutor(
            address(0x00E3CC76DA72cF673E4429E2d527388956af61ef)
        );
        console2.log('ExecutorRegistryAmoy: ', address(executorRegistryAmoy));
        address gatewayAmoy =
            address(0x02856B036D41B4299ccbB7a9280c0b09a9988a21);
        address impl = address(new SkateAuctionPeriphery());

        address auctionTokenAmoy =
            address(new SkateAuctionToken('AuctionToken', 'AT'));
        ISkateAuctionPeriphery auctionPeripheryAmoy = SkateAuctionPeriphery(
            address(
                new ERC1967Proxy(
                    impl,
                    abi.encodeWithSignature(
                        '__SkateAuctionPeriphery_init(string,string,address,address)',
                        'Skate Auction Periphery',
                        'SAP',
                        address(gatewayAmoy),
                        address(0x00D44864a045AC6eA04bb6EC1B0B4161e7882445)
                    )
                )
            )
        );
        console2.log('Impl: ', address(impl));
        console2.log('SkateNFTPeriphery: ', address(auctionPeripheryAmoy));
        vm.stopBroadcast();
    }
}
