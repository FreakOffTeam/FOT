// SPDX-License-Identifier: GPL-3.0
// MockReentrant.sol
// This contract simulates a contract calling back into itself to cause a reentrant attack
pragma solidity ^0.8.24;

contract MockReentrant {
    bool public isReentrant = false;
    event CallCompleted();

    constructor() payable {}

    function maliciousFunction(address target) external payable {
        isReentrant = true;
        (bool success, ) = target.call{value: msg.value}(
            abi.encodeWithSignature("buyTokenByNativeCoin(uint256)", 100)
        );
        require(success, "Low-level call failed"); // Add a require statement to check if the low-level call was successful
        require(success, "Low-level call failed"); // Add a require statement to check if the low-level call was successful
        isReentrant = false;
        emit CallCompleted(); // Emit the event here
    }
}
