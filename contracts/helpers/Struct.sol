// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Enums.sol";

interface Structs is Enums {
    /* START OF STRUCTS */

    // Struct for Depositing Records
    struct DepositRecord {
        address depositor;
        uint256 amount;
        uint256 timestamp;
        DepositStatus status;
    }

    /* END OF STRUCTS */
}
