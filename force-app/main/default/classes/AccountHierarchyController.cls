public with sharing class AccountHierarchyController {
    @AuraEnabled(cacheable=true)
    public static HierarchyWrapper getAccountHierarchy(Id accountId) {
        // Get all related ownership records
        Set<Id> relatedAccountIds = new Set<Id>();
        relatedAccountIds.add(accountId);
        
        // First get direct relationships
        List<Ownership__c> ownerships = [
            SELECT Id, Parent__c, Subsidiary__c, Ownership_Percentage__c 
            FROM Ownership__c 
            WHERE Parent__c = :accountId OR Subsidiary__c = :accountId
        ];
        
        // Collect all related account IDs
        for(Ownership__c own : ownerships) {
            relatedAccountIds.add(own.Parent__c);
            relatedAccountIds.add(own.Subsidiary__c);
        }
        
        // Get all related accounts
        List<Account> accounts = [
            SELECT Id, Name
            FROM Account
            WHERE Id IN :relatedAccountIds
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