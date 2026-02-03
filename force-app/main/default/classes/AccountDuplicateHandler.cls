/**
 * @description Handler class to find duplicate accounts
 * 
 * INTERVIEW QUESTION 1:
 * Create a method that finds duplicate accounts based on exact name match
 * where an account exists with the same name under the same parent account.
 * 
 * Requirements:
 * - Method should accept a Set<Id> of Account Ids
 * - Return a Map<Id, List<Account>> where the key is the Account Id 
 *   and the value is a list of duplicate accounts found
 * - Only consider accounts as duplicates if:
 *   1. They have the exact same Name (case-sensitive)
 *   2. They have the same ParentId
 *   3. They are different accounts (different Ids)
 * - Handle null ParentIds appropriately (accounts with null parent can be duplicates of each other)
 */
public with sharing class AccountDuplicateHandler {
    
    /**
     * @description Finds duplicate accounts based on name and parent
     * @param accountIds Set of Account Ids to check for duplicates
     * @return Map<Id, List<Account>> Map of Account Id to list of its duplicates
     */
    public static Map<Id, List<Account>> findDuplicates(Set<Id> accountIds) {
        Map<Id, List<Account>> results = new Map<Id,List<Account>>();

        if (accountIds == null || accountIds.isEmpty()) {
            return results;
        }
        List<Account> accounts = [
            SELECT Id, Name, ParentId
            FROM Account
            WHERE Id IN :accountIds
        ];

        Set<String> accountNames = new Set<String>();
        Set<Id> parentIds = new Set<Id>();

        for (Account account : accounts) {
            accountNames.add(account.Name);
            if(account.ParentId != null) {
                parentIds.add(account.ParentId);
            }
        }
        List<Account> duplicateAccounts = [
            SELECT Id, Name, ParentId FROM Account WHERE Name IN :accountNames AND ParentId IN :parentIds AND Id NOT IN :accountIds
        ];
        
        for(Account acc : accounts){
            List<Account> duplicates = new List<Account>();
            for(Account duplicate : duplicateAccounts){
                if(acc.Name == duplicate.Name && acc.ParentId == duplicate.ParentId){
                    duplicates.add(duplicate);
                }
            }
            results.put(acc.Id, duplicates);
        }
        // TODO: Implement this method
        // Hint: You'll need to:
        // 1. Query the accounts with the provided Ids to get their Name and ParentId
        // 2. Query all accounts that match those Name/ParentId combinations
        // 3. Build and return the result map
        
        return results;
    }
}
