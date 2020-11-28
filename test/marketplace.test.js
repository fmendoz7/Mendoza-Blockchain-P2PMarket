var Marketplace = artifacts.require('Marketplace');

contract('Marketplace', (accounts) => {
  // NOTE: Because Alice is the first index of the accounts array, the Marketplace contract is always going to be
  // deployed from her account during these tests
  const alice = accounts[0];
  const bob = accounts[1];
  const charlie = accounts[2];

  /**
   * The address that deploys the Marketplace contract should become the owner of the contract and an admin.
   */
  it('TEST #1: Instantiate user as admin and owner of the marketplace', async () => {
    const instance = await Marketplace.deployed();
    const result = await instance.admins(alice);
    const marketplaceOwner = await instance.owner();

    assert.isTrue(result, 'LOG: alice is admin');
    assert.isTrue(marketplaceOwner === alice, 'LOG: alice is marketplace owner')
  })
  /*---------------------------------------------------------------------------------------------------------------------*/
  /**
   * This test should try adding a user as an admin and then removing that user from admin.
   */
  it('TEST #2: Successfully add and revoke an admin user', async () => {
    const instance = await Marketplace.deployed();

    await instance.addAdmin(bob);
    const addAdmin = await instance.admins(bob);

    await instance.removeAdmin(bob);
    const removeAdmin = await instance.admins(bob);

    assert.isTrue(addAdmin, 'LOG: bob is admin');
    assert.isFalse(removeAdmin, 'LOG: bob admin privileges revoked');
  })
/*---------------------------------------------------------------------------------------------------------------------*/   
  /**
   * Non-admins should not be able to add addresses to neither the admins nor storeOwners mapping. This test verifies
   * that non-admins do not have those privileges.
   */
  it('TEST #3: Users with non-admin privileges cannot take admin actions nor mod admin fields', async () => {
    const instance = await Marketplace.deployed();

    //Scenario #1: Malicious regular user (Charlie) cannot add address to admin Bob
    try {
      await instance.addAdmin(bob, { from: charlie });
    } 
    
    catch (error) {
      const revertFound = error.message.search('revert') >= 0;
      assert(revertFound, `LOG: Expected "revert", got ${error} instead`);
    }

    //Scenario #2: Malicious regular user (Charlie) cannot add addresses to store owner Bob
    try {
      await instance.addStoreOwner(bob, { from: charlie });
    } 
    
    catch (error) {
      const revertFound = error.message.search('revert') >= 0;
      assert(revertFound, `LOG: Expected "revert", got ${error} instead`);
      return;
    }

    assert.fail('LOG: Expected revert not received');
  })

})
