const Marketplace = artifacts.require('Marketplace');
const Store = artifacts.require('Store');
const Web3 = require('web3');

// Using web3 for eth to wei conversion and for checking balances
web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));

contract('Store', (accounts) => {
  // NOTE: These accounts start from from the second index
  // NOTE: accounts[0] will deploy the store
  const alice = accounts[1];
  const bob = accounts[2];
  const charlie = accounts[3];
  const diana = accounts[4];

  // Store values
  const storeName = 'Foodstuff Merchant';
  const itemName = 'Turkey';
  const itemPrice = web3.toWei(1, 'ether');
  const itemQty = 7;

 /*-----------------------------------------------------------------------------------------------------------------------*/
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

    assert.isTrue(itemAdded[1] === itemName, 'turkey was added');
    assert.isTrue(itemRemoved[1] === '', 'turkey was removed')
  })
  /*-----------------------------------------------------------------------------------------------------------------------*/
  it('TEST #3: Change item price successfully', async () => {
    const priceChange = web3.toWei(42, 'ether');
    const instance = await Marketplace.deployed();
    await instance.addStoreOwner(bob);
    await instance.addStore(storeName, { from: bob });

    const stores = await instance.getStores(bob);
    const storeInstance = await Store.at(stores[0]);
    await storeInstance.addItem(itemName, itemPrice, itemQty, { from: bob, to: storeInstance.address });
    await storeInstance.changePrice(0, priceChange, { from: bob, to: storeInstance.address });

    const item = await storeInstance.items(0);
    // web3.fromWei() returns a string
    const priceInEther = web3.fromWei(item[2], 'ether');
    
    assert.isTrue(priceInEther === '42', 'changed price')
  })
  /*-----------------------------------------------------------------------------------------------------------------------*/
  it('TEST #4: Purchase item successfully', async () => {
    const qtyBuying = 3;
    const instance = await Marketplace.deployed();
    await instance.addStoreOwner(charlie);
    await instance.addStore(storeName, { from: charlie });

    const stores = await instance.getStores(charlie);
    const storeInstance = await Store.at(stores[0]);
    await storeInstance.addItem(itemName, itemPrice, itemQty, { from: charlie, to: storeInstance.address });
    await storeInstance.buyItem(0, qtyBuying, { from: bob, to: storeInstance.address, value: qtyBuying * itemPrice });

    const item = await storeInstance.items(0);

    assert.isTrue(item[3].toNumber() === itemQty - qtyBuying, 'bought item successfully');
  })
/*-----------------------------------------------------------------------------------------------------------------------*/
  it('TEST #5: Withdraw funds successfully', async () => {
    const qtyBuying = 3;
    const instance = await Marketplace.deployed();
    await instance.addStoreOwner(diana);
    await instance.addStore(storeName, { from: diana });

    const stores = await instance.getStores(diana);
    const storeInstance = await Store.at(stores[0]);
    await storeInstance.addItem(itemName, itemPrice, itemQty, { from: diana, to: stores[0] });
    await storeInstance.buyItem(0, qtyBuying, { from: bob, to: stores[0], value: qtyBuying * itemPrice });

    const dianaBalance = web3.eth.getBalance(diana);
    const storeBalance = web3.eth.getBalance(stores[0]);
    await storeInstance.withdrawFunds(storeBalance, { from: diana, to: stores[0] });
    const dianaBalanceAfterWithdrawal = web3.eth.getBalance(diana);

    const beforeWithdrawal = web3.fromWei(dianaBalance, 'ether');
    const afterWithrawal = web3.fromWei(dianaBalanceAfterWithdrawal, 'ether')

    assert.isTrue(beforeWithdrawal.lt(afterWithrawal), 'diana withdrew successfully');
  })
  
})
