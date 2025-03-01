// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PiggyBank {
    address public immutable owner;
    string public savingPurpose;
    uint256 public savingDuration;
    uint256 public creationTime;
    bool public isActive;

    address public immutable token1; // First ERC20 token
    address public immutable token2; // Second ERC20 token
    address public immutable token3; // Third ERC20 token

    address public immutable developer; // Developer's address for penalty fees

    mapping(address => uint256) public balances;

    event Deposited(address indexed token, address indexed user, uint256 amount);
    event Withdrawn(address indexed token, address indexed user, uint256 amount);
    event PenaltyApplied(address indexed token, address indexed user, uint256 penaltyAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier isContractActive() {
        require(isActive, "Contract is no longer active");
        _;
    }

    modifier isValidToken(address token) {
        require(token == token1 || token == token2 || token == token3, "Token not allowed");
        _;
    }

    constructor(
        string memory _purpose,
        uint256 _duration,
        address _token1,
        address _token2,
        address _token3,
        address _developer
    ) {
        owner = msg.sender;
        savingPurpose = _purpose;
        savingDuration = _duration;
        creationTime = block.timestamp;
        isActive = true;

        token1 = _token1;
        token2 = _token2;
        token3 = _token3;

        developer = _developer; // Set the developer's address
    }

    function deposit(address token, uint256 amount) external isContractActive isValidToken(token) {
        require(amount > 0, "Amount must be greater than 0");

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        balances[token] += amount;

        emit Deposited(token, msg.sender, amount);
    }

    function withdraw(address token) external onlyOwner isContractActive isValidToken(token) {
        require(balances[token] > 0, "No balance to withdraw");

        uint256 amount = balances[token];
        uint256 penalty = 0;

        if (block.timestamp < creationTime + savingDuration) {
            penalty = (amount * 15) / 100;
            amount -= penalty;
            IERC20(token).transfer(developer, penalty);
            emit PenaltyApplied(token, msg.sender, penalty);
        }

        IERC20(token).transfer(owner, amount);
        balances[token] = 0;

        emit Withdrawn(token, msg.sender, amount);

        // Deactivate the contract after withdrawal
        isActive = false;
    }

    function getBalance(address token) external view returns (uint256) {
        return balances[token];
    }
}