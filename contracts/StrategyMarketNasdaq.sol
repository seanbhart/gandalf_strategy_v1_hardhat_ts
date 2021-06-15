// StrategyMarketNasdaq.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";


contract StrategyMarketNasdaq is Ownable {
    address private _creator;
    string private _symbol;
    uint256 private _windowStart;
    uint256 private _windowEnd;
    bool private _active;
    mapping(address => int256) _votes;

    event NewVote(address address_, int256 vote);

    // windowStart and windowEnd should be epoch timestamps in seconds.
    constructor(string memory symbol, uint256 windowStart, uint256 windowEnd) Ownable() {
        console.log("Creating strategy for %s. Start: %d, End: %d", symbol, windowStart, windowEnd);
        _creator = msg.sender;
        _symbol = symbol;
        _windowStart = windowStart;
        _windowEnd = windowEnd;
        _active = true;
        _votes[msg.sender] = 1; // Creator automatically votes positively initially.
    }

    function status() public view returns (bool) {
        return _active;
    }

    function cancel() public onlyOwner {
        require(block.timestamp < _windowStart, "We're sorry, you cannot cancel a strategy after the performance window has started.");
        _active = false;
    }

    function readVote() public view returns (int256) {
        return _votes[msg.sender];
    }

    function vote(int256 voteAmount) public {
        console.log("vote amount: %x", voteAmount > 0 ? true : false);
        // TODO: update timestamp check to more accurate time source
        require(_active && block.timestamp < _windowStart, "We're sorry, you cannot vote after the performance window has started.");
        // Ignore repeat votes and votes outside the acceptable range.
        // require(_votes[msg.sender] != voteAmount, "You already voted!");
        require(voteAmount == 1 || voteAmount == -1, "Sorry, you can't vote more than once!");

        // A vote could be a first time vote or a vote change.
        // A first time vote involves transfer of ERC20 to escrow.
        // A vote change that switches votes does not involve a transfer.
        // A vote change that reverses the current vote involves a transfer of ERC20 out of escrow.
        // _votes[msg.sender] = voteAmount;
        if (_votes[msg.sender] != 0 && _votes[msg.sender] != voteAmount) {
            // switch the vote (no transfer needed)
            _votes[msg.sender] = voteAmount;
            emit NewVote(msg.sender, voteAmount);
        } else if (_votes[msg.sender] == 0) {
            // First time voter - transfer of ERC20 into escrow.
            _votes[msg.sender] = voteAmount;
            emit NewVote(msg.sender, voteAmount);
        } else {
            require(false, "You already voted!");
        }
    }
}

