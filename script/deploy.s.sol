// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import "forge-std/Script.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

import {ERC1967Proxy} from "openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {ExecutorRegistry} from "../src/skate/common/ExecutorRegistry.sol";

import {MessageBox} from "../src/skate/kernel/MessageBox.sol";

import {ISkateGateway} from "../src/skate/periphery/interfaces/ISkateGateway.sol";
import {SkateGateway} from "../src/skate/periphery/SkateGateway.sol";

import {ISkateNFTPeriphery} from "../src/app/periphery/interfaces/ISkateNFTPeriphery.sol";
import {SkateNFTPeriphery} from "../src/app/periphery/SkateNFTPeriphery.sol";

import {ISkateAuction} from "../src/app/kernel/interfaces/ISkateAuction.sol";
import {SkateAuction} from "../src/app/kernel/SkateAuction.sol";

contract DeployScript is Script {
    function run() external {
        // Skatechain deployments:
        console2.log("========= NOLLIE DEPLOYMENTS =========");
        vm.createSelectFork(vm.rpcUrl("NOLLIE_RPC"));
        vm.startBroadcast(vm.envUint("PK"));

        ExecutorRegistry executorRegistrySkate = new ExecutorRegistry();
        console2.log("ExecutorRegistrySkate: ", address(executorRegistrySkate));

        MessageBox messageBox = new MessageBox();
        console2.log("MessageBox: ", address(messageBox));

        messageBox.setExecutorRegistry(address(executorRegistrySkate));

        address nftImpl = address(new SkateAuction());
        //        console2.log('SkateNFT implementation: ', nftImpl);

        SkateAuction nft = SkateAuction(
            address(
                new ERC1967Proxy(
                    nftImpl,
                    abi.encodeWithSignature(
                        "initialize(string,string,address)",
                        "SkateAuction",
                        "SKATE",
                        address(messageBox)
                    )
                )
            )
        );
        vm.makePersistent(address(nft));
        console2.log("SkateNFT proxy: ", address(nft));
        vm.stopBroadcast();

        // polygon amoy
        console2.log("========= AMOY DEPLOYMENTS =========");
        vm.createSelectFork(vm.rpcUrl("AMOY_RPC"));
        vm.startBroadcast(vm.envUint("PK"));

        ExecutorRegistry executorRegistryAmoy = new ExecutorRegistry();
        console2.log("ExecutorRegistryAmoy: ", address(executorRegistryAmoy));
        ISkateGateway gatewayAmoy = new SkateGateway();
        console2.log("SkateGateway: ", address(gatewayAmoy));
        gatewayAmoy.setExecutorRegistry(address(executorRegistryAmoy));
        address impl = address(new SkateNFTPeriphery());
        ISkateNFTPeriphery amoyNftPeriphery = SkateNFTPeriphery(
            address(
                new ERC1967Proxy(
                    impl,
                    abi.encodeWithSignature(
                        "initialize(string,string,address)",
                        "Skate NFT Periphery",
                        "SNP",
                        address(gatewayAmoy)
                    )
                )
            )
        );
        console2.log("SkateNFTPeriphery: ", address(amoyNftPeriphery));
        vm.stopBroadcast();

        console2.log("========= BASE DEPLOYMENTS =========");
        vm.createSelectFork(vm.rpcUrl("BASE_RPC"));
        vm.startBroadcast(vm.envUint("PK"));

        ExecutorRegistry executorRegistryBase = new ExecutorRegistry();
        console2.log("ExecutorRegistryBase: ", address(executorRegistryBase));
        ISkateGateway gatewayBase = new SkateGateway();
        console2.log("SkateGateway: ", address(gatewayBase));
        gatewayBase.setExecutorRegistry(address(executorRegistryBase));
        impl = address(new SkateNFTPeriphery());
        ISkateNFTPeriphery baseNftPeriphery = SkateNFTPeriphery(
            address(
                new ERC1967Proxy(
                    impl,
                    abi.encodeWithSignature(
                        "initialize(string,string,address)",
                        "Skate NFT Periphery",
                        "SNP",
                        address(gatewayBase)
                    )
                )
            )
        );
        //         console2.log("SkateNFTPeriphery: ", address(baseNftPeriphery));
        //         vm.stopBroadcast();

        //         console2.log("========= BSC DEPLOYMENTS =========");
        //         vm.createSelectFork(vm.rpcUrl("BSC_RPC"));
        //         vm.startBroadcast(vm.envUint("PK"));

        //         ExecutorRegistry executorRegistryBsc = new ExecutorRegistry();
        //         console2.log("ExecutorRegistryBsc: ", address(executorRegistryBsc));
        //         ISkateGateway gatewayBsc = new SkateGateway();
        //         console2.log("SkateGateway: ", address(gatewayBsc));
        //         gatewayBsc.setExecutorRegistry(address(executorRegistryBsc));
        //         impl = address(new SkateNFTPeriphery());
        //         ISkateNFTPeriphery bscNftPeriphery = SkateNFTPeriphery(
        //             address(
        //                 new ERC1967Proxy(
        //                     impl,
        //                     abi.encodeWithSignature(
        //                         "initialize(string,string,address)",
        //                         "Skate NFT Periphery",
        //                         "SNP",
        //                         address(gatewayBsc)
        //                     )
        //                 )
        //             )
        //         );
        //         console2.log("SkateNFTPeriphery: ", address(bscNftPeriphery));
        //         vm.stopBroadcast();

        //         console2.log("========= OP DEPLOYMENTS =========");
        //         vm.createSelectFork(vm.rpcUrl("OP_RPC"));
        //         vm.startBroadcast(vm.envUint("PK"));

        //         ExecutorRegistry executorRegistryOp = new ExecutorRegistry();
        //         console2.log("ExecutorRegistryOp: ", address(executorRegistryOp));
        //         ISkateGateway gatewayOp = new SkateGateway();
        //         console2.log("SkateGateway: ", address(gatewayOp));
        //         gatewayOp.setExecutorRegistry(address(executorRegistryOp));
        //         impl = address(new SkateNFTPeriphery());
        //         ISkateNFTPeriphery opNftPeriphery = SkateNFTPeriphery(
        //             address(
        //                 new ERC1967Proxy(
        //                     impl,
        //                     abi.encodeWithSignature(
        //                         "initialize(string,string,address)",
        //                         "Skate NFT Periphery",
        //                         "SNP",
        //                         address(gatewayOp)
        //                     )
        //                 )
        //             )
        //         );
        //         console2.log("SkateNFTPeriphery: ", address(opNftPeriphery));
        //         vm.stopBroadcast();

        //         // vm.createSelectFork(vm.rpcUrl("NOLLIE_RPC"));
        //         // vm.startBroadcast(vm.envUint("PK"));
        //         // SkateAuction(address(nft)).setChainToPeripheryContract(
        //         //     80_002,
        //         //     address(amoyNftPeriphery)
        //         // );
        //         // vm.stopBroadcast();
    }
}
