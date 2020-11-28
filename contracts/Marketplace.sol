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
}
