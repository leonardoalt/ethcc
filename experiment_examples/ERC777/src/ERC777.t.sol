pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./ERC777.sol";
import "./ERC777Mutex.sol";

contract Rec is IERC777Sender, IERC777Recipient {
	IERC777 immutable erc;

	constructor(IERC777 _erc) {
		erc = _erc;
	}

	function tokensReceived(address, address, address, uint256 amount) public override {
		erc.burn(amount);
	}

	function tokensToSend(address, address, address, uint256 amount) public override {}
}

contract ERC777Test is DSTest, IERC777Sender {
	ERC777 erc;
	Rec rec;

	uint constant AMT = 10000;

	function setUp() public {
		erc = new ERC777("", "", AMT);
		rec = new Rec(erc);
	}

	function test_totalSupply() public {
		erc.transfer(address(rec), 100);
	}

	function tokensToSend(address, address, address, uint256 amount) public override {}
}







