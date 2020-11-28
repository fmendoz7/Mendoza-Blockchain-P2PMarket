pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/lifecycle/Pausable.sol";

//Utilize Ownable and Pausable libraries from openzeppelin
contract Marketplace is Ownable, Pauasable {

    //Address mappings of admins, storeOwners, stores
    mapping(address => bool) public admins;
    mapping(address => bool) public storeOwners;
    mapping(address => Store[]) public stores;

    //Events to add/revoke various privileges, add/delete stores
    event AddedAdmin(address indexed addr);
    event RemovedAdmin(address indexed addr);
    event AddedStoreOwner(address indexed addr);
    event RemovedStoreOwner(address indexed addr);
    event AddedStore(address indexed owner, string name);
    event DeletedStore(address indexed addr, address indexed owner);
    /*------------------------------------------------------------------------------------------------------------------*/
    // Scenario: Non-admin user makes call
    modifier onlyAdmin() {
        require(admins[msg.sender] == true, "ERROR: You do not have permission to perform this action.");
        _;
    }

    // Scenario: Non-owner user makes call
    modifier onlyStoreOwner() {
        require(storeOwners[msg.sender] == true, "ERROR: You are NOT a store owner.");
        _;
    }

    // Scenario: User that doesn't own specific store makes call
    modifier validStoreOwner() {
        bool exists = false;
        Store[] memory storeList = stores[msg.sender];
        for (uint i = 0; i < storeList.length; i++) {
            if (storeList[i].owner() == msg.sender) {
                exists = true;
            }
        }
        require(exists, "ERROR: You are NOT the DESIGNATED store owner.");
        _;
    }
    /*------------------------------------------------------------------------------------------------------------------*/
    constructor() public {
        transferOwnership(msg.sender);
        admins[msg.sender] = true;
    }
    /*------------------------------------------------------------------------------------------------------------------*/

    //PURPOSE: Append new address to admin mapping
    function addAdmin(address _addr) public onlyAdmin whenNotPaused {
        emit AddedAdmin(_addr);
        admins[_addr] = true;
    }

    //PURPOSE: Revoke admin privileges by setting checkBool to false
    function removeAdmin(address _addr) public onlyOwner whenNotPaused {
        require(_addr != owner(), "ERROR: You do NOT have owner removal privileges.");
        emit RemovedAdmin(_addr);
        admins[_addr] = false;
    }

    //PURPOSE: Append new address to store owner mapping
    function addStoreOwner(address _addr) public onlyAdmin whenNotPaused {
        emit AddedStoreOwner(_addr);
        storeOwners[_addr] = true;
    }

    //PURPOSE: Revoke store owner privileges by setting checkBool to false
    function removeStoreOwner(address _addr) public onlyAdmin whenNotPaused {
        emit RemovedStoreOwner(_addr);
        storeOwners[_addr] = false;
    }

    //PURPOSE: Getter method for list of stores
    function getStores(address _addr) public view returns (Store[] memory) {
        return stores[_addr];
    }

    //PURPOSE: Getter methods for store values
    function getStoreValues(Store _store) public view returns (address, address, string memory, uint) {
        return _store.getValues();
    }

    //PURPOSE: Add a store
    function addStore(string memory _name) public onlyStoreOwner whenNotPaused returns (Store storeAddress) {
        emit AddedStore(msg.sender, _name);
        Store store = new Store(msg.sender, address(this), _name);
        Store[] memory existingStores = stores[msg.sender];
        Store[] memory storeList = new Store[](existingStores.length + 1);

        for (uint i = 0; i < existingStores.length; i++) {
            storeList[i] = existingStores[i];
        }

        storeList[storeList.length - 1] = store;

        stores[msg.sender] = storeList;
        return store;
    }

    //PURPOSE: Delete a store
    function deleteStore(address _addr) public validStoreOwner whenNotPaused {
        emit DeletedStore(_addr, msg.sender);
        Store[] memory existingStores = stores[msg.sender];
        Store[] memory storeList = new Store[](existingStores.length - 1);
        uint counter = 0;

        for (uint i = 0; i < existingStores.length; i++) {
            if (address(existingStores[i]) != _addr) {
                storeList[counter] = existingStores[i];
                counter++;
            }
        }

        stores[msg.sender] = storeList;
        Store(_addr).deleteStore();
    }
}
