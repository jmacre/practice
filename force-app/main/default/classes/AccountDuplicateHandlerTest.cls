/**
 * @description Test class for AccountDuplicateHandler
 * This test class validates the candidate's implementation
 */
@isTest
private class AccountDuplicateHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create parent account
        Account parentAccount = new Account(Name = 'Parent Corp');
        insert parentAccount;
        
        // Create accounts with duplicates under same parent
        List<Account> accounts = new List<Account>();
        
        // First set of duplicates under parent
        accounts.add(new Account(Name = 'Acme Inc', ParentId = parentAccount.Id));
        accounts.add(new Account(Name = 'Acme Inc', ParentId = parentAccount.Id));
        accounts.add(new Account(Name = 'Acme Inc', ParentId = parentAccount.Id));
        
        // Second set of duplicates under parent (different name)
        accounts.add(new Account(Name = 'Tech Solutions', ParentId = parentAccount.Id));
        accounts.add(new Account(Name = 'Tech Solutions', ParentId = parentAccount.Id));
        
        // Accounts with same name but NO parent (should be duplicates of each other)
        accounts.add(new Account(Name = 'Independent Co'));
        accounts.add(new Account(Name = 'Independent Co'));
        
        // Unique account under parent (no duplicates)
        accounts.add(new Account(Name = 'Unique Corp', ParentId = parentAccount.Id));
        
        // Account with same name as 'Acme Inc' but different parent (NOT a duplicate)
        Account anotherParent = new Account(Name = 'Another Parent');
        insert anotherParent;
        accounts.add(new Account(Name = 'Acme Inc', ParentId = anotherParent.Id));
        
        insert accounts;
    }
    
    @isTest
    static void testFindDuplicates_WithParent() {
        // Get accounts named 'Acme Inc' with parent
        List<Account> acmeAccounts = [
            SELECT Id, Name, ParentId 
            FROM Account 
            WHERE Name = 'Acme Inc' 
            AND Parent.Name = 'Parent Corp'
            ORDER BY CreatedDate
            LIMIT 3
        ];
        
        System.assertEquals(3, acmeAccounts.size(), 'Should have 3 Acme Inc accounts with parent');
        
        // Test finding duplicates for the first Acme account
        Set<Id> accountIds = new Set<Id>{acmeAccounts[0].Id};
        
        Test.startTest();
        Map<Id, List<Account>> results = AccountDuplicateHandler.findDuplicates(accountIds);
        Test.stopTest();
        
        // Should find 2 other duplicates
        System.assert(results.containsKey(acmeAccounts[0].Id), 'Should have results for the queried account');
        System.assertEquals(2, results.get(acmeAccounts[0].Id).size(), 
            'Should find 2 duplicate accounts with same name and parent');
        
        // Verify the duplicates don't include the original account
        List<Account> duplicates = results.get(acmeAccounts[0].Id);
        for (Account dup : duplicates) {
            System.assertNotEquals(acmeAccounts[0].Id, dup.Id, 
                'Duplicate list should not include the original account');
            System.assertEquals('Acme Inc', dup.Name, 'Duplicate should have same name');
            System.assertEquals(acmeAccounts[0].ParentId, dup.ParentId, 
                'Duplicate should have same parent');
        }
    }
    
    @isTest
    static void testFindDuplicates_NoDuplicatesFound() {
        // Get unique account
        Account uniqueAccount = [
            SELECT Id, Name, ParentId 
            FROM Account 
            WHERE Name = 'Unique Corp' 
            LIMIT 1
        ];
        
        Set<Id> accountIds = new Set<Id>{uniqueAccount.Id};
        
        Test.startTest();
        Map<Id, List<Account>> results = AccountDuplicateHandler.findDuplicates(accountIds);
        Test.stopTest();
        
        // Should return entry with empty list
        System.assert(results.containsKey(uniqueAccount.Id) || results.isEmpty(), 
            'Should handle accounts with no duplicates');
        if (results.containsKey(uniqueAccount.Id)) {
            System.assertEquals(0, results.get(uniqueAccount.Id).size(), 
                'Should have empty list for account with no duplicates');
        }
    }
    
    @isTest
    static void testFindDuplicates_MultipleAccounts() {
        // Get multiple accounts with duplicates
        List<Account> acmeAccounts = [
            SELECT Id FROM Account 
            WHERE Name = 'Acme Inc' AND Parent.Name = 'Parent Corp'
            LIMIT 2
        ];
        
        List<Account> techAccounts = [
            SELECT Id FROM Account 
            WHERE Name = 'Tech Solutions'
            LIMIT 1
        ];
        
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(acmeAccounts[0].Id);
        accountIds.add(techAccounts[0].Id);
        
        Test.startTest();
        Map<Id, List<Account>> results = AccountDuplicateHandler.findDuplicates(accountIds);
        Test.stopTest();
        
        // Should have results for both accounts
        System.assertEquals(2, results.size(), 'Should have results for both queried accounts');
        System.assert(results.containsKey(acmeAccounts[0].Id), 
            'Should have results for Acme account');
        System.assert(results.containsKey(techAccounts[0].Id), 
            'Should have results for Tech Solutions account');
    }
    
    @isTest
    static void testFindDuplicates_DifferentParent() {
        // Get the Acme accounts - one with first parent, one with second parent
        List<Account> allAcmeAccounts = [
            SELECT Id, Name, ParentId 
            FROM Account 
            WHERE Name = 'Acme Inc'
            AND Parent.Name = 'Another Parent'
        ];
        
        // Find an Acme account with the second parent
        Account acmeWithDifferentParent = allAcmeAccounts[0];
        
        Set<Id> accountIds = new Set<Id>{acmeWithDifferentParent.Id};
        
        Test.startTest();
        Map<Id, List<Account>> results = AccountDuplicateHandler.findDuplicates(accountIds);
        Test.stopTest();
        
        // Should NOT find duplicates with the first parent
        if (results.containsKey(acmeWithDifferentParent.Id)) {
            List<Account> duplicates = results.get(acmeWithDifferentParent.Id);
            System.assertEquals(0, duplicates.size(), 
                'Should not find duplicates with different parent, even with same name');
        }
    }
    
    @isTest
    static void testFindDuplicates_EmptySet() {
        Set<Id> accountIds = new Set<Id>();
        
        Test.startTest();
        Map<Id, List<Account>> results = AccountDuplicateHandler.findDuplicates(accountIds);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Should return a map, not null');
        System.assertEquals(0, results.size(), 'Should return empty map for empty input');
    }
}
