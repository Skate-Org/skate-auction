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
        ISkateAuction(auction).setChainToPeripheryContract(
            97, address(0x4c45F7c05ddbdab48EC2797F31C4c13ef48E0054)
        );
        console2.log('Hi');
        //SkateGateway(gateway).setSigner(0x1ec3E56cbE71Db52A44ff2A635c468CAF1Bc77B7);
        //ISkateAuction(auction).startAuction();
        address user = address(0xf4e5780b44147365743D8C6D978adcd15838BBd0);
        bytes memory intentCalldata = abi.encodeWithSignature(
            'placeBid(address,uint256,uint256)', user, 4 * (10 ** 18), 97
        );

        bytes memory signature = _getSignature(
            IMessageBox(messageBox).getDataHashForUser(
                user, auction, intentCalldata
            ),
            vm.envUint('SKATEUSER2')
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
        ISkateAuction(auction).processIntent(intent);
        console2.log('Chain:');
        console2.logUint(97);
        console2.log('Bid Placed by User: ', address(user));

        vm.stopBroadcast();
    }
}
