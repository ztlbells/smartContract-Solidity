pragma solidity ^0.4.13;

contract SimpleStorage {
  uint storedData;

  function set(uint x) public {
    storedData = x;
  }

  function get() constant returns (uint) {
    return storedData;
  }
}
