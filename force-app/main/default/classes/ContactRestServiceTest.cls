/**
 * @description Test class for ContactRestService
 * This test class validates the candidate's implementation
 */
@isTest
private class ContactRestServiceTest {
    
    @testSetup
    static void setupTestData() {
        // Create test accounts for contacts
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Test Account 1'));
        accounts.add(new Account(Name = 'Test Account 2'));
        insert accounts;
        
        // Create existing contacts that can be updated
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            AccountId = accounts[0].Id
        ));
        contacts.add(new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'jane.smith@example.com',
            AccountId = accounts[1].Id
        ));
        insert contacts;
    }
    
    @isTest
    static void testInsertNewContacts() {
        // Get account for new contacts
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        
        // Build request JSON for new contacts (no contactId field)
        String requestJson = '{"contactList": [' +
            '{"firstName": "New", "lastName": "Contact1", "emailAddress": "new1@example.com", "accountId": "' + testAccount.Id + '"},' +
            '{"firstName": "New", "lastName": "Contact2", "emailAddress": "new2@example.com", "accountId": "' + testAccount.Id + '"}' +
            ']}';
        
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(requestJson);
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        ContactRestService.ContactResponse result = ContactRestService.processContacts();
        Test.stopTest();
        
        // Verify response
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(2, result.insertedCount, 'Should have inserted 2 contacts');
        System.assertEquals(0, result.updatedCount, 'Should have updated 0 contacts');
        System.assertEquals(0, result.errors.size(), 'Should have no errors');
        
        // Verify contacts were actually inserted
        List<Contact> insertedContacts = [
            SELECT Id, FirstName, LastName, Email 
            FROM Contact 
            WHERE Email IN ('new1@example.com', 'new2@example.com')
        ];
        System.assertEquals(2, insertedContacts.size(), 'Should find 2 newly inserted contacts');
    }
    
    @isTest
    static void testUpdateExistingContacts() {
        // Get existing contacts
        List<Contact> existingContacts = [
            SELECT Id, FirstName, LastName, Email 
            FROM Contact 
            WHERE Email IN ('john.doe@example.com', 'jane.smith@example.com')
        ];
        
        System.assertEquals(2, existingContacts.size(), 'Should have 2 existing contacts');
        
        // Build request JSON for updating contacts (with contactId field)
        String requestJson = '{"contactList": [' +
            '{"contactId": "' + existingContacts[0].Id + '", "firstName": "Updated", "lastName": "Doe", "emailAddress": "john.doe.updated@example.com"},' +
            '{"contactId": "' + existingContacts[1].Id + '", "firstName": "Updated", "lastName": "Smith", "emailAddress": "jane.smith.updated@example.com"}' +
            ']}';
        
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(requestJson);
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        ContactRestService.ContactResponse result = ContactRestService.processContacts();
        Test.stopTest();
        
        // Verify response
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(0, result.insertedCount, 'Should have inserted 0 contacts');
        System.assertEquals(2, result.updatedCount, 'Should have updated 2 contacts');
        System.assertEquals(0, result.errors.size(), 'Should have no errors');
        
        // Verify contacts were actually updated
        List<Contact> updatedContacts = [
            SELECT Id, FirstName, Email 
            FROM Contact 
            WHERE Id IN :existingContacts
        ];
        
        for (Contact con : updatedContacts) {
            System.assertEquals('Updated', con.FirstName, 'FirstName should be updated');
            System.assert(con.Email.contains('updated'), 'Email should be updated');
        }
    }
    
    @isTest
    static void testMixedInsertAndUpdate() {
        // Get existing contact
        Contact existingContact = [
            SELECT Id, FirstName, LastName 
            FROM Contact 
            WHERE Email = 'john.doe@example.com' 
            LIMIT 1
        ];
        
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        
        // Build request JSON with both new and existing contacts
        String requestJson = '{"contactList": [' +
            '{"contactId": "' + existingContact.Id + '", "firstName": "UpdatedJohn", "lastName": "Doe"},' +
            '{"firstName": "Brand", "lastName": "New", "emailAddress": "brand.new@example.com", "accountId": "' + testAccount.Id + '"},' +
            '{"firstName": "Another", "lastName": "New", "emailAddress": "another.new@example.com", "accountId": "' + testAccount.Id + '"}' +
            ']}';
        
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(requestJson);
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        ContactRestService.ContactResponse result = ContactRestService.processContacts();
        Test.stopTest();
        
        // Verify response
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertEquals(2, result.insertedCount, 'Should have inserted 2 contacts');
        System.assertEquals(1, result.updatedCount, 'Should have updated 1 contact');
        System.assertEquals(0, result.errors.size(), 'Should have no errors');
        
        // Verify the update
        Contact updated = [SELECT FirstName FROM Contact WHERE Id = :existingContact.Id];
        System.assertEquals('UpdatedJohn', updated.FirstName, 'Contact should be updated');
        
        // Verify the inserts
        List<Contact> inserted = [
            SELECT Email FROM Contact 
            WHERE Email IN ('brand.new@example.com', 'another.new@example.com')
        ];
        System.assertEquals(2, inserted.size(), 'Should have 2 new contacts');
    }
    
    //@isTest
    // static void testInvalidContactId() {
    //     // Use a fake contact Id that doesn't exist
    //     String fakeId = '003000000000000AAA';
        
    //     String requestJson = '{"contactList": [' +
    //         '{"contactId": "' + fakeId + '", "firstName": "Invalid", "lastName": "Contact"}' +
    //         ']}';
        
    //     // Setup REST context
    //     RestRequest request = new RestRequest();
    //     RestResponse response = new RestResponse();
    //     request.requestBody = Blob.valueOf(requestJson);
    //     RestContext.request = request;
    //     RestContext.response = response;
        
    //     Test.startTest();
    //     ContactRestService.ContactResponse result = ContactRestService.processContacts();
    //     Test.stopTest();
        
    //     // Should have error handling
    //     System.assertEquals(false, result.success, 'Operation should fail with invalid Id');
    //     System.assert(result.errors.size() > 0, 'Should have at least one error message');
    // }
    
    @isTest
    static void testMissingRequiredFields() {
        // Contact without required lastName field
        String requestJson = '{"contactList": [' +
            '{"firstName": "NoLastName", "emailAddress": "nolast@example.com"}' +
            ']}';
        
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(requestJson);
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        ContactRestService.ContactResponse result = ContactRestService.processContacts();
        Test.stopTest();
        
        // Should have error handling
        System.assertEquals(false, result.success, 'Operation should fail with missing required fields');
        System.assert(result.errors.size() > 0, 'Should have at least one error message');
    }
    
    @isTest
    static void testBulkProcessing() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        
        // Build request with many contacts
        String contactsJson = '';
        for (Integer i = 0; i < 50; i++) {
            if (i > 0) contactsJson += ',';
            contactsJson += '{"firstName": "Bulk' + i + '", "lastName": "Contact' + i + 
                '", "emailAddress": "bulk' + i + '@example.com", "accountId": "' + testAccount.Id + '"}';
        }
        
        String requestJson = '{"contactList": [' + contactsJson + ']}';
        
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(requestJson);
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        ContactRestService.ContactResponse result = ContactRestService.processContacts();
        Test.stopTest();
        
        // Verify bulk processing
        System.assertEquals(true, result.success, 'Bulk operation should be successful');
        System.assertEquals(50, result.insertedCount, 'Should have inserted 50 contacts');
        
        // Verify contacts were inserted
        Integer actualCount = [SELECT COUNT() FROM Contact WHERE Email LIKE 'bulk%@example.com'];
        System.assertEquals(50, actualCount, 'Should find 50 bulk contacts in database');
    }
}
