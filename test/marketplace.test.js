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

})
