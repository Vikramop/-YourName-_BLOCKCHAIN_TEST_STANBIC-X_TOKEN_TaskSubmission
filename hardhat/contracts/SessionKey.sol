// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@account-abstraction/contracts/core/BaseAccount.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";

contract SessionKeyAccount is BaseAccount {
    using ECDSA for bytes32;
    mapping(address => uint256) private nonces;

    address public owner;
    mapping(address => uint256) public sessionExpiry;
    IEntryPoint private immutable _entryPoint;

    // for test
    event Debug(address signer, address owner, uint256 expiry);

    constructor(address _owner, IEntryPoint entryPoint_) {
        owner = _owner;
        _entryPoint = entryPoint_;
    }

    function entryPoint() public view override returns (IEntryPoint) {
        return _entryPoint;
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
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) internal override returns (uint256 validationData) {
        address signer = userOpHash.recover(userOp.signature);

        emit Debug(signer, owner, sessionExpiry[signer]);

        if (signer == owner) return 0;
        if (sessionExpiry[signer] >= block.timestamp) return 0;
        return 1;
    }

    function validateUserOpForTest(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) external returns (uint256) {
        return _validateSignature(userOp, userOpHash);
    }

    function incrementNonce(address user) internal {
        nonces[user]++;
    }

    // prevent replay attacks
    function _validateNonce(uint256 nonce) internal view override {
        require(nonce == nonces[msg.sender], "Invalid nonce");
    }

    function getNonce(address user) external view returns (uint256) {
        return nonces[user];
    }
}
