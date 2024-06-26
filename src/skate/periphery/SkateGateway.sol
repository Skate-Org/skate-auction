// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { Ownable } from 'openzeppelin-contracts/contracts/access/Ownable.sol';
import { ECDSA } from
    'openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol';

import { IExecutorRegistry } from '../common/IExecutorRegistry.sol';
import { ISkateGateway } from './interfaces/ISkateGateway.sol';

contract SkateGateway is Ownable, ISkateGateway {
    IExecutorRegistry _executorRegistry;
    address _signer;
    mapping(uint256 => bool) _taskExecuted;

    modifier onlyExecutor() {
        require(_executorRegistry.isExecutor(msg.sender), NotAnExecutor());
        _;
    }

    constructor() Ownable(msg.sender) { }

    function setExecutorRegistry(address executorRegistry_)
        external
        override
        onlyOwner
    {
        require(executorRegistry_ != address(0x0), ZeroAddress());
        _executorRegistry = IExecutorRegistry(executorRegistry_);

        emit ExecutorRegistryAdded();
    }

    function setSigner(address signer_) external override onlyOwner {
        require(signer_ != address(0x0), ZeroAddress());
        _signer = signer_;

        emit SignerSet(signer_);
    }

    function executeTask(TaskData calldata taskData)
        external
        override
        onlyExecutor
        returns (bool success, bytes memory returndata)
    {
        require(
            ECDSA.recover(
                getDataHash(
                    taskData.taskId,
                    taskData.task.appAddress,
                    taskData.task.taskCalldata,
                    taskData.task.user,
                    taskData.task.chainId
                ),
                taskData.signature
            ) == _signer,
            InvalidTaskSignature()
        );
        require(!_taskExecuted[taskData.taskId], TaskAlreadyExecuted());
        require(taskData.task.chainId == block.chainid, IncorrectChainId());

        _taskExecuted[taskData.taskId] = true;
        (success, returndata) =
            taskData.task.appAddress.call(taskData.task.taskCalldata);

        emit TaskExecuted(taskData.taskId, taskData.task);
    }

    function getDataHash(
        uint256 taskId,
        address appAddress,
        bytes calldata taskCalldata,
        address user,
        uint256 chainId
    )
        public
        pure
        override
        returns (bytes32 hash)
    {
        hash = keccak256(
            abi.encodePacked(taskId, appAddress, taskCalldata, user, chainId)
        );
    }

    function signer() external view returns (address signer_) {
        signer_ = _signer;
    }

    function taskExecuted(uint256 taskId)
        external
        view
        override
        returns (bool isExecuted)
    {
        isExecuted = _taskExecuted[taskId];
    }

    function executorRegistry()
        external
        view
        override
        returns (address executorRegistry_)
    {
        executorRegistry_ = address(_executorRegistry);
    }
}
