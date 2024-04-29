// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

/**
 * @title IFOTDistributor Interface
 * @dev Interface for a contract that distributes FOT tokens from various pools
 */
interface IFOTDistributor {
    /**
     * @dev Emitted when tokens are distributed from a pool to an address
     * @param poolName Name of the distribution pool
     * @param _amount Amount of tokens distributed
     * @param _to Recipient address
     */
    event TokenDistributed(
        bytes32 indexed poolName,
        uint256 indexed _amount,
        address indexed _to
    );

    /**
     * @dev Emitted when tokens are swapped from the "Game" pool to an address
     * @param _to Recipient address
     * @param _amount Amount of tokens swapped
     */
    event TokenSwapped(address indexed _to, uint256 indexed _amount);

    /**
     * @dev Emitted when liquidity is transferred between pools
     * @param _fromPoolName Source pool name
     * @param _destPoolName Destination pool name
     * @param _amount Amount of liquidity transferred
     */
    event TransferredLiquidity(
        bytes32 indexed _fromPoolName,
        bytes32 indexed _destPoolName,
        uint256 indexed _amount
    );

    /**
     * @dev Distribute FOT tokens from a specified pool to an address
     * @param poolName Name of the distribution pool
     * @param _amount Amount of tokens to distribute
     * @param _to Recipient address
     * @return Success status of distribution
     */
    function distribute(
        bytes32 poolName,
        uint256 _amount,
        address _to
    ) external returns (bool);

    /**
     * @dev Swap LMNT to FOT tokens from the "Game" pool
     * @param _to Recipient address
     * @param _amount Amount of tokens to swap
     */
    function swap(address _to, uint256 _amount) external returns (bool);

    /**
     * @dev Transfer remaining liquidity from a pool to the "Game" pool
     * @param poolName Source pool name
     */
    function transferLiquidity(bytes32 poolName) external;

    /**
     * @dev Get available liquidity for a pool
     * @param poolName Pool name
     * @return Available liquidity
     */
    function poolLiquidity(bytes32 poolName) external view returns (uint256);

    /**
     * @dev Get used liquidity for a pool
     * @param poolName Pool name
     * @return Used liquidity
     */
    function usedLiquidity(bytes32 poolName) external view returns (uint256);
}
