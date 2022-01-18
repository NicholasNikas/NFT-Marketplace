// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    // build functions to perform safe math operations that would 
    // otherwise replace intuitive preventative measure

    function add(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 r = x + y;
        require(r >= x, 'SafeMath: Addition Overflow!');
        return r;
    }

    function subtract(uint256 x, uint256 y) internal pure returns(uint256) {
        require(y <= x, 'SafeMath: Subtraction Overflow!');
        uint256 r = x - y;
        return r;
    }

    function multiply(uint256 x, uint256 y) internal pure returns(uint256) {
        // gas optimization
        if (x == 0) {
            return 0;
        }
        uint256 r = x * y;
        require(r / x == y, 'SafeMath: Multiplication Overflow!');
        return r;
    }

    function divide(uint256 x, uint256 y) internal pure returns(uint256) {
        require(y > 0, 'SafeMath: Divide Overflow!');
        return x / y;
    }

    function modulo(uint256 x, uint256 y) internal pure returns(uint256) {
        require(y != 0, 'SafeMath: Modulo Overflow!');
        return x % y;
    }
}