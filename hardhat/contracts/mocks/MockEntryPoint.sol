// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";

contract MockEntryPoint is IEntryPoint {
    // IStakeManager
    function balanceOf(address account) external view returns (uint256) {
        return 0;
    }

    function getDepositInfo(
        address account
    ) external view returns (IStakeManager.DepositInfo memory) {
        return IStakeManager.DepositInfo(0, false, 0, 0, 0);
    }

    // INonceManager
    function incrementNonce(uint192 key) external {}

    // IEntryPoint
    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return interfaceId == type(IEntryPoint).interfaceId;
    }

    function depositTo(address) external payable {}

    function addStake(uint32) external payable {}

    function unlockStake() external {}

    function withdrawStake(address payable) external {}

    function withdrawTo(address payable, uint256) external {}

    function getNonce(address, uint192) external view returns (uint256) {
        return 0;
    }

    function getSenderAddress(bytes memory initCode) external {}

    function simulateValidation(PackedUserOperation calldata) external {}

    function handleOps(
        PackedUserOperation[] calldata ops,
        address payable beneficiary
    ) external {}

    function handleAggregatedOps(
        UserOpsPerAggregator[] calldata opsPerAggregator,
        address payable beneficiary
    ) external {}

    function getUserOpHash(
        PackedUserOperation calldata userOp
    ) external view returns (bytes32) {
        return bytes32(0);
    }

    function delegateAndRevert(address target, bytes calldata data) external {}

    function senderCreator() external view returns (ISenderCreator) {
        return ISenderCreator(address(0));
    }
    // Add any other required functions as per your AA package version
}
