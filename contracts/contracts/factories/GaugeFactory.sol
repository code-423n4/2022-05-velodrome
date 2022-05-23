// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import '../Gauge.sol';
import '../interfaces/IPairFactory.sol';

contract GaugeFactory {
    address public last_gauge;
    address public team;
    address immutable pairFactory;

    constructor(address _pairFactory) {
        team = msg.sender;
        pairFactory = _pairFactory;
    }

    function setTeam(address _team) external {
        require(msg.sender == team);
        team = _team;
    }

    function createGauge(address _pool, address _bribe, address _ve) external returns (address) {
        bool isPair = IPairFactory(pairFactory).isPair(_pool);
        last_gauge = address(new Gauge(_pool, _bribe, _ve, msg.sender, isPair));
        return last_gauge;
    }

    function createGaugeSingle(address _pool, address _bribe, address _ve, address _voter) external returns (address) {
        bool isPair = IPairFactory(pairFactory).isPair(_pool);
        last_gauge = address(new Gauge(_pool, _bribe, _ve, _voter, isPair));
        return last_gauge;
    }
}
