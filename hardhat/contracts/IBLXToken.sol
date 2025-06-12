// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IBLXToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // Custom BLX functions
    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function maxTxAmount() external view returns (uint256);

    function cooldownTime() external view returns (uint256);

    function lastTxTime(address account) external view returns (uint256);

    function isExcludedFromCooldown(
        address account
    ) external view returns (bool);

    function setMaxTxAmount(uint256 newMaxTxAmount) external;

    function setCooldownTime(uint256 newCooldownTime) external;

    function setCooldownExcluded(address account, bool excluded) external;
}
