// This work is marked with CC0 1.0 Universal.
//
// SPDX-License-Identifier: CC0-1.0
//
// To view a copy of this license, visit http://creativecommons.org/publicdomain/zero/1.0

import {PackedUserOperation} from "./PackedUserOperation.sol";

pragma solidity ^0.8.23;

interface IAccountExecute {
  function executeUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash) external;
}