// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

contract Token {
	mapping (address => uint) balance;
	address immutable owner;

	constructor(uint _amt) {
		owner = msg.sender;
		balance[msg.sender] = _amt;
	}

	function balanceOf(address _user) public view returns (uint) {
		return balance[_user];
	}

	function transfer(address _to, uint _amt) public {
		require(msg.sender != _to);
		require(balance[msg.sender] >= _amt);

		uint prevBal = balance[msg.sender] + balance[_to];

		balance[msg.sender] -= _amt;
		balance[_to] += _amt;

		uint postBal = balance[msg.sender] + balance[_to];

		assert(prevBal == postBal);
	}
}
