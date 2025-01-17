import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAccountHierarchy from '@salesforce/apex/AccountHierarchyController.getAccountHierarchy';

export default class AccountHierarchy extends NavigationMixin(LightningElement) {
    @api recordId;
    @track hierarchyData = [];
    @track error;
    @track isLoading = true;
    @track expandedRows = new Set();

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
                hasChildren: false,
                isVisible: true
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

        // Get all connected accounts (ancestors and descendants)
        const allConnectedAccounts = new Set();
        
        // Helper to get all ancestors recursively
        const getAllAncestors = (accountId, visited = new Set()) => {
            if (visited.has(accountId)) return;
            visited.add(accountId);
            
            const account = accountMap.get(accountId);
            if (!account) return;
            
            allConnectedAccounts.add(accountId);
            
            account.parents.forEach(parent => {
                allConnectedAccounts.add(parent.accountId);
                getAllAncestors(parent.accountId, visited);
            });
        };

        // Helper to get all descendants recursively
        const getAllDescendants = (accountId, visited = new Set()) => {
            if (visited.has(accountId)) return;
            visited.add(accountId);
            
            const account = accountMap.get(accountId);
            if (!account) return;
            
            allConnectedAccounts.add(accountId);
            
            account.children.forEach(child => {
                allConnectedAccounts.add(child.accountId);
                getAllDescendants(child.accountId, visited);
            });
        };

        // Start from current account and get all connected accounts
        getAllAncestors(this.recordId);
        getAllDescendants(this.recordId);

        // Find highest level parents
        const topLevelAccounts = Array.from(allConnectedAccounts)
            .filter(id => {
                const account = accountMap.get(id);
                return account.parents.length === 0 || 
                       !account.parents.some(p => allConnectedAccounts.has(p.accountId));
            });

        // Calculate levels starting from top
        const calculateLevels = (accountId, level, visited = new Set()) => {
            if (visited.has(accountId)) return;
            visited.add(accountId);
            
            const account = accountMap.get(accountId);
            if (!account) return;
            
            account.level = level;
            account.indentStyle = `margin-left: ${level * 2}rem`;
            
            account.children
                .filter(child => allConnectedAccounts.has(child.accountId))
                .forEach(child => {
                    calculateLevels(child.accountId, level + 1, visited);
                });
        };

        topLevelAccounts.forEach(id => calculateLevels(id, 0));

        // Convert to flat array
        const result = [];
        const processed = new Set();

        const addToResult = (accountId, visited = new Set()) => {
            if (visited.has(accountId) || processed.has(accountId)) return;
            visited.add(accountId);
            
            const account = accountMap.get(accountId);
            if (!account || !allConnectedAccounts.has(accountId)) return;
            
            processed.add(accountId);
            result.push({
                id: account.id,
                name: account.name,
                level: account.level,
                indentStyle: account.indentStyle,
                hasChildren: account.hasChildren,
                parents: account.parents
                    .filter(p => allConnectedAccounts.has(p.accountId))
                    .map(p => ({
                        name: accountMap.get(p.accountId).name,
                        percentage: p.percentage
                    })),
                children: account.children
                    .filter(c => allConnectedAccounts.has(c.accountId))
                    .map(c => c.accountId)
            });

            const sortedChildren = account.children
                .filter(c => allConnectedAccounts.has(c.accountId))
                .sort((a, b) => {
                    const nameA = accountMap.get(a.accountId)?.name || '';
                    const nameB = accountMap.get(b.accountId)?.name || '';
                    return nameA.localeCompare(nameB);
                });

            sortedChildren.forEach(child => {
                addToResult(child.accountId, new Set(visited));
            });
        };

        topLevelAccounts
            .sort((a, b) => accountMap.get(a).name.localeCompare(accountMap.get(b).name))
            .forEach(id => addToResult(id, new Set()));

        return result;
    }
    }

    handleToggle(event) {
        event.stopPropagation();
        const accountId = event.currentTarget.dataset.id;
        
        if (this.expandedRows.has(accountId)) {
            this.expandedRows.delete(accountId);
        } else {
            this.expandedRows.add(accountId);
        }
        
        // Force refresh
        this.hierarchyData = [...this.hierarchyData];
    }

    get getToggleIconClass() {
        return this.expandedRows.has(this.recordId) ? 'toggle-icon expanded' : 'toggle-icon';
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

    get hasError() {
        return this.error != null;
    }

    get hasData() {
        return this.hierarchyData && this.hierarchyData.length > 0;
    }

    get visibleAccounts() {
        return this.hierarchyData;
    }
}