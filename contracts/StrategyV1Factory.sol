// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/IStrategyV1.sol';
import './StrategyV1Market.sol';

contract StrategyV1Factory is Ownable {
    // address public feeRecipient;
    // address public feeRecipientSetter;

    // mapping(address => address[]) public getStrategy;
    mapping(string => mapping(uint256 => mapping(uint256 => address))) public getStrategy;
    address[] public strategyList;

    event StrategyCreated(address indexed creator, string symbol, uint256 start, uint256 end, address strategy, uint256 strategyListLength);

    // constructor(address _feeRecipient) {
    //     feeRecipient = _feeRecipient;
    // }
    constructor() Ownable() {}

    function strategyListLength() external view returns (uint256) {
        return strategyList.length;
    }

    function createStrategy(string memory symbol, uint256 start, uint256 end) external {
        require(getStrategy[symbol][start][end] == address(0), 'StrategyV1: STRATEGY_EXISTS');

        address strategy;
        bytes memory bytecode = type(StrategyV1Market).creationCode;
        bytes32 salt = keccak256(abi.encodePacked('StrategyV1', symbol, start, end));
        assembly {
            strategy := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IStrategyV1(strategy).initialize(symbol, start, end);
        getStrategy[symbol][start][end] = strategy;
        strategyList.push(strategy);

        emit StrategyCreated(msg.sender, symbol, start, end, strategy, strategyList.length);
    }
}
