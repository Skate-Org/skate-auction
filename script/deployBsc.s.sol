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
import { ISkateAuctionPeriphery } from
    '../src/app/periphery/interfaces/ISkateAuctionPeriphery.sol';
import { SkateAuctionPeriphery } from
    '../src/app/periphery/SkateAuctionPeriphery.sol';

contract DeployScript is Script {
    function run() external {
        console2.log('========= BSC DEPLOYMENTS =========');
        vm.startBroadcast();
        ExecutorRegistry executorRegistryBsc = new ExecutorRegistry();
        executorRegistryBsc.addExecutor(
            address(0x00E3CC76DA72cF673E4429E2d527388956af61ef)
        );

        console2.log('ExecutorRegistryBsc: ', address(executorRegistryBsc));
        ISkateGateway gatewayBsc = new SkateGateway();
        console2.log('SkateGateway: ', address(gatewayBsc));
        gatewayBsc.setExecutorRegistry(address(executorRegistryBsc));
        address impl = address(new SkateNFTPeriphery());
        ISkateNFTPeriphery bscNftPeriphery = SkateNFTPeriphery(
            address(
                new ERC1967Proxy(
                    impl,
                    abi.encodeWithSignature(
                        'initialize(string,string,address)',
                        'Skate NFT Periphery',
                        'SNP',
                        address(gatewayBsc)
                    )
                )
            )
        );
        console2.log('SkateNFTPeriphery: ', address(bscNftPeriphery));
    
        console2.log('Impl: ', address(impl));

        vm.stopBroadcast();
    }
}
