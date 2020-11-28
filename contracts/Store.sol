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

    //EVENTS
    event AddedItem(uint indexed id, string name, uint price, uint quantity);
    event RemovedItem(uint indexed id);
    event ChangedPrice(uint indexed id, uint prevPrice, uint price);
    event BoughtItem(uint indexed id, address indexed buyer, uint quantity);
    event DeletedStore(address indexed addr, address indexed owner);
    event WithdrewFunds(address indexed addr, uint amount);

    //MODIFIERS
    // If item does not exist
    modifier itemExists(uint _id) {
        require(items[_id].exists == true, "ERROR: Item does not exist.");
        _;
    }

    // If Markeplace contract is paused
    modifier isNotPaused() {
        Marketplace m = Marketplace(marketplaceAddress);
        bool paused = m.paused();
        require(paused == false, "ERROR: Marketplace is PAUSED");
        _;
    }

    //CONSTRUCTOR
        //NOTE: Be sure to use memory for string parameters!
    constructor(address _owner, address _marketplaceAddr, string memory _name) public {
        // owner = _owner;
        transferOwnership (_owner);
        marketplaceAddress = _marketplaceAddr;
        name = _name;
        itemIterator = 0;
    }

}