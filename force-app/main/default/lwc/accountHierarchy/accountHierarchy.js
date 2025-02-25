import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAccountHierarchy from '@salesforce/apex/AccountHierarchyController.getAccountHierarchy';
import generateHierarchyPdf from '@salesforce/apex/AccountHierarchyPdfController.generateHierarchyPdf';
import { refreshApex } from '@salesforce/apex';

export default class AccountHierarchy extends NavigationMixin(LightningElement) {
    @api recordId;
    @track hierarchyData = [];
    @track error;
    @track isLoading = true;
    @track expandedRows = new Set();
    @track isExporting = false;
    @track exportError = null;

    // Store the wired result for refreshApex.
    wiredResult;

    @wire(getAccountHierarchy, { accountId: '$recordId' })
    wiredHierarchy(result) {
        this.wiredResult = result;
        this.isLoading = true;
        if (result.data) {
            this.hierarchyData = this.processHierarchyData(result.data);
            // Initially expand all rows.
            this.expandedRows = new Set(this.hierarchyData.map(acc => acc.id));
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.hierarchyData = [];
        }
        this.isLoading = false;
    }

    processHierarchyData(rawData) {
        const accountMap = new Map();
        
        // Initialize accountMap including the new insurer type field.
        rawData.accounts.forEach(acc => {
            accountMap.set(acc.Id, {
                id: acc.Id,
                name: acc.Name,
                insurerType: acc.sims_Insurer_Type__c,
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

        // Identify top-level accounts (those with no parents)
        const topLevelAccounts = Array.from(accountMap.values())
            .filter(acc => acc.parents.length === 0)
            .map(acc => acc.id);

        // Calculate levels recursively.
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

        // Flatten the hierarchy into an array while preventing duplicates.
        const result = [];
        const processed = new Set();

        const addToResult = (accountId) => {
            if (processed.has(accountId)) return;
            processed.add(accountId);
            const account = accountMap.get(accountId);
            // Build the parents array (with isLast flag for formatting)
            const parents = account.parents.map((p, idx) => ({
                name: accountMap.get(p.accountId).name,
                percentage: p.percentage,
                isLast: idx === account.parents.length - 1
            }));

            // Determine extra CSS class based on insurer type.
            let extraClass = '';
            if(account.insurerType === 'Certified') {
                extraClass = ' certified';
            } else if(account.insurerType === 'Admitted Reinsurer') {
                extraClass = ' admitted';
            }

            result.push({
                id: account.id,
                name: account.name,
                insurerType: account.insurerType,
                level: account.level,
                indentStyle: account.indentStyle,
                hasChildren: account.hasChildren,
                parents: parents,
                children: account.children.map(c => c.accountId),
                itemClass: `hierarchy-item-content${account.id === this.recordId ? ' current-account' : ''}${extraClass}`
            });

            // Recurse into children in alphabetical order.
            const sortedChildren = [...account.children].sort((a, b) => {
                const nameA = accountMap.get(a.accountId).name;
                const nameB = accountMap.get(b.accountId).name;
                return nameA.localeCompare(nameB);
            });
            sortedChildren.forEach(child => addToResult(child.accountId));
        };

        // Start with the top-level accounts (sorted alphabetically).
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
        // Force refresh so the visibleAccounts getter recalculates.
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
        this.expandedRows = new Set(this.hierarchyData.map(acc => acc.id));
        this.hierarchyData = [...this.hierarchyData];
    }

    handleCollapseAll() {
        this.expandedRows.clear();
        this.hierarchyData = [...this.hierarchyData];
    }

    // New refresh button handler.
    handleRefresh() {
        refreshApex(this.wiredResult);
    }

    // PDF Export function
    handleExportPdf() {
        this.isExporting = true;
        this.exportError = null;
        
        generateHierarchyPdf({ accountId: this.recordId })
            .then(result => {
                // Create a blob from the base64 data
                const byteCharacters = atob(result);
                const byteNumbers = new Array(byteCharacters.length);
                for (let i = 0; i < byteCharacters.length; i++) {
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }
                const byteArray = new Uint8Array(byteNumbers);
                const blob = new Blob([byteArray], { type: 'application/pdf' });
                
                // Create a link and trigger download
                const downloadLink = document.createElement('a');
                downloadLink.href = URL.createObjectURL(blob);
                
                // Generate the filename with the account name and timestamp
                const accountName = this.hierarchyData.find(acc => acc.id === this.recordId)?.name || 'Account';
                const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
                downloadLink.download = `${accountName}_Hierarchy_${timestamp}.pdf`;
                
                // Append to body, click and clean up
                document.body.appendChild(downloadLink);
                downloadLink.click();
                setTimeout(() => {
                    document.body.removeChild(downloadLink);
                    URL.revokeObjectURL(downloadLink.href);
                }, 100);
                
                this.isExporting = false;
            })
            .catch(error => {
                this.exportError = error.body?.message || 'Unknown error generating PDF';
                this.isExporting = false;
                console.error('Error generating PDF', error);
            });
    }
    
    dismissExportError() {
        this.exportError = null;
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

    // Compute the visible accounts based on expandedRows.
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