// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

import {IAccessRestriction} from "./IAccessRestriction.sol";

/** @title AccessRestriction contract */

contract AccessRestriction is AccessControl, Pausable, IAccessRestriction {
    // Roles
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SCRIPT_ROLE = keccak256("SCRIPT_ROLE");
    bytes32 public constant APPROVED_CONTRACT_ROLE = keccak256("APPROVED_CONTRACT_ROLE");

    /** MODIFIER
     * @dev Checks if message sender has admin role
     */
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "AR::caller is not owner"
        );
        _;
    }

    constructor(address _deployer) {
        if (!hasRole(DEFAULT_ADMIN_ROLE, _deployer)) {
            _grantRole(DEFAULT_ADMIN_ROLE, _deployer);
        }
    }

    /**
     * @dev Pauses contract functionality
     */
    function pause() external override onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses contract functionality
     */
    function unpause() external override onlyOwner {
        _unpause();
    }

    /**
     * @dev Checks if given address is owner
     * @param _address Address to check
     */
    function ifOwner(address _address) external view override {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _address),
            "AR::caller is not owner"
        );
    }

    /**
     * @dev Checks if given address has admin role
     * @param _address Address to check
     */
    function ifAdmin(address _address) external view override {
        require(hasRole(ADMIN_ROLE, _address), "AR::caller is not admin");
    }

    /**
     * @dev Checks if given address is admin or owner
     * @param _address Address to check
     */
    function ifOwnerOrAdmin(address _address) external view override {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _address) || hasRole(ADMIN_ROLE, _address),
            "AR::caller is not admin or owner"
        );
    }

    /**
     * @dev Checks if given address is admin or approved contract
     * @param _address Address to check
     */
    function ifAdminOrApprovedContract(
        address _address
    ) external view override {
        require(
            hasRole(APPROVED_CONTRACT_ROLE, _address) || hasRole(ADMIN_ROLE, _address),
            "AR::caller is not admin or approved contract"
        );
    }

    /**
     * @dev Checks if given address is admin or has script role
     * @param _address Address to check
     */
    function ifAdminOrScript(address _address) external view override {
        require(
            hasRole(SCRIPT_ROLE, _address) || hasRole(ADMIN_ROLE, _address),
            "AR::caller is not admin or script"
        );
    }

    /**
     * @dev Checks if given address has distributor role
     * @param _address Address to check
     */
    function ifDistributor(address _address) external view override {
        require(hasRole(DISTRIBUTOR_ROLE, _address), "AR::caller is not distributor");
    }

    /**
     * @dev Checks if given address is approved contract
     * @param _address Address to check
     */
    function ifApprovedContract(address _address) external view override {
        require(
            hasRole(APPROVED_CONTRACT_ROLE, _address),
            "AR::caller is not approved contract"
        );
    }

    /**
     * @dev Checks if given address has script role
     * @param _address Address to check
     */
    function ifScript(address _address) external view override {
        require(hasRole(SCRIPT_ROLE, _address), "AR::caller is not script");
    }

    /**
     * @dev Checks if contract is not paused
     */
    function ifNotPaused() external view override {
        require(!paused(), "AR::Pausable: paused");
    }

    /**
     * @dev Checks if contract is paused
     */
    function ifPaused() external view override {
        require(paused(), "AR::Pausable: not paused");
    }

    /**
     * @dev Returns pause status of contract
     */
    function paused()
        public
        view
        virtual
        override(Pausable, IAccessRestriction)
        returns (bool)
    {
        return super.paused();
    }

    /**
     * @dev Checks if given address has owner role
     * @param _address Address to check
     * @return bool true if address has owner role
     */
    function isOwner(address _address) public view override returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    /**
     * @dev Checks if given address has admin role
     * @param _address Address to check
     * @return bool true if address has admin role
     */
    function isAdmin(address _address) public view override returns (bool) {
        return hasRole(ADMIN_ROLE, _address);
    }

    /**
     * @dev Checks if given address has distributor role
     * @param _address Address to check
     * @return bool true if address has distributor role
     */
    function isDistributor(
        address _address
    ) public view override returns (bool) {
        return hasRole(DISTRIBUTOR_ROLE, _address);
    }

    /**
     * @dev Checks if given address has approved contract role
     * @param _address Address to check
     * @return bool true if address has approved contract role
     */
    function isApprovedContract(
        address _address
    ) public view override returns (bool) {
        return hasRole(APPROVED_CONTRACT_ROLE, _address);
    }

    /**
     * @dev Checks if given address has script role
     * @param _address Address to check
     * @return bool true if address has script role
     */
    function isScript(address _address) public view override returns (bool) {
        return hasRole(SCRIPT_ROLE, _address);
    }
}
