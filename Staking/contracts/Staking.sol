// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title RWX Staking Contract: Stake and Unstake Tokens
 */
contract Staking is Ownable {
  using SafeERC20 for ERC20;
  using SafeMath for uint256;

  // Token to be staked
  ERC20 public immutable token;
  uint256 constant private duration = 7890000; // 3 months
  // the date where rewardRate will reset
  uint256 public endPeriod;
  // the date where the new rewardRate will reset
  uint256 public nextEndPeriod;
  uint256 public rewardRate;
  
  // Mapping of account to stakes
  // Stake is a struct consisting of balance and timestamp of staking
  mapping(address => Stake) internal stakes;
  
  // Stake - a struct consisting of stake balance and timestamp of staking
  struct Stake {
    uint256 balance;
    uint256 timestamp;
  }

  // Staking event
  event StakeAmount(address indexed account, uint256 amount, uint256 timestamp);

  // Unstaking event
  event UnStakeAmount (address indexed account, uint256 amount, uint256 timestamp);
  event SetRewardRate(uint256 indexed rewardRate);

  /**
   * @notice Constructor
   * @param _token address
   * @param _rewardRate uint256
   */
  constructor(
    address _token,
    uint256 _rewardRate
  ) {
    token = ERC20(_token);
    rewardRate = _rewardRate;
    endPeriod = block.timestamp + duration;
    nextEndPeriod = endPeriod + duration;
  }

  /**
   * @dev function to reset reward rate 
   * @param _rewardRate - new rate set by admin  
   */
  function setRewardRate(uint256 _rewardRate) external onlyOwner {
    if(block.timestamp > endPeriod && block.timestamp <= nextEndPeriod) {
      rewardRate = _rewardRate;
    }
    emit SetRewardRate(rewardRate);
  }

  /**
   * @notice Stake tokens for own account
   * @param amount uint256
   */
  function stake(uint256 amount) external {
      _stake(msg.sender, amount);
  }

  /**
   * @notice Unstake tokens for own account
   * @param amount uint256
   */
  function unstake(uint256 amount) external {
    _unstake(msg.sender, amount);
    token.transfer(msg.sender, amount);
    emit UnStakeAmount(msg.sender, amount, block.timestamp);
  }

  /**
   * @notice Receive stakes for an account
   * @param account address 
   * @return accountStake - consisting of balance and timestamp
   */
  function getStakes(address account)
    external
    view
    returns (Stake memory accountStake)
  {
    return stakes[account];
  }

  /**
   * @notice Total balance of all accounts (ERC-20)
   */
  function totalSupply() external view returns (uint256) {
    return token.balanceOf(address(this));
  }

  /**
   * @notice Balance of an account (ERC-20)
   */
  function balanceOf(address account)
    external
    view
    returns (uint256 total)
  {
    return stakes[account].balance;
  }

  /**
   * @notice Decimals of underlying token (ERC-20)
   */
  function decimals() external view returns (uint8) {
    return token.decimals();
  }

  /**
   * @notice Stake tokens on behalf of an account
   * @param account address
   * @param amount uint256
   */
  function stakeFor(address account, uint256 amount) public {
    _stake(account, amount);
  }

  /**
   * @notice Update amount with staking reward
   * @param account uint256
   */
  function available(address account) public view returns (uint256) {
    Stake storage selected = stakes[account];
    uint256 year = 365*24*60*60; // 365 days * 24 hours * 60 min * 60 sec
    uint256 stakeDuration = block.timestamp.sub(selected.timestamp);    
    if(selected.balance==0) {
      return 0;
    } else {
      // calculate reward amount = (balance * rewardRate * stakeDuration)/ (100*year)
      uint256 rewardAmount = (selected.balance.mul(rewardRate).mul(stakeDuration))
        .div(year.mul(100));
      return selected.balance + rewardAmount;
    }
  }

  /**
   * @notice Stake tokens for an account
   * @param account address
   * @param amount uint256
   */
  function _stake(address account, uint256 amount) internal {
    require(amount > 0, "AMOUNT_INVALID");
    require(token.balanceOf(account)>= amount, "INSUFFICIENT_BALANCE");

    if (stakes[account].balance == 0) {
      // update the balance if initial amount is 0
      stakes[account].balance = amount;
      stakes[account].timestamp = block.timestamp;
    } else {
      // else update the balance with staking reward + new staking amount
      stakes[account].balance = available(account).add(amount);
      stakes[account].timestamp = block.timestamp;      
    }
    token.safeTransferFrom(msg.sender, address(this), amount);
    emit StakeAmount (account, amount, stakes[account].timestamp);
  }

  /**
   * @notice Update the balance of amount staked based on withdrawal
   * @param account address
   * @param amount uint256
   */
  function _unstake(address account, uint256 amount) internal {
    Stake storage selected = stakes[account];
    require(amount <= available(account), "AMOUNT_EXCEEDS_AVAILABLE");
    selected.balance = selected.balance.sub(amount);
  }
}
