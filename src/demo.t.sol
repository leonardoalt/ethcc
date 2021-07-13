// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.7.4;

import "ds-test/test.sol";
import "./BytesLib.sol";

contract Demo is DSTest {
    function testSlice(bytes memory a, uint8 len, uint8 start) public {
        if (len + start < len)      return; // overflow check
        if (len + start > a.length) return; // ensure correct usage
        new DSTest();
        bytes memory res = BytesLib.slice(a, start, len);
        log_named_uint("res length: ", res.length);
        logs(res);
        assertEq(len, res.length);
    }
}
