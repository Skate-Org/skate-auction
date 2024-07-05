// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {SkateApp} from "../../skate/kernel/SkateApp.sol";
import {SkateNFT} from "../../app/kernel/SkateNFT.sol";
import {IMessageBox} from "../../skate/kernel/interfaces/IMessageBox.sol";
import {ISkateAuction} from "./interfaces/ISkateAuction.sol";

contract SkateAuction is SkateNFT, ISkateAuction {
    Status _auctionStatus;
    Bid[] _bids;

    modifier onlyWhileAuctionOpen() {
        require(_auctionStatus == Status.Started, BiddingNotAvailable());
        _;
    }

    function startAuction() external onlyOwner {
        require(_auctionStatus == Status.NotStarted, AuctionAlreadyStarted());
        _auctionStatus = Status.Started;

        emit AuctionStarted(block.timestamp);
    }

    function placeBid(
        address user,
        uint256 amount,
        uint256 chainId
    ) external onlyWhileAuctionOpen returns (IMessageBox.Task[] memory tasks) {
        require(user != address(0), AddressZero());
        require(amount > 0, NonZeroBidRequired());
        _bids.push(Bid({bidder: user, amount: amount, chainId: chainId}));
        emit BidPlaced(user, amount, chainId);
    }

    function stopAuction(
        address owner
    ) external onlyContract returns (IMessageBox.Task[] memory tasks) {
        require(_auctionStatus == Status.Started, "Auction not started yet");

        Bid[] memory arr = _bids;
        arr = _quickSort(arr, int256(0), int256(arr.length - 1));
        _bids = arr;
        uint256 numWinners = _bids.length < 3 ? _bids.length : 3;
        tasks = new IMessageBox.Task[](numWinners);

        for (uint256 i = 0; i < numWinners; i++) {
            tasks[i] = _processBid(
                owner,
                arr[i].bidder,
                arr[i].amount,
                ++_tokenId,
                arr[i].chainId
            )[0];
        }

        emit AuctionEnded(block.timestamp);
    }
    /**
     * @notice _processBid is an internal function that is used to process the bid
     * by minting and creating task required
     * @param owner is the executor address
     * @param to is the user the nft is minted to
     * @param amount is the bid amount by user
     * @param tokenId is the nft id 
     * @param chainId is the chainId that the bid intent is destined for
     * requirements:
     * - only contract can call this function
     */

    function _processBid(
        address owner,
        address to,
        uint256 amount,
        uint256 tokenId,
        uint256 chainId
    ) internal returns (IMessageBox.Task[] memory tasks) {
        _mint(owner, to, tokenId, chainId);
        address peripheryContract = chainIdToPeripheryContract(chainId);
        tasks = new IMessageBox.Task[](1);
        tasks[0] = IMessageBox.Task(
            peripheryContract, // app address,
            abi.encodeWithSignature(
                "processBid(address,uint256,uint256)",
                to,
                tokenId,
                amount
            ),
            owner,
            chainId
        );
    }
    /**
     * @notice _quicksort is an internal function that is used to perform sort on an array of bids
     * @param arr is the address of the user submitting the bid
     * @param left is the left index
     * @param right is the right index
     * requirements:
     * - only contract can call this function
     */

    function _quickSort(
        Bid[] memory arr,
        int256 left,
        int256 right
    ) internal pure returns (Bid[] memory) {
        if (left < right) {
            int256 pivotIndex = _partition(arr, left, right);
            _quickSort(arr, left, pivotIndex - 1);
            _quickSort(arr, pivotIndex + 1, right);
        }
        return arr;
    }
    /**
     * @notice _partition is an internal function that is used to perform partitioning that is used for quicksort algo
     * @param arr is the address of the user submitting the bid
     * @param left is the left index
     * @param right is the right index
     * requirements:
     * - only contract can call this function
     */

    function _partition(
        Bid[] memory arr,
        int256 left,
        int256 right
    ) internal pure returns (int256) {
        uint256 pivot = arr[uint256(right)].amount;
        int256 i = left - 1;

        for (int256 j = left; j < right; j++) {
            if (arr[uint256(j)].amount > pivot) {
                i++;
                (arr[uint256(i)], arr[uint256(j)]) = (
                    arr[uint256(j)],
                    arr[uint256(i)]
                );
            }
        }

        (arr[uint256(i + 1)], arr[uint256(right)]) = (
            arr[uint256(right)],
            arr[uint256(i + 1)]
        );
        return i + 1;
    }

    function auctionStatus() external view returns (Status) {
        return _auctionStatus;
    }

    function bids() external view returns (Bid[] memory) {
        return _bids;
    }
}
