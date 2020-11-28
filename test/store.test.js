const Marketplace = artifacts.require('Marketplace');
const Store = artifacts.require('Store');
const Web3 = require('web3');

// Using web3 for eth to wei conversion and for checking balances
web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));

contract('Store', (accounts) => {
  // NOTE: These accounts start from from the second index. accounts[0] will deploy the store
  const alice = accounts[1];
  const bob = accounts[2];
  const charlie = accounts[3];
  const diana = accounts[4];

  // Store values
  const storeName = 'Potion Seller';
  const itemName = 'Potion';
  const itemPrice = web3.toWei(1, 'ether');
  const itemQty = 7;

 /*-----------------------------------------------------------------------------------------------------------------------*/
  /**
   * Test that a store owner is able to both open and close a store.
   */
  it('TEST #1: Can instantiate and delete a store', async () => {
    const instance = await Marketplace.deployed();
    await instance.addStoreOwner(alice);
    await instance.addStore(storeName, { from: alice });

    const stores = await instance.getStores(alice);

    await instance.deleteStore(stores[0], { from: alice });
    const deletedStore = await instance.getStores(alice);

    assert.isTrue(stores.length > 0, 'store added');
    assert.isTrue(deletedStore.length === 0, 'store removed');
  })
  /*-----------------------------------------------------------------------------------------------------------------------*/
  /**
   * Test that a store owner is able to add and remove an item from the store.
   */
  it('TEST #2: Add and remove item from store', async () => {
    const instance = await Marketplace.deployed();
    await instance.addStoreOwner(alice);
    await instance.addStore(storeName, { from: alice });

    const stores = await instance.getStores(alice);
    const storeInstance = await Store.at(stores[0]);

    await storeInstance.addItem(itemName, itemPrice, itemQty, { from: alice, to: stores[0] });
    const itemAdded = await storeInstance.items(0);

    await storeInstance.removeItem(0, { from: alice, to: stores[0] })
    const itemRemoved = await storeInstance.items(0);

    assert.isTrue(itemAdded[1] === itemName, 'potion was added');
    assert.isTrue(itemRemoved[1] === '', 'potion was removed')
  })
  /*-----------------------------------------------------------------------------------------------------------------------*/

})
