// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Weth is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, 10000 * (10 ** decimals()));
    }

    function setMint(address _address, uint256 _amount) external {
        _mint(_address, _amount);
    }

    function resetAcc(address _address) external {
        uint256 amount = balanceOf(_address);
        _burn(_address, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 18; // Set the desired number of decimal places here
    }
}
