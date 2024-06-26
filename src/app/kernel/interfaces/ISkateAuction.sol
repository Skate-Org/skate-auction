// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { IMessageBox } from '../../../skate/kernel/interfaces/IMessageBox.sol';
import { ISkateApp } from '../../../skate/kernel/interfaces/ISkateApp.sol';

/**
 * @notice contract that conducts a crosschain auction while maintaining
 * shared state on Skate.
 */
interface ISkateAuction is ISkateApp {
    struct Bid {
        address bidder;
        uint256 amount;
        uint256 chainId;
    }

    enum Status {
        NotStarted,
        Started,
        Ended
    }

    event AuctionStarted(uint256 time);
    event AuctionEnded(uint256 time);

    error BiddingNotAvailable();
    error AuctionAlreadyStarted();
    error NonZeroBidRequired();
    error AddressZero();
    /**
     * @notice startAuction is called by owner to allow other users to begin submitting bids.
     * requirements:
     * - only owner can call this function
     */

    function startAuction() external;
    /**
     * @notice startAuction is called by owner to allow other users to begin submitting bids.
     * @param user is the address of the user submitting the bid
     * @param amount is the amount of
     * @param chainId is the chainId where bid is placed from
     * requirements:
     * - only owner can call this function
     */
    function placeBid(
        address user,
        uint256 amount,
        uint256 chainId
    )
        external
        returns (IMessageBox.Task[] memory tasks);
    /**
     * @notice stopAuction is called by owner to end the auction.
     * this function also performs sorting to pick the top N bids based on number parameter passed in startAuction.
     * requirements:
     * - only owner can call this function
     */
    function stopAuction(address user)
        external
        returns (IMessageBox.Task[] memory tasks);
    // function bids(uint256 index) external view returns (address bidder, uint256 amount);
    function auctionStatus() external view returns (Status);

    function bids() external view returns (Bid[] memory);
}
