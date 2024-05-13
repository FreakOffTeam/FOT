// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IAccessRestriction} from "../accessRestrictions/IAccessRestriction.sol";
import {IFOT} from "../token/IFOT.sol";
import {IFOTDistributor} from "./IFOTDistributor.sol";

/**
 * @title FOT Token Distributor Contract
 * @dev Distributes FOT tokens from various pools with access controls
 */
contract FOTDistributor is IFOTDistributor {
    /**
     * @dev Mapping to store available liquidity for each pool
     */
    mapping(bytes32 => uint256) public override poolLiquidity;

    /**
     * @dev Mapping to track used liquidity for each pool
     */
    mapping(bytes32 => uint256) public override usedLiquidity;

    /**
     * @dev Reference to the access restriction contract
     */
    IAccessRestriction public immutable accessRestriction;

    /**
     * @dev Reverts if address is invalid
     */
    modifier validAddress(address _addr) {
        require(_addr != address(0), "FOTDistributor::Not valid address");
        _;
    }

    /**
     * @dev Reference to the FOT token contract
     */
    IFOT public immutable token;

    /**
     * @dev Modifier: Only accessible by administrators
     */
    modifier onlyAdmin() {
        accessRestriction.ifAdmin(msg.sender);
        _;
    }

    /**
     * @dev Modifier: Only accessible by authorized scripts
     */
    modifier onlyScript() {
        accessRestriction.ifScript(msg.sender);
        _;
    }

    /**
     * @dev Modifier: Only accessible by approved contracts
     */
    modifier onlyApprovedContract() {
        accessRestriction.ifApprovedContract(msg.sender);
        _;
    }

    modifier onlygGameOrP2E(bytes32 pool) {
        require(pool == bytes32("GameTreasury") || pool == bytes32("P2E"), "FOTDistributor::The pool is not game or p2e");
        _;
    }

    /**
     * @dev Constructor to initialize the FOTDistributor contract
     * @param _accessRestrictionAddress Address of the access restriction contract
     * @param _fotAddress Address of the FOT token contract
     */
    constructor(address _accessRestrictionAddress, address _fotAddress) {
        accessRestriction = IAccessRestriction(_accessRestrictionAddress);
        token = IFOT(_fotAddress);

        // Initialize pool liquidity values
        poolLiquidity[bytes32("P2E")] = 39e8 * (10 ** 18);
        poolLiquidity[bytes32("GameTreasury")] = 11e8 * (10 ** 18);
        poolLiquidity[bytes32("Sale")] = 13e8 * (10 ** 18);
        poolLiquidity[bytes32("Liquidity")] = 7e8 * (10 ** 18);
        poolLiquidity[bytes32("Team")] = 1e9 * (10 ** 18);
        poolLiquidity[bytes32("Marketing")] = 12e8 * (10 ** 18);
        poolLiquidity[bytes32("Reserved")] = 5e8 * (10 ** 18);
        poolLiquidity[bytes32("Seed")] = 3e8 * (10 ** 18);
    }

    /**
     * @dev Distribute FOT tokens from a specified pool
     * @param poolName Name of distribution pool
     * @param _amount Amount of tokens to distribute
     * @param _to Recipient address
     * @return Success status
     */
    function distribute(
        bytes32 poolName,
        uint256 _amount,
        address _to
    ) external override onlyApprovedContract validAddress(_to) returns (bool) {
        _distribute(poolName, _amount, _to);

        emit TokenDistributed(poolName, _amount, _to);

        return true;
    }

    /**
     * @dev Swap FOT tokens from the "GameTreasury" or "P2E" pool
     * @param _to Recipient address
     * @param _amount Amount of tokens to swap
     */
    function swap(
        bytes32 _poolName,
        address _to,
        uint256 _amount
    ) external override onlyScript onlygGameOrP2E(_poolName) validAddress(_to) returns (bool) {
        // require(_poolName == bytes32("GameTreasury") || _poolName == bytes32("P2E"), "FOTDistributor::The pool is not valid for swap");
        _distribute(bytes32(_poolName), _amount, _to);

        emit TokenSwapped(_poolName, _to, _amount);
        return true;
    }

    /**
     * @dev Transfer liquidity from 'Reserved' to 'toPool'"
     * @param toPool Target pool name
     * @param amount Transfer amount
     */
    function transferLiquidity(bytes32 toPool, uint256 amount) external override onlyAdmin onlygGameOrP2E(toPool){
        uint256 remainingToken = poolLiquidity[bytes32("Reserved")] -
            usedLiquidity[bytes32("Reserved")];

        require(remainingToken >= 0 && remainingToken >= amount, "FOTDistributor::The pool has not enough balance");

        poolLiquidity[bytes32("Reserved")] -= amount;
        poolLiquidity[toPool] += amount;

        emit TransferredLiquidity(toPool, amount);
    }

    /**
     * @dev Distribute tokens from a pool
     * @param poolName Pool name
     * @param _amount Amount to distribute
     * @param _to Recipient address
     */
    function _distribute(
        bytes32 poolName,
        uint256 _amount,
        address _to
    ) private {
        // Validate pool balance
        require(
            _amount + usedLiquidity[poolName] <= poolLiquidity[poolName],
            "FOTDistributor::The pool has not enough balance"
        );

        require(
            _to != address(this),
            "FOTDistributor::FOT cannot transfer to distributor"
        );

        usedLiquidity[poolName] += _amount;

        // Transfer tokens
        bool success = token.transferToken(_to, _amount);
        require(success, "FOTDistributor::Token transfer faild");
    }
}

