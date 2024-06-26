// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { Test, console2 } from 'forge-std/Test.sol';
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

import { Utils } from '../test/utils/Utils.sol';

import { Vm } from 'forge-std/Vm.sol';

contract SkateNFTTest is Test, Utils {
    error OwnableUnauthorizedAccount(address);

    IExecutorRegistry executorRegistry;
    IMessageBox messageBox;
    ISkateNFT nft;

    function setUp() external {
        executorRegistry = new ExecutorRegistry();
        messageBox = new MessageBox();
        messageBox.setExecutorRegistry(address(executorRegistry));
        address nftImpl = address(new SkateNFT());
        nft = SkateNFT(
            address(
                new ERC1967Proxy(
                    nftImpl,
                    abi.encodeWithSignature(
                        'initialize(string,string,address)',
                        'SkateNFT',
                        'NFT',
                        address(messageBox)
                    )
                )
            )
        );
    }

    function testDeployment() external view {
        assertEq(messageBox.executorRegistry(), address(executorRegistry));
        assertEq(address(nft.messageBox()), address(messageBox));
    }

    function testSetChainToPerihpheryContractByNonOwner() external {
        vm.prank(address(0x123));
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUnauthorizedAccount.selector, address(0x123)
            )
        );
        nft.setChainToPeripheryContract(1, address(0x123));
    }

    function testSetChainToPerihpheryContract() external {
        vm.expectEmit();
        emit ISkateApp.PeripheryContractSet(address(0x123), 1);
        nft.setChainToPeripheryContract(1, address(0x123));
    }

    function testExecuteIntentWhenPeripheryContractIsNotSet() external {
        executorRegistry.addExecutor(tx.origin);
        Vm.Wallet memory wallet = _getWallet(0);
        address user = wallet.addr;
        address skateAppAddress = wallet.addr;
        bytes memory intentCalldata = abi.encodeWithSignature(
            'mint(address,address,uint256)', user, user, 1
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
        nft.processIntent(intent);
    }

    function testExecuteIntentWhenExecutorIsNotSet() external {
        nft.setChainToPeripheryContract(1, address(0x123));
        Vm.Wallet memory wallet = _getWallet(1);
        address user = wallet.addr;
        address skateAppAddress = address(0x123);
        bytes memory intentCalldata = abi.encodeWithSignature(
            'mint(address,address,uint256)', user, user, 1
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
            abi.encodeWithSelector(
                IMessageBox.NotAnExecutor.selector, tx.origin
            )
        );
        nft.processIntent(intent);
    }

    function testDirectlyCallingMint() external {
        vm.expectRevert(ISkateApp.OnlyContractCanCall.selector);
        nft.mint(address(this), address(this), 1);
    }

    function testExecuteIntent() external {
        nft.setChainToPeripheryContract(1, address(0x123));
        executorRegistry.addExecutor(tx.origin);

        Vm.Wallet memory wallet = _getWallet(2);
        address user = wallet.addr;
        address skateAppAddress = address(nft);
        bytes memory intentCalldata = abi.encodeWithSignature(
            'mint(address,address,uint256)', user, user, 1
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
        uint256 taskId = messageBox.taskId() + 1;
        vm.expectEmit();
        emit IMessageBox.TaskSubmitted(
            taskId,
            IMessageBox.Task(
                address(0x123),
                abi.encodeWithSignature('mint(address,uint256)', user, 1),
                user,
                1
            )
        );
        nft.processIntent(intent);
    }
}
