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
}
