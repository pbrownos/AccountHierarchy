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
            // Process the hierarchy using the global processed approach
            this.hierarchyData = this.processHierarchyData(data);
            // Initially expand all rows
            this.expandedRows = new Set(this.hierarchyData.map(acc => acc.id));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.hierarchyData = [];
        }
        this.isLoading = false;
    }

    processHierarchyData(rawData) {
        const accountMap = new Map();

        // Initialize the account map with each account
        rawData.accounts.forEach(acc => {
            accountMap.set(acc.Id, {
                id: acc.Id,
                name: acc.Name,
                level: 0,
                parents: [],
                children: [],
                hasChildren: false
            });
        });

        // Build parent–child relationships using ownership records
        rawData.ownerships.forEach(own => {
            const parentId = own.Parent__c;
            const subsidiaryId = own.Subsidiary__c;
            const percentage = own.Ownership_Percentage__c;

            if (accountMap.has(parentId) && accountMap.has(subsidiaryId)) {
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

        // Identify top-level accounts (those with no parents)
        const topLevelAccounts = Array.from(accountMap.values())
            .filter(acc => acc.parents.length === 0)
            .map(acc => acc.id);

        // Calculate levels and set indentation style.
        const calculateLevels = (accountId, level, visited = new Set()) => {
            if (visited.has(accountId)) return;
            visited.add(accountId);
            const account = accountMap.get(accountId);
            account.level = level;
            account.indentStyle = `padding-left: ${level * 4}rem`;
            account.children.forEach(child => {
                calculateLevels(child.accountId, level + 1, visited);
            });
        };
        topLevelAccounts.forEach(id => calculateLevels(id, 0));

        // Flatten the hierarchy into an array while using a global processed set to avoid duplicates.
        const result = [];
        const processed = new Set();

        const addToResult = (accountId) => {
            if (processed.has(accountId)) return;
            processed.add(accountId);
            const account = accountMap.get(accountId);
            // Build parent's array (with isLast flag for formatting)
            const parents = account.parents.map((p, idx) => ({
                name: accountMap.get(p.accountId).name,
                percentage: p.percentage,
                isLast: idx === account.parents.length - 1
            }));

            result.push({
                id: account.id,
                name: account.name,
                level: account.level,
                indentStyle: account.indentStyle,
                hasChildren: account.hasChildren,
                parents: parents,
                children: account.children.map(c => c.accountId),
                itemClass: `hierarchy-item ${account.id === this.recordId ? 'current-account' : ''}`
            });

            // Sort children alphabetically by account name and process them
            const sortedChildren = [...account.children].sort((a, b) => {
                const nameA = accountMap.get(a.accountId).name;
                const nameB = accountMap.get(b.accountId).name;
                return nameA.localeCompare(nameB);
            });
            sortedChildren.forEach(child => addToResult(child.accountId));
        };

        // Start from the top-level accounts (sorted alphabetically)
        topLevelAccounts
            .sort((a, b) => accountMap.get(a).name.localeCompare(accountMap.get(b).name))
            .forEach(id => addToResult(id));

        return result;
    }

    handleToggle(event) {
        event.preventDefault();
        event.stopPropagation();
        const accountId = event.currentTarget.dataset.id;
        if (this.expandedRows.has(accountId)) {
            this.expandedRows.delete(accountId);
        } else {
            this.expandedRows.add(accountId);
        }
        // Force refresh of the hierarchy data so that visibleAccounts getter recalculates.
        this.hierarchyData = [...this.hierarchyData];
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

    handleExpandAll() {
        // Expand every account by adding all IDs to expandedRows
        this.expandedRows = new Set(this.hierarchyData.map(acc => acc.id));
        this.hierarchyData = [...this.hierarchyData];
    }

    handleCollapseAll() {
        // Collapse all accounts
        this.expandedRows.clear();
        this.hierarchyData = [...this.hierarchyData];
    }

    get hasError() {
        return this.error != null;
    }

    get hasData() {
        return this.hierarchyData && this.hierarchyData.length > 0;
    }

    get hasRelatedAccounts() {
        if (!this.hierarchyData) return false;
        return this.hierarchyData.some(acc => acc.parents.length > 0 || acc.children.length > 0);
    }

    // Compute visible accounts from the flattened hierarchy based on the expandedRows state.
    // This version uses a global processed set so that each account appears only once.
    get visibleAccounts() {
        if (!this.hierarchyData?.length) return [];
        const result = [];
        const processed = new Set();

        const addAccountAndChildren = (account) => {
            if (processed.has(account.id)) return;
            processed.add(account.id);
            const acc = { ...account };
            acc.toggleIconClass = this.expandedRows.has(acc.id)
                ? 'toggle-icon expanded'
                : 'toggle-icon';
            result.push(acc);

            if (this.expandedRows.has(acc.id) && acc.hasChildren) {
                const children = this.hierarchyData
                    .filter(a => acc.children.includes(a.id))
                    .sort((a, b) => a.name.localeCompare(b.name));
                children.forEach(child => addAccountAndChildren(child));
            }
        };

        const topLevelAccounts = this.hierarchyData
            .filter(acc => acc.level === 0)
            .sort((a, b) => a.name.localeCompare(b.name));
        topLevelAccounts.forEach(acc => addAccountAndChildren(acc));

        return result;
    }
}
