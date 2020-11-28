pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./Marketplace.sol";

contract Store is Ownable {
    //Global variables
    address marketplaceAddress;

    mapping(uint => Item) public items;
    string public name;
    uint public itemIterator;

    //"Digital Twin" for the item being sold
    struct Item {
        uint id;
        string name;
        uint price;
        uint quantity;
        bool exists;
    }

}