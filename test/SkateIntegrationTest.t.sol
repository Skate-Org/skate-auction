// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { Test, console2 } from 'forge-std/Test.sol';

import { ERC1967Proxy } from
    'openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol';

import { IMessageBox } from '../src/skate/kernel/interfaces/IMessageBox.sol';
import { MessageBox } from '../src/skate/kernel/MessageBox.sol';

import { IExecutorRegistry } from '../src/skate/common/IExecutorRegistry.sol';
import { ExecutorRegistry } from '../src/skate/common/ExecutorRegistry.sol';

import { ISkateNFT } from '../src/app/kernel/interfaces/ISkateNFT.sol';
import { SkateNFT } from '../src/app/kernel/SkateNFT.sol';

import { ISkateAuction } from '../src/app/kernel/interfaces/ISkateAuction.sol';
import { SkateAuction } from '../src/app/kernel/SkateAuction.sol';

import { ISkateGateway } from
    '../src/skate/periphery/interfaces/ISkateGateway.sol';
import { SkateGateway } from '../src/skate/periphery/SkateGateway.sol';

import { ISkateNFTPeriphery } from
    '../src/app/periphery/interfaces/ISkateNFTPeriphery.sol';
import { SkateNFTPeriphery } from '../src/app/periphery/SkateNFTPeriphery.sol';

import { Utils } from './utils/Utils.sol';

import { Vm } from 'forge-std/Vm.sol';
import 'forge-std/console.sol';

contract SkateNFTIntegration is Test, Utils {
    //owner
    address owner;
    uint256 key;
    // contracts on skate app
    IExecutorRegistry executorRegistry;
    IMessageBox messageBox;
    SkateAuction auction;
    // contracts on L2 (periphery)
    uint256 skateFork;
    uint256 arbFork;
    uint256 opFork;
    uint256 baseFork;
    uint256 bscFork;
    uint256 polygonFork;
    //Arbitrum: 421614
    // Optimism: 420
    // BNB: 97
    // Base: 84532
    //Polygon: 80002
    ISkateNFTPeriphery auctionPeripheryOp;
    ISkateNFTPeriphery auctionPeripheryBase;
    ISkateNFTPeriphery auctionPeripheryArb;
    ISkateNFTPeriphery auctionPeripheryPolygon;
    ISkateNFTPeriphery auctionPeripheryBsc;
    ISkateGateway gatewayOp;
    ISkateGateway gatewayBase;
    ISkateGateway gatewayArb;
    ISkateGateway gatewayPolygon;
    ISkateGateway gatewayBsc;
    IExecutorRegistry registry;
    IExecutorRegistry registryOp;
    IExecutorRegistry registryBase;
    IExecutorRegistry registryArb;
    IExecutorRegistry registryPolygon;
    IExecutorRegistry registryBsc;

    function setUp() external {
        (owner, key) = makeAddrAndKey('test_test_test');
        vm.startPrank(owner);
        // contracts on Skate app
        skateFork = vm.createSelectFork(vm.envString('NOLLIE_RPC'));
        registry = new ExecutorRegistry();
        messageBox = new MessageBox();
        messageBox.setExecutorRegistry(address(registry));
        address auctionImpl = address(new SkateAuction());

        auction = SkateAuction(
            address(
                new ERC1967Proxy(
                    auctionImpl,
                    abi.encodeWithSignature(
                        'initialize(string,string,address)',
                        'Skate',
                        'SKATE',
                        address(messageBox)
                    )
                )
            )
        );

        // contracts on OP (periphery)
        opFork = vm.createSelectFork(vm.envString('OP_RPC'));
        registryOp = new ExecutorRegistry();
        gatewayOp = new SkateGateway();
        gatewayOp.setExecutorRegistry(address(registryOp));
        address impl = address(new SkateNFTPeriphery());
        auctionPeripheryOp = SkateNFTPeriphery(
            address(
                new ERC1967Proxy(
                    impl,
                    abi.encodeWithSignature(
                        'initialize(string,string,address)',
                        'Skate NFT Periphery',
                        'SNP',
                        address(gatewayOp)
                    )
                )
            )
        );
        // contracts on Base (periphery)
        baseFork = vm.createSelectFork(vm.envString('BASE_RPC'));
        registryBase = new ExecutorRegistry();
        gatewayBase = new SkateGateway();
        gatewayBase.setExecutorRegistry(address(registryBase));
        impl = address(new SkateNFTPeriphery());
        auctionPeripheryBase = SkateNFTPeriphery(
            address(
                new ERC1967Proxy(
                    impl,
                    abi.encodeWithSignature(
                        'initialize(string,string,address)',
                        'Skate NFT Periphery',
                        'SNP',
                        address(gatewayBase)
                    )
                )
            )
        );
        // contracts on BSC (periphery)
        bscFork = vm.createSelectFork(vm.envString('BSC_RPC'));
        registryBsc = new ExecutorRegistry();
        gatewayBsc = new SkateGateway();
        gatewayBsc.setExecutorRegistry(address(registryBsc));
        impl = address(new SkateNFTPeriphery());
        auctionPeripheryBsc = SkateNFTPeriphery(
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
        // // contracts on Arb (periphery)
        // arbFork = vm.createSelectFork(vm.envString("ARB_RPC"));
        // registryArb = new ExecutorRegistry();
        // gatewayArb = new SkateGateway();
        // gatewayArb.setExecutorRegistry(address(registryArb));
        // impl = address(new SkateNFTPeriphery());
        // auctionPeripheryArb = SkateNFTPeriphery(
        //     address(
        //         new ERC1967Proxy(
        //             impl,
        //             abi.encodeWithSignature(
        //                 "initialize(string,string,address)",
        //                 "Skate NFT Periphery",
        //                 "SNP",
        //                 address(gatewayArb)
        //             )
        //         )
        //     )
        // );
        // // contracts on L2 (periphery)
        polygonFork = vm.createSelectFork(vm.envString('AMOY_RPC'));
        registryPolygon = new ExecutorRegistry();
        gatewayPolygon = new SkateGateway();
        gatewayPolygon.setExecutorRegistry(address(registryPolygon));
        impl = address(new SkateNFTPeriphery());
        auctionPeripheryPolygon = SkateNFTPeriphery(
            address(
                new ERC1967Proxy(
                    impl,
                    abi.encodeWithSignature(
                        'initialize(string,string,address)',
                        'Skate NFT Periphery',
                        'SNP',
                        address(gatewayPolygon)
                    )
                )
            )
        );
        vm.stopPrank();
    }

    function _placeBid(
        Vm.Wallet memory wallet,
        address user,
        uint256 amount,
        address skateAppAddress,
        uint256 chainId
    )
        internal
    {
        vm.startPrank(owner);
        bytes memory intentCalldata = abi.encodeWithSignature(
            'placeBid(address,uint256,uint256)', user, amount, chainId
        );

        bytes memory signature = _getSignature(
            messageBox.getDataHashForUser(user, skateAppAddress, intentCalldata),
            wallet.privateKey
        );
        IMessageBox.IntentData memory intentData = IMessageBox.IntentData({
            appAddress: skateAppAddress,
            intentCalldata: intentCalldata
        });
        IMessageBox.Intent memory intent = IMessageBox.Intent({
            intentData: intentData,
            user: user,
            signature: signature
        });
        auction.processIntent(intent);
        vm.stopPrank();
    }

    function testFullFlow() external {
        vm.selectFork(skateFork);
        vm.startPrank(owner);
        auction.setChainToPeripheryContract(420, address(auctionPeripheryOp));
        auction.setChainToPeripheryContract(97, address(auctionPeripheryBsc));
        auction.setChainToPeripheryContract(
            421_614, address(auctionPeripheryArb)
        );
        auction.setChainToPeripheryContract(
            80_002, address(auctionPeripheryPolygon)
        );
        auction.setChainToPeripheryContract(
            84_532, address(auctionPeripheryBase)
        );

        registry.addExecutor(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
        vm.selectFork(baseFork);
        registryBase.addExecutor(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
        vm.selectFork(opFork);
        registryOp.addExecutor(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
        vm.selectFork(bscFork);
        registryBsc.addExecutor(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
        vm.selectFork(polygonFork);
        registryPolygon.addExecutor(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
        vm.selectFork(skateFork);
        Vm.Wallet memory wallet1 = _getWallet(1);
        address user1 = wallet1.addr;
        Vm.Wallet memory wallet2 = _getWallet(2);
        address user2 = wallet2.addr;
        Vm.Wallet memory wallet3 = _getWallet(3);
        address user3 = wallet3.addr;
        Vm.Wallet memory wallet4 = _getWallet(4);
        address user4 = wallet4.addr;
        Vm.Wallet memory wallet5 = _getWallet(5);
        address user5 = wallet5.addr;
        address skateAppAddress = address(auction);

        auction.startAuction();
        _placeBid(wallet5, user5, uint256(2 * 10 ** 18), skateAppAddress, 420);
        _placeBid(wallet4, user4, uint256(1 * 10 ** 18), skateAppAddress, 97);
        // _placeBid(
        //     wallet3,
        //     user3,
        //     uint256(3 * 10 ** 18),
        //     skateAppAddress,
        //     421614
        // );
        _placeBid(
            wallet2, user2, uint256(4 * 10 ** 18), skateAppAddress, 80_002
        );
        _placeBid(
            wallet1, user1, uint256(5 * 10 ** 18), skateAppAddress, 84_532
        );
        ISkateAuction.Bid[] memory bids_ = auction.bids();
        //registry.addExecutor(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
        bytes memory intentCalldata =
            abi.encodeWithSignature('stopAuction(address)', owner);
        bytes memory signature = _getSignature(
            messageBox.getDataHashForUser(
                owner, address(auction), intentCalldata
            ),
            key
        );
        IMessageBox.IntentData memory intentData = IMessageBox.IntentData({
            appAddress: address(auction),
            intentCalldata: intentCalldata
        });

        IMessageBox.Intent memory intent = IMessageBox.Intent({
            intentData: intentData,
            user: owner,
            signature: signature
        });
        auction.processIntent(intent);
        vm.stopPrank();
        //execute on Base
        vm.selectFork(baseFork);
        vm.startPrank(owner);
        Vm.Wallet memory signer = _getWallet(1);
        gatewayBase.setSigner(signer.addr);
        vm.stopPrank();
        vm.selectFork(skateFork);
        IMessageBox.Task memory task = messageBox.taskById(1);
        vm.selectFork(baseFork);
        vm.startPrank(owner);
        bytes memory sig = _getSignature(
            gatewayBase.getDataHash(
                uint256(1),
                task.appAddress,
                task.taskCalldata,
                task.user,
                task.chainId
            ),
            signer.privateKey
        );

        ISkateGateway.TaskData memory taskData =
            ISkateGateway.TaskData({ taskId: 1, task: task, signature: sig });
        assertEq(gatewayBase.taskExecuted(1), false);
        vm.startPrank(address(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38));
        gatewayBase.executeTask(taskData);
        assertEq(gatewayBase.taskExecuted(1), true);
    }
}
