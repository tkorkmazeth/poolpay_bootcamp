// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./helpers/Errors.sol";
import "./helpers/Events.sol";
import "./helpers/Struct.sol";
import "./helpers/Modifiers.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract PayPool is ReentrancyGuard, Events, Errors, Structs {
    /* GLB VARS */

    uint public totalBalance;
    address public owner;
    address[] public depositAddresses;
    DepositRecord[] public depositHistory;

    mapping(address => uint256) public allowances;

    /* START OF MODIFIERS */

    modifier isOwner() {
        if (msg.sender != owner) {
            revert InvalidOwner(msg.sender);
        }
        _;
    }

    modifier gotAllowance(address user) {
        if (!hasAllowance(user)) {
            revert HasNoAllowance(user);
        }
        _;
    }

    modifier canDepositTokens(address depositor) {
        if (!canDeposit(depositor)) {
            revert NotAllowedToDeposit(depositor);
        }
        _;
    }

    /* END OF MODIFIERS */

    /* GLB VARS */

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

    /* STATE CHANGER FUNCS */

    function addDepositAddress(address depositor) external isOwner {
        depositAddresses.push(depositor);
        emit AddressAdded(depositor);
    }

    function removeDepositAddress(
        uint index
    ) external isOwner canDepositTokens(depositAddresses[index]) {
        address removedAddress = depositAddresses[index];
        depositAddresses[index] = depositAddresses[depositAddresses.length - 1];
        depositAddresses.pop();
        emit AddressRemoved(removedAddress);
    }

    function deposit() external payable canDepositTokens(msg.sender) {
        totalBalance += msg.value;

        DepositRecord memory newRecord = DepositRecord({
            depositor: msg.sender,
            amount: msg.value,
            timestamp: block.timestamp,
            status: DepositStatus.Pending
        });

        depositHistory.push(newRecord);
        emit Deposit(msg.sender, msg.value);
    }

    function approveDeposit(uint256 index) external isOwner {
        if (index >= depositHistory.length) {
            revert InvalidIndex();
        }

        depositHistory[index].status = DepositStatus.Approved;
        emit DepositStatusUpdated(index, DepositStatus.Approved);
    }

    function rejectDeposit(uint256 index) external isOwner {
        if (index >= depositHistory.length) {
            revert InvalidIndex();
        }
        depositHistory[index].status = DepositStatus.Rejected;
        emit DepositStatusUpdated(index, DepositStatus.Rejected);
    }

    function giveAllowance(uint amount, address user) external isOwner {
        if (totalBalance < amount) {
            revert InsufficientBalance();
        }
        allowances[user] = amount;
        unchecked {
            totalBalance -= amount;
        }
        emit AllowanceGranted(user, amount);
    }

    function allowRetrieval() external gotAllowance(msg.sender) nonReentrant {
        uint amount = allowances[msg.sender];
        (bool success, ) = msg.sender.call{value: amount}("");

        if (!success) {
            revert RetrievalFailed();
        }

        allowances[msg.sender] = 0;
        emit FundsRetrieved(msg.sender, amount);
    }

    function removeAllowance(address user) external isOwner gotAllowance(user) {
        allowances[user] = 0;
        emit AllowanceRemoved(user);
    }

    /* STATE CHANGER FUNCS */

    /* READ ONLY FUNCS */

    function getDepositHistory()
        external
        view
        returns (DepositRecord[] memory)
    {
        return depositHistory;
    }

    function retrieveBalance() external isOwner nonReentrant {
        uint balance = totalBalance;
        (bool success, ) = owner.call{value: balance}("");

        if (!success) {
            revert TransferFailed();
        }

        totalBalance = 0;
        emit FundsRetrieved(owner, balance);
    }

    /* READ ONLY FUNCS */
}
