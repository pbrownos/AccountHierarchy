import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAccountHierarchy from '@salesforce/apex/AccountHierarchyController.getAccountHierarchy';

export default class AccountHierarchy extends NavigationMixin(LightningElement) {
    @api recordId;
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
        const accountMap = new Map();
        
        // Initialize accountMap with all accounts
        rawData.accounts.forEach(acc => {
            accountMap.set(acc.Id, {
                id: acc.Id,
                name: acc.Name,
                level: 0,
                parents: [],
                children: [],
                isExpanded: true, // Start expanded
                hasChildren: false,
                isVisible: true   // Start visible
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
                accountMap.get(parentId).hasChildren = true;
            }
        });

        // Find all accounts connected to the current record
        const currentAccount = accountMap.get(this.recordId);
        const connectedAccounts = new Set();
        
        // Traverse up to find all ancestors
        const findAncestors = (account) => {
            if (!account || connectedAccounts.has(account.id)) return;
            connectedAccounts.add(account.id);
            
            account.parents.forEach(parent => {
                const parentAccount = accountMap.get(parent.accountId);
                findAncestors(parentAccount);
            });
        };

        // Traverse down to find all descendants
        const findDescendants = (account) => {
            if (!account || connectedAccounts.has(account.id)) return;
            connectedAccounts.add(account.id);
            
            account.children.forEach(child => {
                const childAccount = accountMap.get(child.accountId);
                findDescendants(childAccount);
            });
        };

        // Find all connected accounts
        if (currentAccount) {
            findAncestors(currentAccount);
            findDescendants(currentAccount);
        }

        // Find top-level accounts among connected accounts
        const topLevelAccounts = Array.from(connectedAccounts)
            .map(id => accountMap.get(id))
            .filter(acc => acc.parents.length === 0 || !acc.parents.every(p => connectedAccounts.has(p.accountId)));

        // Calculate levels starting from top
        const calculateLevels = (account, level, visited = new Set()) => {
            if (visited.has(account.id)) return;
            visited.add(account.id);
            
            account.level = Math.max(account.level, level);
            account.indentStyle = `margin-left: ${level * 2}rem`;
            
            account.children.forEach(child => {
                const childAccount = accountMap.get(child.accountId);
                calculateLevels(childAccount, level + 1, visited);
            });
        };

        topLevelAccounts.forEach(acc => calculateLevels(acc, 0));

        // Convert to flat array with proper formatting
        const flattenHierarchy = () => {
            const result = [];
            
            const addToResult = (accountId, visited = new Set()) => {
                if (visited.has(accountId)) return;
                visited.add(accountId);
                
                const account = accountMap.get(accountId);
                if (!connectedAccounts.has(accountId)) return;
                
                result.push({
                    id: account.id,
                    name: account.name,
                    level: account.level,
                    indentStyle: account.indentStyle,
                    hasChildren: account.hasChildren,
                    isExpanded: account.isExpanded,
                    isVisible: account.isVisible,
                    parents: account.parents
                        .filter(p => connectedAccounts.has(p.accountId))
                        .map(p => ({
                            name: accountMap.get(p.accountId).name,
                            percentage: p.percentage
                        })),
                    children: account.children
                        .filter(c => connectedAccounts.has(c.accountId))
                        .map(c => c.accountId)
                });
                
                const sortedChildren = [...account.children]
                    .filter(c => connectedAccounts.has(c.accountId))
                    .sort((a, b) => accountMap.get(a.accountId).name
                        .localeCompare(accountMap.get(b.accountId).name));
                    
                sortedChildren.forEach(child => {
                    addToResult(child.accountId, visited);
                });
            };
            
            const sortedTopLevel = topLevelAccounts
                .sort((a, b) => a.name.localeCompare(b.name));
            
            sortedTopLevel.forEach(acc => addToResult(acc.id));
            
            return result;
        };

        return flattenHierarchy();
    }

    handleToggle(event) {
        const accountId = event.currentTarget.dataset.id;
        const account = this.hierarchyData.find(acc => acc.id === accountId);
        if (account) {
            account.isExpanded = !account.isExpanded;
            // Force refresh
            this.hierarchyData = [...this.hierarchyData];
        }
    }

    get hasError() {
        return this.error != null;
    }

    get hasData() {
        return this.hierarchyData && this.hierarchyData.length > 0;
    }

    get visibleAccounts() {
        return this.hierarchyData.filter(acc => acc.isVisible);
    }

    navigateToAccount(event) {
        event.preventDefault();
        const accountId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
}