public with sharing class AccountHierarchyController {
    @AuraEnabled(cacheable=true)
    public static HierarchyWrapper getAccountHierarchy(Id accountId) {
        Set<Id> allRelatedAccounts = new Set<Id>();
        allRelatedAccounts.add(accountId);
        
        // Find all connected accounts through ownership relationships
        Set<Id> accountsToProcess = new Set<Id>{accountId};
        Set<Id> processedAccounts = new Set<Id>();
        
        while (!accountsToProcess.isEmpty()) {
            Set<Id> newAccountsToProcess = new Set<Id>();
            
            // Get all ownership records where current accounts are either parent or subsidiary
            for (Ownership__c ownership : [
                SELECT Parent__c, Subsidiary__c
                FROM Ownership__c
                WHERE Parent__c IN :accountsToProcess
                   OR Subsidiary__c IN :accountsToProcess
            ]) {
                if (!processedAccounts.contains(ownership.Parent__c)) {
                    newAccountsToProcess.add(ownership.Parent__c);
                    allRelatedAccounts.add(ownership.Parent__c);
                }
                if (!processedAccounts.contains(ownership.Subsidiary__c)) {
                    newAccountsToProcess.add(ownership.Subsidiary__c);
                    allRelatedAccounts.add(ownership.Subsidiary__c);
                }
            }
            
            processedAccounts.addAll(accountsToProcess);
            accountsToProcess = newAccountsToProcess;
        }
        
        // Get all accounts in the hierarchy, including the insurer type field.
        List<Account> accounts = [
            SELECT Id, Name, sims_Insurer_Type__c
            FROM Account
            WHERE Id IN :allRelatedAccounts
            ORDER BY Name ASC
        ];
        
        // Get all ownership relationships for these accounts
        List<Ownership__c> ownerships = [
            SELECT Id, Parent__c, Subsidiary__c, Ownership_Percentage__c
            FROM Ownership__c
            WHERE Parent__c IN :allRelatedAccounts
               OR Subsidiary__c IN :allRelatedAccounts
            ORDER BY Parent__c, Subsidiary__c
        ];
        
        return new HierarchyWrapper(accounts, ownerships);
    }
    
    public class HierarchyWrapper {
        @AuraEnabled public List<Account> accounts;
        @AuraEnabled public List<Ownership__c> ownerships;
        
        public HierarchyWrapper(List<Account> accounts, List<Ownership__c> ownerships) {
            this.accounts = accounts;
            this.ownerships = ownerships;
        }
    }
}
