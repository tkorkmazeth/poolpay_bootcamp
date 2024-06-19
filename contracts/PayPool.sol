// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract PayPool is ReentrancyGuard {
    /* START OF STRUCTS */

    // Struct for Depositing Records
    struct DepositRecord {
        address depositor;
        uint256 amount;
        uint256 timestamp;
        DepositStatus status;
    }

    /* END OF STRUCTS */

    enum DepositStatus {
        Pending,
        Approved,
        Rejected
    }

    /* GLB VARS */

    uint public totalBalance;
    address public owner;
    address[] public depositAddresses;
    DepositRecord[] public depositHistory;

    mapping(address => uint256) public allowances;

    /* GLB VARS */

    /* START OF EVENTS */

    event Deposit(address indexed depositor, uint256 amount);
    event AddressAdded(address indexed depositor);
    event AddressRemoved(address indexed depositor);
    event AllowanceGranted(address indexed user, uint amount);
    event AllowanceRemoved(address indexed user);
    event FundsRetrieved(address indexed recipient, uint amount);
    event DepositStatusUpdated(uint256 index, DepositStatus status);

    /* END OF EVENTS */

    /* START OF MODIFIERS */

    modifier isOwner() {
        require(msg.sender == owner, "Not owner!");
        _;
    }

    modifier gotAllowance(address user) {
        require(hasAllowance(user), "This address has no allowance");
        _;
    }

    modifier canDepositTokens(address depositor) {
        require(
            canDeposit(depositor),
            "This address is not allowed to deposit tokens"
        );
        _;
    }

    /* END OF MODIFIERS */

    constructor() payable {
        totalBalance = msg.value;
        owner = msg.sender;
    }

    /* INTERNAL FUNCS */

    function hasAllowance(address user) internal view returns (bool) {
        return allowances[user] > 0;
    }

    function canDeposit(address depositor) internal view returns (bool) {
        for (uint i = 0; i < depositAddresses.length; i++) {
            if (depositAddresses[i] == depositor) {
                return true;
            }
        }
        return false;
    }

    /* INTERNAL FUNCS */
}
