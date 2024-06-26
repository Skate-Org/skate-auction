// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/**
 * @notice contract to emit the intent driven event for all the Skate apps.
 * The Skate relayer listens to the {TaskSubmitted} event to forward it to performer for submission to
 * AVS. The AVS then performs attestations on it by retrieving tasks calldata from this contract.
 */
interface IMessageBox {
    struct IntentData {
        address appAddress;
        bytes intentCalldata;
    }

    struct Intent {
        IntentData intentData;
        address user;
        bytes signature;
    }

    struct Task {
        address appAddress;
        bytes taskCalldata;
        address user;
        uint256 chainId;
    }

    error ZeroAddress();
    error InvalidIntentSignature();
    error NotAnExecutor(address);
    error TaskAndIntentUsersDoNotMatch();
    error IntentIsNotSignedForTheApp();

    event ExecutorRegistryAdded();
    event TaskSubmitted(uint256 taskId, Task task);

    /**
     * @notice sets the executor registry contract's address.
     * executorRegistry_ address of executor registry contract.
     * requirements:
     * - only Skate app owner can call this function.
     */
    function setExecutorRegistry(address executorRegistry_) external;

    /**
     * @notice {submitTasks} is called by the Skate App to emit Task related events for off-chain processing on
     * the AVS. The function also verifies that the passed {Intent} has been signed off-chain by the user.
     * @param tasks list of tasks to be emitted in the event {TaskSubmitted}.
     * @param intent the original intent signed by the user.
     * requirements:
     * - the signature verification of the intent must evaluate to the user's address.
     */
    function submitTasks(
        Task[] calldata tasks,
        Intent calldata intent
    )
        external;

    /**
     * @notice returns the address of {ExecutorRegistry} contract.
     */
    function executorRegistry() external view returns (address);

    /**
     * @notice returns the id of the last task emitted on the {MessageBox} contract.
     */
    function taskId() external view returns (uint256);

    /**
     * @notice returns the data of the {Task} against the provided {taskId_}.
     * @param taskId_ the task id to get the data against.
     * @return task the data of the task.
     */
    function taskById(uint256 taskId_)
        external
        view
        returns (Task memory task);

    /**
     * @notice returns the nonce of the user.
     * @param user address of the user to get the nonce for.
     * @return value current nonce of the user.
     */
    function nonce(address user) external view returns (uint256 value);

    /**
     * @notice returns the hash of the intent data for a {user}.
     * @param user address of the user signing the intent.
     * @param appAddress address of the Skate app.
     * @param intentCalldata calldata of the intent.
     * @return hash of the intent's data.
     */
    function getDataHashForUser(
        address user,
        address appAddress,
        bytes calldata intentCalldata
    )
        external
        view
        returns (bytes32 hash);
}
