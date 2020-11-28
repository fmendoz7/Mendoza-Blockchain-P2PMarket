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
    /*------------------------------------------------------------------------------------------------------------------*/
    //EVENTS
    event AddedItem(uint indexed id, string name, uint price, uint quantity);
    event RemovedItem(uint indexed id);
    event ChangedPrice(uint indexed id, uint prevPrice, uint price);
    event BoughtItem(uint indexed id, address indexed buyer, uint quantity);
    event DeletedStore(address indexed addr, address indexed owner);
    event WithdrewFunds(address indexed addr, uint amount);
    /*------------------------------------------------------------------------------------------------------------------*/
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
    /*------------------------------------------------------------------------------------------------------------------*/
    //CONSTRUCTOR
        //NOTE: Be sure to use memory for string parameters!
    constructor(address _owner, address _marketplaceAddr, string memory _name) public {
        // owner = _owner;
        transferOwnership (_owner);
        marketplaceAddress = _marketplaceAddr;
        name = _name;
        itemIterator = 0;
    }
    /*------------------------------------------------------------------------------------------------------------------*/
    //PURPOSE: Get properties of the store as a tuple
    function getValues() public view returns (address, address, string memory, uint) {
        return (owner(), marketplaceAddress, name, itemIterator);
    }
    /*------------------------------------------------------------------------------------------------------------------*/
    //PURPOSE: Add item to store inventory
    function addItem(string memory _name, uint _price, uint _quantity) public onlyOwner isNotPaused {
        emit AddedItem(itemIterator, _name, _price, _quantity);
        items[itemIterator] = Item(itemIterator, _name, _price, _quantity, true);
        itemIterator = SafeMath.add(itemIterator, 1);
    }
    /*------------------------------------------------------------------------------------------------------------------*/
    //PURPOSE: Remove item from store inventory
    function removeItem(uint _id) public itemExists(_id) onlyOwner isNotPaused {
        emit RemovedItem(_id);
        delete items[_id];
    }
    /*------------------------------------------------------------------------------------------------------------------*/
    //PURPOSE: Change price of an item
    function changePrice(uint _id, uint _price) public itemExists(_id) onlyOwner isNotPaused {
        emit ChangedPrice(_id, items[_id].price, _price);
        items[_id].price = _price;
    }
    /*------------------------------------------------------------------------------------------------------------------*/
    //PURPOSE: Purchase item
    function buyItem(uint _id, uint _quantity) public payable itemExists(_id) isNotPaused {
        require(items[_id].price <= msg.value, "ERROR: Insufficient Funds.");
        require(items[_id].quantity >= _quantity, "ERROR: Insufficient Stock Of Item.");
        emit BoughtItem(_id, msg.sender, _quantity);
        items[_id].quantity = items[_id].quantity - _quantity;
    }
    /*------------------------------------------------------------------------------------------------------------------*/
    //PURPOSE: Delete Store Instance
    function deleteStore() external isNotPaused {
        // Verify that call is made from the marketplace contract
        require(msg.sender == marketplaceAddress, "ERROR: You do NOT have permission to perform this action.");
        emit DeletedStore(address(this), owner());
        // cast to address(uint160) to make address payable
        selfdestruct(address(uint160(owner())));
    }
    /*------------------------------------------------------------------------------------------------------------------*/
    //PURPOSE: Withdraw funds
    function withdrawFunds(uint _amount) public onlyOwner {
        require(_amount <= address(this).balance, "ERROR: Withdrawal amount exceeds available balance.");
        emit WithdrewFunds(owner(), _amount);
        // cast to address(uint160) to make address payable
        address(uint160(owner())).transfer(_amount);
    }
}