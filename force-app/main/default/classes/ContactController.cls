public with sharing class ContactController {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(){
        // Include Id because lightning-datatable key-field requires it
        return [SELECT FirstName, LastName, Email FROM Contact LIMIT 10];
    }
}
