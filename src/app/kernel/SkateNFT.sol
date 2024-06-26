// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { UUPSUpgradeable } from
    '@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol';
import { ReentrancyGuardUpgradeable } from
    '@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol';
import { ERC1155Upgradeable } from
    '@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol';

import { IMessageBox } from '../../skate/kernel/interfaces/IMessageBox.sol';
import { ISkateNFT } from './interfaces/ISkateNFT.sol';

import { SkateApp } from '../../skate/kernel/SkateApp.sol';

/**
 * @dev SkateRebelNFT is a collection contract by Skate.
 */
contract SkateNFT is
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC1155Upgradeable,
    SkateApp,
    ISkateNFT
{
    string public _name;
    string public _symbol;
    uint256 public _tokenId;
    mapping(address user => uint256[] tokenIds) _userToTokenIds;
    mapping(uint256 tokenId => address user) _tokenIdToUser;
    mapping(uint256 tokenId => uint256 chainId) _tokenIdToChainId;
    mapping(uint256 tokenId => bool used) _tokenIdToUsedStatus;

    event Minted(address to, uint256 tokenId);

    constructor() {
        _disableInitializers();
    }

    function initialize(
        string calldata name_,
        string calldata symbol_,
        address messageBox_
    )
        public
        initializer
    {
        __ReentrancyGuard_init();
        __ERC1155_init('no uri');
        __SkateApp_init(messageBox_);

        _name = name_;
        _symbol = symbol_;
    }

    function mint(
        address user,
        address to,
        uint256 chainId
    )
        public
        virtual
        override
        onlyContract
        returns (IMessageBox.Task[] memory tasks)
    {
        return _mint(user, to, ++_tokenId, chainId);
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    )
        public
        view
        override
        onlyContract
    {
        revert();
    }

    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    )
        public
        view
        override
        onlyContract
    {
        revert();
    }

    function changeBaseURI(string calldata newURI)
        external
        override
        onlyOwner
    {
        _setURI(newURI);
    }

    function uri(uint256 id)
        public
        view
        virtual
        override(ERC1155Upgradeable)
        returns (string memory)
    {
        return super.uri(id);
    }

    function _mint(
        address user,
        address to,
        uint256 tokenId_,
        uint256 chainId
    )
        internal
        returns (IMessageBox.Task[] memory tasks)
    {
        _mint(to, tokenId_, 1, '');
        _userToTokenIds[to].push(tokenId_);
        _tokenIdToUser[tokenId_] = to;
        _tokenIdToChainId[tokenId_] = chainId;
        emit Minted(to, tokenId_);
        address peripheryContract = chainIdToPeripheryContract(chainId);
        // creates a task.
        tasks = new IMessageBox.Task[](1);
        tasks[0] = IMessageBox.Task(
            peripheryContract, // app address,
            abi.encodeWithSignature('mint(address,uint256)', to, tokenId_),
            user,
            chainId
        );
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override(UUPSUpgradeable)
        onlyOwner
    { }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function tokenId() external view override returns (uint256) {
        return _tokenId;
    }

    function getTokenIdsByUser(address user)
        external
        view
        override
        returns (uint256[] memory)
    {
        return _userToTokenIds[user];
    }

    function getUserByTokenId(uint256 id)
        external
        view
        override
        returns (address)
    {
        return _tokenIdToUser[id];
    }

    function getChainIdByTokenId(uint256 id)
        external
        view
        override
        returns (uint256)
    {
        return _tokenIdToChainId[id];
    }

    function getChainIdsByTokenIds(uint256[] memory ids)
        external
        view
        override
        returns (uint256[] memory chainIds)
    {
        chainIds = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            chainIds[i] = _tokenIdToChainId[ids[i]];
        }
    }

    function getUsedStatusByTokenId(uint256 id)
        external
        view
        override
        returns (bool)
    {
        return _tokenIdToUsedStatus[id];
    }
}
