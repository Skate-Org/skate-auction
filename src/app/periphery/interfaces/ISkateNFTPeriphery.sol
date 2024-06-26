// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { ISkateAppPeriphery } from
    '../../../skate/periphery/interfaces/ISkateAppPeriphery.sol';

interface ISkateNFTPeriphery is ISkateAppPeriphery {
    event Transfer(address from, address to, uint256 tokenId);

    /**
     * @notice updates nft balances to the diffeernt
     */
    function mint(address to, uint256 tokenId) external;
    /**
     * @notice name of nft
     */
    function name() external view returns (string memory);
    /**
     * @notice symbol of nft
     */
    function symbol() external view returns (string memory);
    /**
     * @notice nft balance of user
     */
    function balanceOf(address owner) external view returns (uint256 balance);
    /**
     * @notice owner of specified tokenId
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);
    /**
     * @notice uri of nft
     */
    function uri(uint256 tokenId) external view returns (string memory);
}
