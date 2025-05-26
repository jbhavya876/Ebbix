// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Web3YouTube {
    struct User {
        address wallet;
        bool registered;
        uint subscribers;
    }

    struct Content {
        address creator;
        string metadata;
        bool uploaded;
    }

    address public owner;
    uint public contentCount = 0;
    uint public rewardThreshold = 100; // Default threshold for subscribers
    uint public rewardAmount = 0.01 ether; // Default reward amount

    mapping(address => User) public users;
    mapping(uint => Content) public contents;

    event UserRegistered(address indexed user);
    event ContentUploaded(uint contentId, address indexed creator, string metadata);
    event Subscribed(address indexed subscriber, address indexed creator);
    event RewardDistributed(address indexed creator, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User not registered");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Register a new user
    function registerUser() public {
        require(!users[msg.sender].registered, "User already registered");
        users[msg.sender] = User(msg.sender, true, 0);
        emit UserRegistered(msg.sender);
    }

    // Upload content
    function uploadContent(string memory metadata) public onlyRegistered {
        contents[contentCount] = Content(msg.sender, metadata, true);
        contentCount++;
        emit ContentUploaded(contentCount - 1, msg.sender, metadata);
    }

    // Subscribe to a content creator
    function subscribe(address creator) public onlyRegistered {
        require(users[creator].registered, "Creator not registered");
        users[creator].subscribers++;
        emit Subscribed(msg.sender, creator);

        // Reward creator if they cross the threshold
        if (users[creator].subscribers == rewardThreshold) {
            distributeReward(creator);
        }
    }

    // Distribute reward to the creator
    function distributeReward(address creator) internal {
        require(address(this).balance >= rewardAmount, "Insufficient contract balance");
        payable(creator).transfer(rewardAmount);
        emit RewardDistributed(creator, rewardAmount);
    }

    // Allow owner to fund the contract
    function fundContract() public payable onlyOwner {}

    // Update reward threshold
    function updateRewardThreshold(uint newThreshold) public onlyOwner {
        rewardThreshold = newThreshold;
    }

    // Update reward amount
    function updateRewardAmount(uint newAmount) public onlyOwner {
        rewardAmount = newAmount;
    }

    // Withdraw contract balance (only owner)
    function withdrawBalance() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Get contract balance
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
