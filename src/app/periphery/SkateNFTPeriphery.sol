// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { UUPSUpgradeable } from
    '@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol';
import { ReentrancyGuardUpgradeable } from
    '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';

import { SkateAppPeriphery } from '../../skate/periphery/SkateAppPeriphery.sol';
import { ISkateGateway } from
    '../../skate/periphery/interfaces/ISkateGateway.sol';
import { ISkateNFTPeriphery } from './interfaces/ISkateNFTPeriphery.sol';

/**
 * @notice {SkateNFTPeriphery} is a periphery contract of the {SkateNFT} contract. It tracks the periphery
 * states of users balances and NFT ownership.
 */
contract SkateNFTPeriphery is
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    SkateAppPeriphery,
    ISkateNFTPeriphery
{
    string _name;
    string _symbol;
    mapping(address => uint256) _balances;
    mapping(uint256 => address) _owners;
    string _uri;

    constructor() {
        _disableInitializers();
    }

    function __SkateNFTPeriphery_init(
        string memory name_,
        string memory symbol_,
        address gateway_
    )
        public
        initializer
    {
        __ReentrancyGuard_init();
        __SkateAppPeriphery_init(gateway_);
        _name = name_;
        _symbol = symbol_;
    }

    function mint(
        address to,
        uint256 tokenId
    )
        external
        virtual
        override
        onlyGateway
    {
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0x0), to, tokenId);
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner)
        external
        view
        override
        returns (uint256 balance)
    {
        balance = _balances[owner];
    }

    function ownerOf(uint256 tokenId)
        external
        view
        override
        returns (address owner)
    {
        owner = _owners[tokenId];
    }

    function uri(uint256 /* tokenId */ )
        external
        view
        virtual
        override
        returns (string memory)
    {
        return _uri; // todo: implement link specific implementation.
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override(UUPSUpgradeable)
        onlyOwner
    { }
}
