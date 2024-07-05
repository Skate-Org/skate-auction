//SPDX-License-Identifier: BUSL-1.1
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
import { ISkateAuctionPeriphery } from
    '../src/app/periphery/interfaces/ISkateAuctionPeriphery.sol';
import { SkateAuctionPeriphery } from
    '../src/app/periphery/SkateAuctionPeriphery.sol';

contract DeployScript is Script {
    function run() external {
        console2.log('========= OP DEPLOYMENTS =========');
        vm.startBroadcast();
        ExecutorRegistry executorRegistryOp = new ExecutorRegistry();
        executorRegistryOp.addExecutor(
            address(0x00E3CC76DA72cF673E4429E2d527388956af61ef)
        );

        console2.log('ExecutorRegistryOp: ', address(executorRegistryOp));
        ISkateGateway gatewayOp = new SkateGateway();
        address impl = address(new SkateAuctionPeriphery());

        console2.log('SkateGateway: ', address(gatewayOp));
        gatewayOp.setExecutorRegistry(address(executorRegistryOp));
        address auctionTokenOp =
            address(new SkateAuctionToken('AuctionToken', 'AT'));
        ISkateAuctionPeriphery auctionPeripheryOp = SkateAuctionPeriphery(
            address(
                new ERC1967Proxy(
                    impl,
                    abi.encodeWithSignature(
                        '__SkateAuctionPeriphery_init(string,string,address,address)',
                        'Skate Auction Periphery',
                        'SAP',
                        address(gatewayOp),
                        auctionTokenOp
                    )
                )
            )
        );
        console2.log('Auction Token: ', address(auctionTokenOp));
        console2.log('SkateNFTPeriphery: ', address(auctionPeripheryOp));

        vm.stopBroadcast();
    }
}
