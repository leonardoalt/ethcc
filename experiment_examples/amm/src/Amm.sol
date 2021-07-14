// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.6;

import {ERC20} from "./ERC20.sol";

function min(uint _a, uint _b) pure returns (uint) {
	return _a < _b ? _a : _b;
}

contract AMM is ERC20 {
    ERC20 token0;
    ERC20 token1;

	uint KPrev;
	uint KPost;

    constructor(address _token0, address _token1) {
        token0 = ERC20(_token0);
        token1 = ERC20(_token1);
    }

    // swap allows the caller to exchange amt of src for dst at a price given
    // by the constant product formula: x * y == k.
    function swap(address src, address dst, uint amt) external {
        require(src != dst, "no self swap");
        require(src == address(token0) || src == address(token1), "src not in pair");
        require(dst == address(token0) || dst == address(token1), "dst not in pair");

        KPrev = token0.balanceOf(address(this)) * token1.balanceOf(address(this));

        ERC20(src).transferFrom(msg.sender, address(this), amt);

        uint out =
            ERC20(dst).balanceOf(address(this)) -
            (KPrev / ERC20(src).balanceOf(address(this)));
            //(KPrev / ERC20(src).balanceOf(address(this)) + 1);

        ERC20(dst).transfer(msg.sender, out);

        KPost = token0.balanceOf(address(this)) * token1.balanceOf(address(this));
    }

	function invariant_k() public view {
		assert(KPost >= KPrev);
	}

	function kprev() public view returns (uint) {
		return KPrev;
	}

	function kpost() public view returns (uint) {
		return KPost;
	}

    // join allows the caller to exchange amt0 and amt1 tokens for some amount
    // of pool shares. The exact amount of pool shares minted depends on the
    // state of the pool at the time of the call.
    function join(uint amt0, uint amt1) external {
        require(amt0 > 0 && amt1 > 0, "insufficient input amounts");

        uint bal0 = token0.balanceOf(address(this));
        uint bal1 = token1.balanceOf(address(this));

		uint shares = totalSupply == 0
			? min(amt0, amt1)
                      : min((totalSupply * amt0) / bal0,
							(totalSupply * amt1) / bal1);

        balanceOf[msg.sender] += shares;
        totalSupply += shares;

        token0.transferFrom(msg.sender, address(this), amt0);
        token1.transferFrom(msg.sender, address(this), amt1);
    }

    // exit allows the caller to exchange shares pool shares for the
    // proportional amount of the underlying tokens.
    function exit(uint shares) external {
        uint amt0 = (token0.balanceOf(address(this)) * shares) / totalSupply;
        uint amt1 = (token1.balanceOf(address(this)) * shares) / totalSupply;

        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;

        token0.transfer(msg.sender, amt0);
        token1.transfer(msg.sender, amt1);
    }
}
