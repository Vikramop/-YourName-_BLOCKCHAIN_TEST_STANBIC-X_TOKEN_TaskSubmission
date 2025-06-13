// contracts/mocks/TestHelper.sol
pragma solidity ^0.8.28;

import "../GasslessPaymaster.sol";
import "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract TestHelper is GasslessPaymaster {
    constructor(IEntryPoint entryPoint) GasslessPaymaster(entryPoint) {}

    function callValidatePaymasterUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    ) public returns (bytes memory context, uint256 validationData) {
        return _validatePaymasterUserOp(userOp, userOpHash, maxCost);
    }
}
