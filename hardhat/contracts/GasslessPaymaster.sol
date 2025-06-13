// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@account-abstraction/contracts/core/BasePaymaster.sol";
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";

contract GasslessPaymaster is BasePaymaster {
    constructor(IEntryPoint _entryPoint) BasePaymaster(_entryPoint) {}

    function _validatePaymasterUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    ) internal override returns (bytes memory context, uint256 validationData) {
        context = "";
        validationData = 0;
        return (context, validationData);
    }

    function exposeValidatePaymasterUserOp(
        address sender,
        uint256 nonce,
        bytes memory initCode,
        bytes memory callData,
        bytes32 accountGasLimits,
        uint256 preVerificationGas,
        bytes32 gasFees,
        bytes memory paymasterAndData,
        bytes memory signature,
        bytes32 userOpHash,
        uint256 maxCost
    ) public returns (bytes memory, uint256) {
        PackedUserOperation memory userOp = PackedUserOperation(
            sender,
            nonce,
            initCode,
            callData,
            accountGasLimits,
            preVerificationGas,
            gasFees,
            paymasterAndData,
            signature
        );
        return _validatePaymasterUserOp(userOp, userOpHash, maxCost);
    }

    // Receive ETH to fund the paymaster
    receive() external payable {}
}
