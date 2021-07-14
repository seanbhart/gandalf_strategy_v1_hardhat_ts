// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;

interface IStrategyV1 {
    function status() external view returns (bool);
    function cancel() external;
    function initialize(string memory _symbol, uint256 _start, uint256 _end) external;

    function readVote() external view returns (int256);
    function vote(int256 voteAmount) external;
}
