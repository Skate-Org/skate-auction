// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { IMessageBox } from '../../../skate/kernel/interfaces/IMessageBox.sol';
import { ISkateApp } from '../../../skate/kernel/interfaces/ISkateApp.sol';

interface ISkateNFT is ISkateApp {
    /**
     * @notice Returns name of NFT
     */
    function name() external view returns (string memory);
    /**
     * @notice Returns symbol of NFT
     */
    function symbol() external view returns (string memory);
    /**
     * @notice Returns tokenId of NFT
     */
    function tokenId() external view returns (uint256);
    /**
     * @notice Returns tokenIds owned by user
     */
    function getTokenIdsByUser(address user)
        external
        view
        returns (uint256[] memory);
    /**
     * @notice Returns tokenIds owned by user
     */
    function getUserByTokenId(uint256 id) external view returns (address);
    /**
     * @notice Returns chain id for a token id
     */
    function getChainIdByTokenId(uint256 id) external view returns (uint256);
    /**
     * @notice Returns respective chain ids for a token id
     */
    function getChainIdsByTokenIds(uint256[] memory ids)
        external
        view
        returns (uint256[] memory chainIds);
    /**
     * @notice Returns used status of a token id
     */
    function getUsedStatusByTokenId(uint256 id) external view returns (bool);
    /**
     * @notice Mints a nft to the user on the specified chainId
     * @param to The address of the user
     * @param chainId The chainId where NFT is minted.
     */
    function mint(
        address user,
        address to,
        uint256 chainId
    )
        external
        returns (IMessageBox.Task[] memory tasks);
    /**
     * @notice Mint
     * @param newURI The updated URI for NFT
     */
    function changeBaseURI(string calldata newURI) external;
}
