// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Enums.sol";

interface Events is Enums {
    /* START OF EVENTS */

    event Deposit(address indexed depositor, uint256 amount);
    event AddressAdded(address indexed depositor);
    event AddressRemoved(address indexed depositor);
    event AllowanceGranted(address indexed user, uint amount);
    event AllowanceRemoved(address indexed user);
    event FundsRetrieved(address indexed recipient, uint amount);
    event DepositStatusUpdated(uint256 index, DepositStatus status);

    /* END OF EVENTS */
}
