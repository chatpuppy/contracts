// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

contract Bitmask {
    uint256[8] mask = [
        uint256(0x00000000000000000000000000000000000000000000000000000000ffffffff),
        uint256(0x000000000000000000000000000000000000000000000000ffffffff00000000),
        uint256(0x0000000000000000000000000000000000000000ffffffff0000000000000000),
        uint256(0x00000000000000000000000000000000ffffffff000000000000000000000000),
        uint256(0x000000000000000000000000ffffffff00000000000000000000000000000000),
        uint256(0x0000000000000000ffffffff0000000000000000000000000000000000000000),
        uint256(0x00000000ffffffff000000000000000000000000000000000000000000000000),
        uint256(0xffffffff00000000000000000000000000000000000000000000000000000000)];

    function getRandomnesses(uint256 randomness) public view returns(uint256[] memory) {
        uint256[] memory results = new uint256[](8);
        for(uint i = 0; i < 8; i++) {
		    results[i] = (randomness & mask[i]) >> 32 * i;
        }
        return results;
    }
}