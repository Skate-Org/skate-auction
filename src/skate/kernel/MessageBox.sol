// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { Ownable } from 'openzeppelin-contracts/contracts/access/Ownable.sol';
import { ECDSA } from
    'openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol';

import { IExecutorRegistry } from '../common/IExecutorRegistry.sol';
import { IMessageBox } from './interfaces/IMessageBox.sol';

contract MessageBox is IMessageBox, Ownable {
    IExecutorRegistry _executorRegistry;
    uint256 _taskId;
    mapping(uint256 => IMessageBox.Task) _taskById;
    mapping(address => uint256) _nonce;

    constructor() Ownable(msg.sender) { }

    function setExecutorRegistry(address executorRegistry_)
        external
        onlyOwner
    {
        require(executorRegistry_ != address(0x0), ZeroAddress());
        _executorRegistry = IExecutorRegistry(executorRegistry_);

        emit ExecutorRegistryAdded();
    }

    function submitTasks(
        IMessageBox.Task[] calldata tasks,
        IMessageBox.Intent calldata intent
    )
        external
        override
    {
        // check tx.origin is a whitelisted executor
        require(
            _executorRegistry.isExecutor(tx.origin), NotAnExecutor(tx.origin)
        );
        require(
            msg.sender == intent.intentData.appAddress,
            IntentIsNotSignedForTheApp()
        );
        require(
            ECDSA.recover(
                getDataHashForUser(
                    intent.user,
                    intent.intentData.appAddress,
                    intent.intentData.intentCalldata
                ),
                intent.signature
            ) == intent.user,
            InvalidIntentSignature()
        );

        // increase the nonce for the user.
        _nonce[intent.user]++;

        for (uint256 i = 0; i < tasks.length; i++) {
            require(
                tasks[i].user == intent.user, TaskAndIntentUsersDoNotMatch()
            );
            uint256 taskId_ = ++_taskId;
            _taskById[taskId_] = tasks[i];
            emit TaskSubmitted(taskId_, tasks[i]);
        }
    }

    function executorRegistry() external view override returns (address) {
        return address(_executorRegistry);
    }

    function taskId() external view returns (uint256) {
        return _taskId;
    }

    function taskById(uint256 taskId_)
        external
        view
        returns (Task memory task)
    {
        task = _taskById[taskId_];
    }

    function getDataHashForUser(
        address user,
        address appAddress,
        bytes calldata intentCalldata
    )
        public
        view
        override
        returns (bytes32 hash)
    {
        hash = keccak256(
            abi.encodePacked(user, _nonce[user], appAddress, intentCalldata)
        );
    }

    function nonce(address user)
        external
        view
        override
        returns (uint256 value)
    {
        value = _nonce[user];
    }
}
