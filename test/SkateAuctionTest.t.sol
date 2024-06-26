// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { Test, console2 } from 'forge-std/Test.sol';
import { Ownable } from 'openzeppelin-contracts/contracts/access/Ownable.sol';
import { ERC1967Proxy } from
    'openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol';

import { ISkateNFT } from '../src/app/kernel/interfaces/ISkateNFT.sol';
import { SkateNFT } from '../src/app/kernel/SkateNFT.sol';

import { ISkateApp } from '../src/skate/kernel/interfaces/ISkateApp.sol';
import { SkateApp } from '../src/skate/kernel/SkateApp.sol';

import { IMessageBox } from '../src/skate/kernel/interfaces/IMessageBox.sol';
import { MessageBox } from '../src/skate/kernel/MessageBox.sol';

import { IExecutorRegistry } from '../src/skate/common/IExecutorRegistry.sol';
import { ExecutorRegistry } from '../src/skate/common/ExecutorRegistry.sol';
import { ISkateAuction } from '../src/app/kernel/interfaces/ISkateAuction.sol';
import { SkateAuction } from '../src/app/kernel/SkateAuction.sol';
import { Utils } from '../test/utils/Utils.sol';

import { Vm } from 'forge-std/Vm.sol';

contract SkateAuctionTest is Test, Utils {
    IMessageBox messageBox;
    IExecutorRegistry executorRegistry;
    SkateAuction auction;
    address owner;
    uint256 key;

    error OwnableUnauthorizedAccount(address);

    function setUp() external {
        (owner, key) = makeAddrAndKey('test_test_test');
        vm.startPrank(owner);
        executorRegistry = new ExecutorRegistry();
        messageBox = new MessageBox();
        messageBox.setExecutorRegistry(address(executorRegistry));
        address auctionImpl = address(new SkateAuction());
        auction = SkateAuction(
            address(
                new ERC1967Proxy(
                    auctionImpl,
                    abi.encodeWithSignature(
                        'initialize(string,string,address)',
                        'SkateItem',
                        'SKATE',
                        address(messageBox)
                    )
                )
            )
        );
        vm.stopPrank();
    }

    function testDeployment() external view {
        assertEq(messageBox.executorRegistry(), address(executorRegistry));
        assertEq(address(auction.messageBox()), address(messageBox));
    }

    function testSetChainToPerihpheryContractByNonOwner() external {
        vm.prank(address(0x123));
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUnauthorizedAccount.selector, address(0x123)
            )
        );
        auction.setChainToPeripheryContract(1, address(0x123));
    }

    function testSetChainToPerihpheryContract() external {
        vm.startPrank(owner);
        vm.expectEmit();
        emit ISkateApp.PeripheryContractSet(address(0x123), 1);
        auction.setChainToPeripheryContract(1, address(0x123));
    }

    function testPlaceBidWhenAuctionIsNotActive() external {
        vm.startPrank(owner);
        auction.setChainToPeripheryContract(1, address(0x123));
        executorRegistry.addExecutor(tx.origin);
        Vm.Wallet memory wallet = _getWallet(2);
        address user = wallet.addr;
        address skateAppAddress = address(auction);
        bytes memory intentCalldata = abi.encodeWithSignature(
            'placeBid(address,uint256,uint256)', user, uint256(1 * 10 ** 18), 1
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
        vm.expectRevert(ISkateApp.IntentProcessingReverted.selector);
        auction.processIntent(intent);
    }

    function testPlaceBidWithZeroAddress() external {
        vm.startPrank(owner);
        auction.setChainToPeripheryContract(1, address(0x123));
        executorRegistry.addExecutor(tx.origin);
        Vm.Wallet memory wallet = _getWallet(2);
        address user = wallet.addr;
        address skateAppAddress = address(auction);
        auction.startAuction();
        bytes memory intentCalldata = abi.encodeWithSignature(
            'placeBid(address,uint256,uint256)',
            address(0),
            uint256(1 * 10 ** 18),
            1
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
        vm.expectRevert(
            abi.encodeWithSelector(ISkateApp.IntentProcessingReverted.selector)
        );
        auction.processIntent(intent);
    }

    function testPlaceBidWithZeroBidAmount() external {
        vm.startPrank(owner);
        auction.setChainToPeripheryContract(1, address(0x123));
        executorRegistry.addExecutor(tx.origin);
        Vm.Wallet memory wallet = _getWallet(2);
        address user = wallet.addr;
        address skateAppAddress = address(auction);
        auction.startAuction();
        bytes memory intentCalldata = abi.encodeWithSignature(
            'placeBid(address,uint256,uint256)', user, 0, 1
        );

        bytes memory signature = _getSignature(
            messageBox.getDataHashForUser(user, skateAppAddress, intentCalldata),
            key
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
        vm.expectRevert(
            abi.encodeWithSelector(ISkateApp.IntentProcessingReverted.selector)
        );
        auction.processIntent(intent);
    }

    function testPlaceBid() external {
        vm.startPrank(owner);
        auction.setChainToPeripheryContract(1, address(0x123));
        executorRegistry.addExecutor(tx.origin);
        Vm.Wallet memory wallet = _getWallet(2);
        address user = wallet.addr;
        address skateAppAddress = address(auction);
        auction.startAuction();
        bytes memory intentCalldata = abi.encodeWithSignature(
            'placeBid(address,uint256,uint256)', user, uint256(1 * 10 ** 18), 1
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
    }

    function testStartAuctionByNonOwner() external {
        vm.startPrank(owner);
        auction.setChainToPeripheryContract(1, address(0x123));
        executorRegistry.addExecutor(tx.origin);
        Vm.Wallet memory wallet = _getWallet(2);
        address user = wallet.addr;
        address skateAppAddress = address(auction);
        vm.stopPrank();
        vm.prank(address(0x123));
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUnauthorizedAccount.selector, address(0x123)
            )
        );
        auction.startAuction();
    }

    function testQuicksort() external { }

    function testStopAuctionByNonOwner() external {
        vm.startPrank(owner);
        auction.setChainToPeripheryContract(1, address(0x123));
        executorRegistry.addExecutor(tx.origin);
        //using user account to sign intent
        Vm.Wallet memory wallet = _getWallet(2);
        address user = wallet.addr;
        address skateAppAddress = address(auction);
        auction.startAuction();
        bytes memory intentCalldata =
            abi.encodeWithSignature('stopAuction(address)', user);
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
        vm.expectRevert(
            abi.encodeWithSelector(ISkateApp.IntentProcessingReverted.selector)
        );
        auction.processIntent(intent);
    }

    function _placeBid(
        Vm.Wallet memory wallet,
        address user,
        uint256 amount,
        address skateAppAddress
    )
        internal
    {
        bytes memory intentCalldata = abi.encodeWithSignature(
            'placeBid(address,uint256,uint256)', user, amount, 1
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
    }

    function testStopAuction() external {
        vm.startPrank(owner);
        auction.setChainToPeripheryContract(1, address(0x123));
        executorRegistry.addExecutor(tx.origin);
        address skateAppAddress = address(auction);
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

        auction.startAuction();
        _placeBid(wallet5, user5, uint256(1 * 10 ** 18), skateAppAddress);
        _placeBid(wallet4, user4, uint256(2 * 10 ** 18), skateAppAddress);
        _placeBid(wallet3, user3, uint256(3 * 10 ** 18), skateAppAddress);
        _placeBid(wallet2, user2, uint256(4 * 10 ** 18), skateAppAddress);
        _placeBid(wallet1, user1, uint256(5 * 10 ** 18), skateAppAddress);

        bytes memory intentCalldata =
            abi.encodeWithSignature('stopAuction(address)', owner);
        bytes memory signature = _getSignature(
            messageBox.getDataHashForUser(
                owner, skateAppAddress, intentCalldata
            ),
            key
        );
        IMessageBox.IntentData memory intentData = IMessageBox.IntentData({
            appAddress: skateAppAddress,
            intentCalldata: intentCalldata
        });

        IMessageBox.Intent memory intent = IMessageBox.Intent({
            intentData: intentData,
            user: owner,
            signature: signature
        });
        vm.expectEmit();
        emit ISkateAuction.AuctionEnded(block.timestamp);
        vm.expectEmit();
        emit IMessageBox.TaskSubmitted(
            1,
            IMessageBox.Task(
                address(0x123),
                abi.encodeWithSignature(
                    'mint(address,uint256)', user1, auction.tokenId()
                ),
                owner,
                1
            )
        );
        vm.expectEmit();
        emit IMessageBox.TaskSubmitted(
            2,
            IMessageBox.Task(
                address(0x123),
                abi.encodeWithSignature(
                    'mint(address,uint256)', user2, auction.tokenId()
                ),
                owner,
                1
            )
        );
        vm.expectEmit();
        emit IMessageBox.TaskSubmitted(
            3,
            IMessageBox.Task(
                address(0x123),
                abi.encodeWithSignature(
                    'mint(address,uint256)', user3, auction.tokenId()
                ),
                owner,
                1
            )
        );
        auction.processIntent(intent);
    }
}
