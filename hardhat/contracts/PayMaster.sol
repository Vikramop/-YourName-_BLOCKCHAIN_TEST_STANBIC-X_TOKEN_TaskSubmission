// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@account-abstraction/contracts/core/BasePaymaster.sol";
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";

// EntryPoint v0.8 is always deployed at address 0x4337084d9e255ff0702461cf8895ce9e3b5ff108

contract SimpleGaslessPaymaster is BasePaymaster {
    constructor(IEntryPoint _entryPoint) BasePaymaster(_entryPoint) {}

    // Override _validatePaymasterUserOp to accept any user operation
    function _validatePaymasterUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    )
        internal
        pure
        override
        returns (bytes memory context, uint256 validationData)
    {
        // Always approve, regardless of sender or operation
        context = "";
        validationData = 0;
    }

    // Optional: Allow owner to withdraw funds
    function withdrawTo(
        address payable withdrawAddress,
        uint256 amount
    ) external onlyOwner {
        withdrawAddress.transfer(amount);
    }

    // Receive ETH to fund the paymaster
    receive() external payable {}
}
