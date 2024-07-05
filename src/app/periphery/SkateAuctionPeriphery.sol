// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { UUPSUpgradeable } from
    '@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol';
import { ReentrancyGuardUpgradeable } from
    '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { SkateAppPeriphery } from '../../skate/periphery/SkateAppPeriphery.sol';
import { ISkateGateway } from
    '../../skate/periphery/interfaces/ISkateGateway.sol';
import { ISkateNFTPeriphery } from './interfaces/ISkateNFTPeriphery.sol';
import { SkateNFTPeriphery } from './SkateNFTPeriphery.sol';
import { ISkateAuctionPeriphery } from './interfaces/ISkateAuctionPeriphery.sol';

contract SkateAuctionPeriphery is
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    SkateNFTPeriphery,
    ISkateAuctionPeriphery
{
    address _auctionToken;

    constructor() {
        _disableInitializers();
    }

    function __SkateAuctionPeriphery_init(
        string memory name_,
        string memory symbol_,
        address gateway_,
        address auctionToken_
    )
        public
        initializer
    {
        __ReentrancyGuard_init();
        __SkateNFTPeriphery_init(name_, symbol_, gateway_);
        _auctionToken = auctionToken_;
    }

    function mint(address to, uint256 tokenId) external override {
        revert();
    }

    function _mint(address to, uint256 tokenId) internal {
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0x0), to, tokenId);
    }

    function processBid(
        address to,
        uint256 tokenId,
        uint256 bidAmount
    )
        external
        onlyGateway
    {
        //
        IERC20(_auctionToken).transferFrom(to, address(this), bidAmount);
        //mint nft
        _mint(to, tokenId);
    }
}
