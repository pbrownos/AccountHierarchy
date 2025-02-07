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
            // Build the flattened hierarchy array
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
        
        // Initialize accountMap with all accounts.
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

        // Build relationships based on ownership records.
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

        // Identify top-level accounts (those with no parents).
        const topLevelAccountIds = Array.from(accountMap.values())
            .filter(acc => acc.parents.length === 0)
            .map(acc => acc.id);

        // Calculate levels recursively (using a per‑branch path to avoid cycles).
        const calculateLevels = (accountId, level, path = new Set()) => {
            if (path.has(accountId)) return;
            const newPath = new Set(path);
            newPath.add(accountId);
            const account = accountMap.get(accountId);
            account.level = level;
            account.indentStyle = `padding-left: ${level * 4}rem`;
            account.children.forEach(child => {
                calculateLevels(child.accountId, level + 1, newPath);
            });
        };

        topLevelAccountIds.forEach(id => calculateLevels(id, 0));

        // Flatten the hierarchical data into an array.
        // (We remove the global “processed” set so that an account reached via one branch
        // doesn’t block its appearance when reached via another branch.)
        const result = [];
        const addToResult = (accountId, path = new Set()) => {
            if (path.has(accountId)) return; // prevent cycles within the same branch
            const newPath = new Set(path);
            newPath.add(accountId);

            const account = accountMap.get(accountId);
            // Build a parents array with an isLast flag.
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

            // Recurse into children in alphabetical order.
            const sortedChildren = [...account.children].sort((a, b) => {
                const nameA = accountMap.get(a.accountId).name;
                const nameB = accountMap.get(b.accountId).name;
                return nameA.localeCompare(nameB);
            });
            sortedChildren.forEach(child => addToResult(child.accountId, newPath));
        };

        // Start with top-level accounts sorted alphabetically.
        topLevelAccountIds
            .sort((a, b) => accountMap.get(a).name.localeCompare(accountMap.get(b).name))
            .forEach(id => addToResult(id, new Set()));

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
        // Force refresh of visible accounts.
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
        // Expand every account.
        this.expandedRows = new Set(this.hierarchyData.map(acc => acc.id));
        this.hierarchyData = [...this.hierarchyData];
    }

    handleCollapseAll() {
        // Collapse all accounts.
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

    // Compute the visible accounts based on the expandedRows state.
    // We traverse from top-level accounts, using a per‑branch path to avoid cycles.
    get visibleAccounts() {
        if (!this.hierarchyData?.length) return [];
        const result = [];
        const addAccountAndChildren = (account, path = new Set()) => {
            if (path.has(account.id)) return;
            const newPath = new Set(path);
            newPath.add(account.id);

            const acc = { ...account };
            acc.toggleIconClass = this.expandedRows.has(acc.id)
                ? 'toggle-icon expanded'
                : 'toggle-icon';
            result.push(acc);

            if (this.expandedRows.has(acc.id) && acc.hasChildren) {
                const children = this.hierarchyData
                    .filter(a => acc.children.includes(a.id))
                    .sort((a, b) => a.name.localeCompare(b.name));
                children.forEach(child => addAccountAndChildren(child, newPath));
            }
        };

        const topLevelAccounts = this.hierarchyData
            .filter(acc => acc.level === 0)
            .sort((a, b) => a.name.localeCompare(b.name));
        topLevelAccounts.forEach(acc => addAccountAndChildren(acc));
        return result;
    }
}
