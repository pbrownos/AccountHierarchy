import { LightningElement, api, wire, track } from 'lwc';
import getAccountHierarchy from '@salesforce/apex/AccountHierarchyController.getAccountHierarchy';

export default class AccountHierarchy extends LightningElement {
    @api recordId; // Current account ID
    @track hierarchyData = [];
    @track error;
    @track isLoading = true;

    @wire(getAccountHierarchy, { accountId: '$recordId' })
    wiredHierarchy({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.hierarchyData = this.processHierarchyData(data);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.hierarchyData = [];
        }
        this.isLoading = false;
    }

    processHierarchyData(rawData) {
        // First, organize data into a map for easy access
        const accountMap = new Map();
        const parentRelations = new Map();
        
        // Initialize accountMap with all accounts
        rawData.accounts.forEach(acc => {
            accountMap.set(acc.Id, {
                id: acc.Id,
                name: acc.Name,
                level: 0,
                parents: [],
                children: []
            });
        });

        // Process ownership relationships
        rawData.ownerships.forEach(own => {
            const parentId = own.Parent__c;
            const subsidiaryId = own.Subsidiary__c;
            const percentage = own.Ownership_Percentage__c;

            if (accountMap.has(parentId) && accountMap.has(subsidiaryId)) {
                // Add parent-child relationship
                accountMap.get(subsidiaryId).parents.push({
                    accountId: parentId,
                    percentage: percentage
                });
                accountMap.get(parentId).children.push({
                    accountId: subsidiaryId,
                    percentage: percentage
                });

                // Track parent relations for later processing
                if (!parentRelations.has(subsidiaryId)) {
                    parentRelations.set(subsidiaryId, new Set());
                }
                parentRelations.get(subsidiaryId).add(parentId);
            }
        });

        // Find top-level accounts (those with no parents)
        const topLevelAccounts = Array.from(accountMap.values())
            .filter(acc => acc.parents.length === 0);

        // Calculate levels through recursive traversal
        const calculateLevels = (account, level, visited = new Set()) => {
            if (visited.has(account.id)) return;
            visited.add(account.id);
            
            account.level = Math.max(account.level, level);
            
            account.children.forEach(child => {
                const childAccount = accountMap.get(child.accountId);
                calculateLevels(childAccount, level + 1, visited);
            });
        };

        topLevelAccounts.forEach(acc => calculateLevels(acc, 0));

        // Convert to flat array with proper formatting
        const flattenHierarchy = () => {
            const result = [];
            
            // Helper function to add account and its children to result
            const addToResult = (accountId, visited = new Set()) => {
                if (visited.has(accountId)) return;
                visited.add(accountId);
                
                const account = accountMap.get(accountId);
                
                // Add current account
                result.push({
                    id: account.id,
                    name: account.name,
                    level: account.level,
                    parents: account.parents.map(p => ({
                        name: accountMap.get(p.accountId).name,
                        percentage: p.percentage
                    }))
                });
                
                // Add children (sorted by name)
                const sortedChildren = [...account.children]
                    .sort((a, b) => accountMap.get(a.accountId).name.localeCompare(accountMap.get(b.accountId).name));
                    
                sortedChildren.forEach(child => {
                    addToResult(child.accountId, visited);
                });
            };
            
            // Start with top-level accounts, sorted by name
            const sortedTopLevel = topLevelAccounts
                .sort((a, b) => a.name.localeCompare(b.name));
            
            sortedTopLevel.forEach(acc => addToResult(acc.id));
            
            return result;
        };

        return flattenHierarchy();
    }

    get hasError() {
        return this.error != null;
    }

    get hasData() {
        return this.hierarchyData && this.hierarchyData.length > 0;
    }
}