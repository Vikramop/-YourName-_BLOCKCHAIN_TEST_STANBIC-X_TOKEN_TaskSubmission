// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@account-abstraction/contracts/core/BaseAccount.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SessionKeyAccount is BaseAccount {
    using ECDSA for bytes32;

    address public owner;
    mapping(address => uint256) public sessionExpiry;

    constructor(
        address _owner,
        IEntryPoint _entryPoint
    ) BaseAccount(_entryPoint) {
        owner = _owner;
    }

    function addSessionKey(address sessionKey, uint256 expiry) external {
        require(msg.sender == owner, "not owner");
        sessionExpiry[sessionKey] = expiry;
    }

    function removeSessionKey(address sessionKey) external {
        require(msg.sender == owner, "not owner");
        sessionExpiry[sessionKey] = 0;
    }

    function _validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash
    ) internal view override returns (uint256 validationData) {
        address signer = userOpHash.recover(userOp.signature);
        if (signer == owner) return 0;
        if (sessionExpiry[signer] >= block.timestamp) return 0;
        return SIG_VALIDATION_FAILED;
    }
}
