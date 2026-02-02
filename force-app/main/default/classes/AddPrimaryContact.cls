public with sharing class AddPrimaryContact implements Queueable {
    private Contact sourceContact;
    private String stateAbbr;

    public AddPrimaryContact(Contact con, String stateAbbr) {
        this.sourceContact = con;
        this.stateAbbr = stateAbbr;
    }
    public void execute(QueueableContext context) {
        // Query up to 200 Accounts matching the provided State abbreviation
        // Note: Using WITH USER_MODE to enforce FLS/sharing on read.
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE BillingState = :stateAbbr
            LIMIT 200
        ];

        if (accounts.isEmpty()) {
            return; // Nothing to do
        }

        List<Contact> contactsToInsert = new List<Contact>();
        for (Account a : accounts) {
            Contact c = (Contact) sourceContact.clone(false, false, false, false);
            c.AccountId = a.Id;
            contactsToInsert.add(c);
        }

        if (!contactsToInsert.isEmpty()) {
        
            insert contactsToInsert;
        }


    }
}