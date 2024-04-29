// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/**
 * @title AccessRestriction interface
 */
interface IAccessRestriction is IAccessControl {
    /**
     * @dev Pauses contract functionality
     */
    function pause() external;

    /**
     * @dev Unpauses contract functionality
     */
    function unpause() external;

    /**
     * @dev Checks if given address is owner
     * @param _address Address to check
     */
    function ifOwner(address _address) external view;

    /**
     * @dev Checks if given address has admin role
     * @param _address Address to check
     */
    function ifAdmin(address _address) external view;

    /**
     * @dev Checks if given address is admin or owner
     * @param _address Address to check
     */
    function ifOwnerOrAdmin(address _address) external view;

    /**
     * @dev Checks if given address is admin or approved contract
     * @param _address Address to check
     */
    function ifAdminOrApprovedContract(address _address) external view;

    /**
     * @dev Checks if given address has owner role
     * @param _address Address to check
     * @return bool true if address has owner role
     */
    function isOwner(address _address) external view returns (bool);

    /**
     * @dev Checks if given address has admin role
     * @param _address Address to check
     * @return bool true if address has admin role
     */
    function isAdmin(address _address) external view returns (bool);

    /**
     * @dev Checks if given address is approved contract
     * @param _address Address to check
     */
    function ifApprovedContract(address _address) external view;

    /**
     * @dev Checks if given address has approved contract role
     * @param _address Address to check
     * @return bool true if address has approved contract role
     */
    function isApprovedContract(address _address) external view returns (bool);

    /**
     * @dev Checks if given address has script role
     * @param _address Address to check
     * @return bool true if address has script role
     */
    function isScript(address _address) external view returns (bool);

    /**
     * @dev Checks if given address has script role
     * @param _address Address to check
     */
    function ifScript(address _address) external view;

    /**
     * @dev Checks if given address has distributor role
     * @param _address Address to check
     */
    function ifDistributor(address _address) external view;

    /**
     * @dev Checks if given address has vesting manager role
     * @param _address Address to check
     */
    function ifVestingManager(address _address) external view;

    /**
     * @dev Checks if given address has WERT role
     * @param _address Address to check
     * @return bool true if address has WERT role
     */
    function isWert(address _address) external view returns (bool);

    /**
     * @dev Checks if given address has vesting manager role
     * @param _address Address to check
     * @return bool true if address has vesting manager role
     */
    function isVestingManager(address _address) external view returns (bool);

    /**
     * @dev Checks if given address has distributor role
     * @param _address Address to check
     * @return bool true if address has distributor role
     */
    function isDistributor(address _address) external view returns (bool);

    /**
     * @dev Checks if given address has WERT role
     * @param _address Address to check
     */
    function ifWert(address _address) external view;

    /**
     * @dev Checks if given address is admin or has script role
     * @param _address Address to check
     */
    function ifAdminOrScript(address _address) external view;

    /**
     * @dev Checks if contract is not paused
     */
    function ifNotPaused() external view;

    /**
     * @dev Checks if contract is paused
     */
    function ifPaused() external view;

    /**
     * @dev Returns if contract is paused
     * @return bool true if paused
     */
    function paused() external view returns (bool);
}
