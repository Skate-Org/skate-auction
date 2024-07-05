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

contract DeployScript is Script {
    function run() external {
        console2.log('========= NOLLIE DEPLOYMENTS =========');
        vm.startBroadcast();

        ExecutorRegistry executorRegistrySkate = new ExecutorRegistry();
        executorRegistrySkate.addExecutor(
            0x00E3CC76DA72cF673E4429E2d527388956af61ef
        );

        console2.log('ExecutorRegistrySkate: ', address(executorRegistrySkate));

        MessageBox messageBox = new MessageBox();
        console2.log('MessageBox: ', address(messageBox));

        messageBox.setExecutorRegistry(address(executorRegistrySkate));

        address nftImpl = address(new SkateAuction());
        console2.log('SkateNFT implementation: ', nftImpl);

        SkateAuction nft = SkateAuction(
            address(
                new ERC1967Proxy(
                    nftImpl,
                    abi.encodeWithSignature(
                        'initialize(string,string,address)',
                        'Skateboard',
                        'SKATEBOARD',
                        address(0x59090778bD757328c8bBb353341F1209cAE66847)
                    )
                )
            )
        );
        console2.log('SkateNFT proxy: ', address(nft));
        vm.stopBroadcast();
    }
}
