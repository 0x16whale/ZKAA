//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

interface IUserOperation{
    struct UserOperation {
        address sender;
        uint256 nonce;
        uint64 chainId;
        bytes initCode;
        bytes callData;
        uint256 callGasLimit;
        uint256 verificationGasLimit;
        uint256 preVerificationGas;
        uint256 maxFeePerGas;
        uint256 maxPriorityFeePerGas;
        bytes paymasterAndData;
        bytes signature;
    }

    struct Ticket {
        address user;
        uint256 amount;
        uint256 timestamp;
    }
}