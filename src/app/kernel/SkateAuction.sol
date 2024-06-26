// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { SkateApp } from '../../skate/kernel/SkateApp.sol';
import { SkateNFT } from '../../app/kernel/SkateNFT.sol';
import { IMessageBox } from '../../skate/kernel/interfaces/IMessageBox.sol';
import { ISkateAuction } from './interfaces/ISkateAuction.sol';
import { Arrays } from '@openzeppelin/contracts/utils/Arrays.sol';

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
    )
        external
        onlyWhileAuctionOpen
        returns (IMessageBox.Task[] memory tasks)
    {
        require(user != address(0), AddressZero());
        require(amount > 0, NonZeroBidRequired());
        _bids.push(Bid({ bidder: user, amount: amount, chainId: chainId }));
    }

    function stopAuction(address owner)
        external
        onlyContract
        returns (IMessageBox.Task[] memory tasks)
    {
        require(_auctionStatus == Status.Started, 'Auction not ended yet');

        // sort bids in descending order of amount
        Bid[] memory arr = _bids;
        arr = _quickSort(arr, int256(0), int256(arr.length - 1));
        _bids = arr;

        // Only take top 3 bids
        uint256 numWinners = _bids.length < 3 ? _bids.length : 3;
        tasks = new IMessageBox.Task[](numWinners);

        for (uint256 i = 0; i < numWinners; i++) {
            tasks[i] = _mint(owner, arr[i].bidder, _tokenId, arr[i].chainId)[0];
        }

        emit AuctionEnded(block.timestamp);
    }

    // function _quickSort(uint[] memory arr, int left, int right) internal{
    //     int i = left;
    //     int j = right;
    //     if(i==j) return;
    //     uint pivot = arr[uint(left + (right - left) / 2)];
    //     while (i <= j) {
    //         while (arr[uint(i)] < pivot) i++;
    //         while (pivot < arr[uint(j)]) j--;
    //         if (i <= j) {
    //             (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
    //             i++;
    //             j--;
    //         }
    //     }
    //     if (left < j)
    //         quickSort(arr, left, j);
    //     if (i < right)
    //         quickSort(arr, i, right);
    // }

    function _quickSort(
        Bid[] memory arr,
        int256 left,
        int256 right
    )
        internal
        pure
        returns (Bid[] memory)
    {
        if (left < right) {
            int256 pivotIndex = _partition(arr, left, right);
            _quickSort(arr, left, pivotIndex - 1);
            _quickSort(arr, pivotIndex + 1, right);
        }
        return arr;
    }

    function _partition(
        Bid[] memory arr,
        int256 left,
        int256 right
    )
        internal
        pure
        returns (int256)
    {
        uint256 pivot = arr[uint256(right)].amount;
        int256 i = left - 1;

        for (int256 j = left; j < right; j++) {
            if (arr[uint256(j)].amount > pivot) {
                // Change < to > for descending order
                i++;
                (arr[uint256(i)], arr[uint256(j)]) =
                    (arr[uint256(j)], arr[uint256(i)]);
            }
        }

        (arr[uint256(i + 1)], arr[uint256(right)]) =
            (arr[uint256(right)], arr[uint256(i + 1)]);
        return i + 1;
    }

    function auctionStatus() external view returns (Status) {
        return _auctionStatus;
    }

    function bids() external view returns (Bid[] memory) {
        return _bids;
    }
}
