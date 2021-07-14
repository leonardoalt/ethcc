#!/usr/bin/sh

echo "Running Deposit contract"
hevm symbolic --code $(cat deposit_simplified.bin) --sig "deposit(bytes16,bytes16,bytes16,bytes32,bytes32,bytes32,bytes32,bytes32)"
