// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { OwnableUpgradeable } from
    '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import { IMessageBox } from './interfaces/IMessageBox.sol';
import { ISkateApp } from './interfaces/ISkateApp.sol';

abstract contract SkateApp is OwnableUpgradeable, ISkateApp {
    IMessageBox _messageBox;
    mapping(uint256 chainId => address perihpheryContract)
        _chainIdToPeripheryContract;
    uint256[] _chainIds;

    modifier onlyContract() {
        require(msg.sender == address(this), OnlyContractCanCall());
        _;
    }

    function __SkateApp_init(address messageBox_) public initializer {
        __Ownable_init(msg.sender);
        _messageBox = IMessageBox(messageBox_);
    }

    function setChainToPeripheryContract(
        uint256 chainId,
        address peripheryContract
    )
        external
        virtual
        override
        onlyOwner
    {
        if (peripheryContract == address(0x0)) {
            uint256 length = _chainIds.length;
            for (uint256 i = 0; i < length; i++) {
                if (_chainIds[i] == chainId) {
                    _chainIds[i] = _chainIds[length - 1];
                    _chainIds.pop();
                    break;
                }
            }
        } else if (_chainIdToPeripheryContract[chainId] == address(0x0)) {
            _chainIds.push(chainId);
        }
        _chainIdToPeripheryContract[chainId] = peripheryContract;
        emit PeripheryContractSet(peripheryContract, chainId);
    }

    function processIntent(IMessageBox.Intent calldata intent)
        external
        virtual
        override
    {
        // pass into a super function
        (bool success, bytes memory data) =
            address(this).call(intent.intentData.intentCalldata);
        require(success, IntentProcessingReverted());

        IMessageBox.Task[] memory tasks = abi.decode(data, (IMessageBox.Task[]));
        _messageBox.submitTasks(tasks, intent);
    }

    function chainIdToPeripheryContract(uint256 chainId)
        public
        view
        override
        returns (address peripheryContract)
    {
        require(
            (peripheryContract = _chainIdToPeripheryContract[chainId])
                != address(0x0),
            ZeroPeripheryContractAddress()
        );
    }

    function messageBox() external view override returns (address) {
        return address(_messageBox);
    }

    function getChainIds()
        external
        view
        override
        returns (uint256[] memory chainIds)
    {
        return _chainIds;
    }
}
