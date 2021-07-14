// StrategyMarket.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import 'hardhat/console.sol';
import './interfaces/IStrategyV1.sol';


contract StrategyV1Market is IStrategyV1, Ownable {
    address public factory;
    address private creator;
    string private symbol;
    uint256 private start;
    uint256 private end;
    bool private active;
    mapping(address => int256) votes;

    event NewVote(address address_, int256 vote);

    constructor() Ownable() {
        factory = msg.sender;
        
    }

    // called once by the factory at time of deployment
    // start and end should be epoch timestamps in seconds.
    function initialize(string memory _symbol, uint256 _start, uint256 _end) external override onlyOwner {
        require(msg.sender == factory, 'GandalfV1: FORBIDDEN');

        console.log("Creating strategy for %s. Start: %d, End: %d", _symbol, _start, _end);
        creator = msg.sender;
        symbol = _symbol;
        start = _start;
        end = _end;
        active = true;
        votes[msg.sender] = 1; // Creator automatically votes positively initially.
    }

    function status() override public view returns (bool) {
        return active;
    }

    function cancel() override public onlyOwner {
        require(block.timestamp < start, "We're sorry, you cannot cancel a strategy after the performance window has started.");
        active = false;
    }

    function readVote() override public view returns (int256) {
        return votes[msg.sender];
    }

    function vote(int256 voteAmount) override public {
        console.log("vote amount: %x", voteAmount > 0 ? true : false);
        // TODO: update timestamp check to more accurate time source
        require(active && block.timestamp < start, "We're sorry, you cannot vote after the performance window has started.");
        // Ignore repeat votes and votes outside the acceptable range.
        // require(_votes[msg.sender] != voteAmount, "You already voted!");
        require(voteAmount == 1 || voteAmount == -1, "Sorry, you can't vote more than once!");

        // A vote could be a first time vote or a vote change.
        // A first time vote involves transfer of ERC20 to escrow.
        // A vote change that switches votes does not involve a transfer.
        // A vote change that reverses the current vote involves a transfer of ERC20 out of escrow.
        // votes[msg.sender] = voteAmount;
        if (votes[msg.sender] != 0 && votes[msg.sender] != voteAmount) {
            // switch the vote (no transfer needed)
            votes[msg.sender] = voteAmount;
            emit NewVote(msg.sender, voteAmount);
        } else if (votes[msg.sender] == 0) {
            // First time voter - transfer of ERC20 into escrow.
            votes[msg.sender] = voteAmount;
            emit NewVote(msg.sender, voteAmount);
        } else {
            require(false, "You already voted!");
        }
    }
}
