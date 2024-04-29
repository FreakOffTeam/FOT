// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IFOT} from "./IFOT.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IAccessRestriction} from "../accessRestrictions/IAccessRestriction.sol";

contract FOT is ERC20, IFOT {
    /// @dev EIP-20 token name for this token
    string public constant NAME = "FreakOff";

    /// @dev EIP-20 token symbol for this token
    string public constant SYMBOL = "FOT";

    /// @dev EIP-20 token decimals for this token
    uint8 public constant DECIMALS = 18;

    /// @dev EIP-20 token supply for this token
    uint256 public constant SUPPLY = 1e10 * (10 ** DECIMALS);

    /// @dev Reference to the access restriction contract
    IAccessRestriction public immutable accessRestriction;

    /// @dev Modifier: Only accessible by distributors
    modifier onlyDistributor() {
        accessRestriction.ifDistributor(msg.sender);
        _;
    }

    constructor(address _accessRestrictionAddress) ERC20(NAME, SYMBOL) {
        accessRestriction = IAccessRestriction(_accessRestrictionAddress);
        _mint(address(this), SUPPLY);
    }

    function transferToken(
        address _to,
        uint256 _amount
    ) onlyDistributor external returns (bool) {
        require(_amount > 0, "FOT::Insufficient amount:equal to zero");
        require(
            !accessRestriction.isOwner(_to),
            "FOT::FOT can't transfer to owner"
        );
        require(
            balanceOf(address(this)) >= _amount,
            "FOT::Insufficient balance"
        );

        _transfer(address(this), _to, _amount);

        return true;
    }
}
