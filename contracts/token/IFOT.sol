// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;


import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFOT is IERC20{
    function transferToken(address _to,uint256 _amount) external returns (bool);
}