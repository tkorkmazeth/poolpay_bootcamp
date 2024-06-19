// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface Errors {
    error InvalidIndex();
    error InvalidOwner(address owner);
    error HasNoAllowance(address spender);
    error NotAllowedToDeposit(address depositor);
    error InsufficientBalance();
    error RetrievalFailed();
    error TransferFailed();
}
