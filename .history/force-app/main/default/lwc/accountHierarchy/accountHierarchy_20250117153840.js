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
                isExpanded: false,
                hasChildren: false
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

        // Find top-level accounts
        const topLevelAccounts = Array.from(accountMap.values())
            .filter(acc => acc.parents.length === 0);

        // Calculate levels and build tree structure
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
                
                result.push({
                    id: account.id,
                    name: account.name,
                    level: account.level,
                    indentStyle: account.indentStyle,
                    hasChildren: account.hasChildren,
                    isExpanded: account.isExpanded,
                    isVisible: account.level === 0, // Only top-level nodes visible initially
                    parents: account.parents.map(p => ({
                        name: accountMap.get(p.accountId).name,
                        percentage: p.percentage
                    })),
                    children: account.children.map(c => c.accountId)
                });
                
                const sortedChildren = [...account.children]
                    .sort((a, b) => accountMap.get(a.accountId).name.localeCompare(accountMap.get(b.accountId).name));
                    
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
            if (account.isExpanded) {
                // Make immediate children visible
                this.hierarchyData = this.hierarchyData.map(acc => {
                    if (account.children.includes(acc.id)) {
                        return { ...acc, isVisible: true };
                    }
                    return acc;
                });
            } else {
                // Hide all descendants
                const hideDescendants = (nodeId) => {
                    const node = this.hierarchyData.find(acc => acc.id === nodeId);
                    if (node) {
                        node.isVisible = false;
                        node.children.forEach(hideDescendants);
                    }
                };
                account.children.forEach(hideDescendants);
            }
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