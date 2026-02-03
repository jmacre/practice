/**
 * @description REST API Service for processing Contact records
 * 
 * INTERVIEW QUESTION 2:
 * Create a REST service that processes incoming JSON containing a list of contacts.
 * If the contact has an Id, update it. If not, insert it as a new contact.
 * 
 * Requirements:
 * - Endpoint should be accessible at: /services/apexrest/contacts
 * - Accept POST requests with JSON body containing a list of contacts
 * - JSON structure uses custom field names (not Salesforce field names):
 *   {
 *     "contactList": [
 *       {"contactId": "003...", "firstName": "John", "lastName": "Doe", "emailAddress": "john@example.com", "accountId": "001..."},
 *       {"firstName": "Jane", "lastName": "Smith", "emailAddress": "jane@example.com"}
 *     ]
 *   }
 * - Parse the JSON and map fields to Contact object:
 *   - contactId -> Contact.Id
 *   - firstName -> Contact.FirstName
 *   - lastName -> Contact.LastName
 *   - emailAddress -> Contact.Email
 *   - accountId -> Contact.AccountId
 * - If a contact has a contactId field, update that contact
 * - If a contact does not have a contactId field, insert it as a new contact
 * - Return a response with:
 *   - success: boolean indicating overall success
 *   - insertedCount: number of contacts inserted
 *   - updatedCount: number of contacts updated
 *   - errors: list of any errors encountered
 * - Use proper error handling and DML operations
 */
@RestResource(urlMapping='/contacts')
global with sharing class ContactRestService {
    
    /**
     * @description Wrapper class for the response
     */
    global class ContactResponse {
        public Boolean success;
        public Integer insertedCount;
        public Integer updatedCount;
        public List<String> errors;
        
        public ContactResponse() {
            this.success = true;
            this.insertedCount = 0;
            this.updatedCount = 0;
            this.errors = new List<String>();
        }
    }
    
    /**
     * @description POST method to process incoming contacts
     * @return ContactResponse with processing results
     */
    // TODO: Implement this method
    // Hint: You'll need to:
    // 1. Get the request body using RestContext.request.requestBody
    // 2. Parse the JSON string (cannot directly deserialize to Contact objects)
    // 3. Extract the contactList array from the JSON
    // 4. Loop through each contact in the JSON and manually map fields:
    //    - contactId -> Contact.Id
    //    - firstName -> Contact.FirstName
    //    - lastName -> Contact.LastName
    //    - emailAddress -> Contact.Email
    //    - accountId -> Contact.AccountId
    // 5. Separate contacts with contactId (update) from those without (insert)
    // 6. Perform DML operations using Database.insert/update with allOrNone=false
    // 7. Handle any errors from DML results
    // 8. Build and return the response
    // Example JSON structure:
    // {
    //     "contactList": [
    //     {
    //         "contactId": "003...",
    //         "firstName": "John",
    //         "lastName": "Doe",
    //         "emailAddress": "john@example.com",
    //         "accountId": "001..."
    //     },
    //     {
    //         "firstName": "Jane",
    //         "lastName": "Smith",
    //         "emailAddress": "jane@example.com"
    //     }
    //     ]
    // }
    @HttpPost
    global static ContactResponse processContacts() {
        ContactResponse response = new ContactResponse();
        String reqBody = RestContext.request.requestBody.toString();
        Map<String, Object> reqMap = (Map<String, Object>)JSON.deserializeUntyped(reqBody);
        List<Object> contactsList = (List<Object>)reqMap.get('contactList');

        List<Contact> contactsToUpsert = new List<Contact>();

        for(Object contactObj : contactsList) {
            Map<String, Object> contactMap = (Map<String, Object>)contactObj;
            Contact contact = new Contact();

            if(contactMap.containsKey('contactId') && contactMap.get('contactId') != null){
                contact.Id = (String)contactMap.get('contactId');
            }
            
            if(contactMap.containsKey('firstName') && contactMap.get('firstName') != null){
                contact.FirstName = (String)contactMap.get('firstName');
            }

            if(contactMap.containsKey('lastName') && contactMap.get('lastName') != null) {
                contact.LastName = (String)contactMap.get('lastName');
            }
            if(contactMap.containsKey('emailAddress') && contactMap.get('emailAddress') != null) {
                contact.Email = (String)contactMap.get('emailAddress');
            }
            if(contactMap.containsKey('accountId') && contactMap.get('accountId') != null) {
                contact.AccountId = (String)contactMap.get('accountId');
            }

            contactsToUpsert.add(contact);

        }
        if(!contactsToUpsert.isEmpty()){
            Database.UpsertResult[] saveResults = Database.upsert(contactsToUpsert, false);
            for(Database.UpsertResult saveResult : saveResults){
                if(saveResult.isSuccess() && saveResult.isCreated()){
                    response.insertedCount++;
                } else if(saveResult.isSuccess()){
                    response.updatedCount++;
                } else {
                    response.errors.add(saveResult.getErrors()[0].getMessage());
                    response.success = false;
                }
            }
        }
        return response;
    }
}
