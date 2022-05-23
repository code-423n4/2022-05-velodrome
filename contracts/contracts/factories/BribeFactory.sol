// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import '../Bribe.sol';

contract BribeFactory {
    address public last_gauge;

    function createBribe() external returns (address) {
        last_gauge = address(new Bribe());
        return last_gauge;
    }
}
