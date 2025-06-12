// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface ISXToken {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract StanbicXLiquidStaking is ERC20, Ownable, ReentrancyGuard {
    ISXToken public sxtToken;

    uint256 public totalStaked; // Total SXT tokens staked
    uint256 public rewardPerTokenStored; // Accumulated rewards per token
    uint256 public lastUpdateTime; // Last timestamp rewards were updated
    uint256 public rewardRate; // Reward tokens distributed per second

    mapping(address => uint256) public userRewardPerTokenPaid; // User’s reward per token paid
    mapping(address => uint256) public rewards; // Rewards accrued but not claimed

    // Cooldown and anti-whale can be added similarly if needed

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        address _sxtToken,
        uint256 _rewardRate
    ) ERC20("Staked Stanbic-X Token", "stSXT") {
        sxtToken = ISXToken(_sxtToken);
        rewardRate = _rewardRate; // e.g., rewards per second
        lastUpdateTime = block.timestamp;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    // Calculate reward per token based on time elapsed
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) /
                totalSupply());
    }

    // Calculate earned rewards for an account
    function earned(address account) public view returns (uint256) {
        return
            ((balanceOf(account) *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

    // Stake SXT tokens and mint stSXT 1:1
    function stake(
        uint256 amount
    ) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        require(
            sxtToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        _mint(msg.sender, amount);
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    // Unstake stSXT tokens and redeem original SXT + rewards
    function unstake(
        uint256 amount
    ) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot unstake 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient stSXT balance");

        _burn(msg.sender, amount);
        totalStaked -= amount;

        require(sxtToken.transfer(msg.sender, amount), "Transfer failed");

        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            // Reward distribution logic here (e.g., transfer reward tokens)
            // For simplicity, assuming rewards are paid in SXT:
            require(
                sxtToken.transfer(msg.sender, reward),
                "Reward transfer failed"
            );
            emit RewardPaid(msg.sender, reward);
        }

        emit Unstaked(msg.sender, amount);
    }

    // Admin can update reward rate
    function setRewardRate(uint256 newRate) external onlyOwner {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewardRate = newRate;
    }
}
