
@isTest
private class AddPrimaryContactTest {

    @testSetup
    static void setupData() {
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < 50; i++) {
            accs.add(new Account(Name = 'Test Account NY' + i, BillingState = 'NY'));
            accs.add(new Account(Name = 'Test Account CA' + i, BillingState = 'CA'));
        }
        insert accs;
    }

    @isTest
    static void createsContactsForStateCA_upTo200() {
        // Source contact to clone
        Contact srcContact = new Contact(FirstName = 'Test', LastName = 'Last');

        Test.startTest();
        AddPrimaryContact job = new AddPrimaryContact(srcContact, 'CA');
        System.enqueueJob(job);
        Test.stopTest();

        List<Contact> insertedContacts = [
            SELECT Id, AccountId
            FROM Contact
            WHERE Account.BillingState = 'CA'
        ];
        System.assertEquals(50, insertedContacts.size(), 'Should create one Contact per CA Account');
        for (Contact c : insertedContacts) {
            System.assertNotEquals(null, c.AccountId, 'Contact must be related to an Account');
        }
    }

    @isTest
    static void noContactsWhenNoMatchingAccounts() {
        // Use a state with no accounts
        Contact srcContact = new Contact(FirstName = 'Test2', LastName = 'User');

        Test.startTest();
        AddPrimaryContact job = new AddPrimaryContact(srcContact, 'TX');
        System.enqueueJob(job);
        Test.stopTest();

        Integer countTx = [SELECT count() FROM Contact WHERE Account.BillingState = 'TX'];
        System.assertEquals(0, countTx, 'No contacts should be created when no accounts match');
    }
}
