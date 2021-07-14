// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.6;

//import {DSTest} from "test.sol";
import {DSTest} from "ds-test/test.sol";
import {MintableERC20} from "./ERC20.sol";
import {AMM} from "./Amm.sol";

function min(uint _a, uint _b) pure returns (uint) {
	return _a < _b ? _a : _b;
}

contract User {
    MintableERC20 token0;
    MintableERC20 token1;
	AMM pair;
	constructor(MintableERC20 _token0, MintableERC20 _token1, AMM _pair) {
		token0 = _token0;
		token1 = _token1;
		pair = _pair;

		token0.approve(address(pair), type(uint).max);
		token1.approve(address(pair), type(uint).max);
	}

    function join(uint8 amt0, uint8 amt1) external {
		pair.join(amt0, amt1);
	}

    function exit(uint8 shares) external {
		pair.exit(shares);
	}

	function swap1(uint8 amt) external {
		pair.swap(address(token0), address(token1), amt);
	}

	function swap2(uint8 amt) external {
		pair.swap(address(token1), address(token0), amt);
	}
}

contract TestAMM is DSTest {
    MintableERC20 token0;
    MintableERC20 token1;
    AMM pair;

	User user0;
	User user1;
	User user2;

	function targetContracts() public view returns (address[] memory) {
		address[] memory addrs = new address[](3);
		addrs[0] = address(user0);
		addrs[1] = address(user1);
		addrs[2] = address(user2);
		return addrs;
	}

    function setUp() public {
        token0 = new MintableERC20();
        token1 = new MintableERC20();
        pair = new AMM(address(token0), address(token1));

		user0 = new User(token0, token1, pair);
		user1 = new User(token0, token1, pair);
		user2 = new User(token0, token1, pair);

        token0.approve(address(pair), type(uint).max);
        token1.approve(address(pair), type(uint).max);

		uint amt = type(uint).max / 24;

		token0.mint(address(user0), amt);
		token0.mint(address(user1), amt);
		token0.mint(address(user2), amt);

		token1.mint(address(user0), amt);
		token1.mint(address(user1), amt);
		token1.mint(address(user2), amt);
    }

   function invariant_k() public view {
	   pair.invariant_k();
   }
}

/*
contract TestAMMEchidna {
	MintableERC20 token0;
	MintableERC20 token1;
	AMM pair;

	User[3] users;

	constructor() {
		token0 = new MintableERC20();
		token1 = new MintableERC20();
		pair = new AMM(address(token0), address(token1));

		users[0] = new User(token0, token1, pair);
		users[1] = new User(token0, token1, pair);
		users[2] = new User(token0, token1, pair);

		token0.approve(address(pair), type(uint).max);
		token1.approve(address(pair), type(uint).max);

		uint amt = type(uint).max / 24;

		token0.mint(address(users[0]), amt);
		token0.mint(address(users[1]), amt);
		token0.mint(address(users[2]), amt);

		token1.mint(address(users[0]), amt);
		token1.mint(address(users[1]), amt);
		token1.mint(address(users[2]), amt);
	}

	function echidna_k() public returns (bool) {
		return pair.kpost() >= pair.kprev();
	}

	function join(uint8 u, uint8 amt0, uint8 amt1) external {
		users[u%3].join(amt0, amt1);
	}

	function exit(uint8 u, uint8 shares) external {
		users[u%3].exit(shares);
	}

	function swap1(uint8 u, uint8 amt) external {
		users[u%3].swap1(amt);
	}

	function swap2(uint8 u, uint8 amt) external {
		users[u%3].swap2(amt);
	}
}
*/
