// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import 'forge-std/Script.sol';

import { ERC1967Proxy } from
    'openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol';

import { ExecutorRegistry } from '../src/skate/common/ExecutorRegistry.sol';

import { MessageBox } from '../src/skate/kernel/MessageBox.sol';
import { IMessageBox } from '../src/skate/kernel/interfaces/IMessageBox.sol';
import { ISkateGateway } from
    '../src/skate/periphery/interfaces/ISkateGateway.sol';
import { SkateGateway } from '../src/skate/periphery/SkateGateway.sol';

import { ISkateNFTPeriphery } from
    '../src/app/periphery/interfaces/ISkateNFTPeriphery.sol';
import { SkateNFTPeriphery } from '../src/app/periphery/SkateNFTPeriphery.sol';

import { ISkateAuction } from '../src/app/kernel/interfaces/ISkateAuction.sol';
import { SkateAuction } from '../src/app/kernel/SkateAuction.sol';

contract PlaceBidScript is Script {
    function _getSignature(
        bytes32 hash,
        uint256 privKey
    )
        internal
        pure
        returns (bytes memory)
    {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey, hash);
        return abi.encodePacked(r, s, v);
    }

    function run() external {
        vm.startBroadcast();
        address auction = address(0x59EC62CED14a0ebE75E7b48b65dA4a0db3F777C5);
        address messageBox = address(0x59090778bD757328c8bBb353341F1209cAE66847);
        address gateway = address(0x7e093D035552F39d78DD3691c1837191984064c5);

        SkateAuction(auction).setChainToPeripheryContract(
            80_002, address(0x2Fa5Ac9Be2b60cBE823EEab6D989da2832062601)
        );
        address user = address(0xc314bBE792F2853a39a7B2EcaFbc472CCdE17158);
        bytes memory intentCalldata = abi.encodeWithSignature(
            'placeBid(address,uint256,uint256)', user, 3 * (10 ** 18), 80_002
        );

        bytes memory signature = _getSignature(
            IMessageBox(messageBox).getDataHashForUser(
                user, auction, intentCalldata
            ),
            vm.envUint('SKATEUSER3')
        );
        IMessageBox.IntentData memory intentData = IMessageBox.IntentData({
            appAddress: auction,
            intentCalldata: intentCalldata
        });
        IMessageBox.Intent memory intent = IMessageBox.Intent({
            intentData: intentData,
            user: user,
            signature: signature
        });
        SkateAuction(auction).processIntent(intent);
        console2.log('Chain: 80002');
        console2.log('Bid Placed by User: ', address(user));

        vm.stopBroadcast();
    }
}
