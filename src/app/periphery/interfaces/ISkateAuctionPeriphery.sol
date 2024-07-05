// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

interface ISkateAuctionPeriphery {
    /**
     * @notice processBid is a function that is used to process a user's bid
     * by minting and creating task required
     * @param to is the address of the user submitting the bid
     * @param tokenId is the left index
     * @param bidAmount is the right index
     * requirements:
     * - only contract can call this function
     */
    function processBid(
        address to,
        uint256 tokenId,
        uint256 bidAmount
    )
        external;
}
