public with sharing class AccountHierarchyPdfController {
    
    /**
     * Property to access from Visualforce page
     */
    public Map<String, Object> hierarchyData { get; set; }
    
    /**
     * Constructor for Visualforce
     */
    public AccountHierarchyPdfController() {
        String accountId = ApexPages.currentPage().getParameters().get('accountId');
        if (String.isNotBlank(accountId)) {
            try {
                this.hierarchyData = getPdfHierarchyData(accountId);
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Error loading hierarchy data: ' + e.getMessage()
                ));
            }
        }
    }
    
    /**
     * Generates PDF data for the account hierarchy
     * @param accountId The ID of the root account for the hierarchy
     * @return String Base64 encoded PDF data
     */
    @AuraEnabled(cacheable=false)
    public static String generateHierarchyPdf(Id accountId) {
        try {
            // Create the page reference for the Visualforce page
            PageReference pdf = Page.AccountHierarchyPdf;
            
            // Add parameters
            pdf.getParameters().put('accountId', accountId);
            
            // Get the PDF content
            Blob pdfBlob;
            
            // In a test context, we can't call getContent()
            if (Test.isRunningTest()) {
                pdfBlob = Blob.valueOf('Test PDF Content');
            } else {
                pdfBlob = pdf.getContent();
            }
            
            // Convert to base64 for the component to handle
            String base64Data = EncodingUtil.base64Encode(pdfBlob);
            return base64Data;
        } catch (Exception e) {
            throw new AuraHandledException('Error generating PDF: ' + e.getMessage());
        }
    }
    
    /**
     * Gets formatted account hierarchy data for the Visualforce PDF page
     * @param accountId The ID of the root account
     * @return Map<String, Object> Formatted hierarchy data for the PDF
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getPdfHierarchyData(Id accountId) {
        try {
            // Get the account name for the title
            Account currentAccount = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
            
            // Get the hierarchy data
            AccountHierarchyController.HierarchyWrapper hierarchyData = 
                AccountHierarchyController.getAccountHierarchy(accountId);
            
            // Process the data into a tree structure
            Map<Id, Map<String, Object>> accountNodes = new Map<Id, Map<String, Object>>();
            
            // Create a node for each account
            for (Account acc : hierarchyData.accounts) {
                Map<String, Object> node = new Map<String, Object>{
                    'id' => acc.Id,
                    'name' => acc.Name,
                    'insurerType' => acc.sims_Insurer_Type__c,
                    'isCurrentAccount' => (acc.Id == accountId),
                    'children' => new List<Map<String, Object>>(),
                    'level' => 0,
                    'parents' => new List<Map<String, Object>>(),
                    'parentInfo' => ''
                };
                accountNodes.put(acc.Id, node);
            }
            
            // Build the relationship structure
            for (Ownership__c ownership : hierarchyData.ownerships) {
                // Skip if either parent or subsidiary doesn't exist in our data
                if (!accountNodes.containsKey(ownership.Parent__c) || 
                    !accountNodes.containsKey(ownership.Subsidiary__c)) {
                    continue;
                }
                
                // Add child to parent
                Map<String, Object> parentNode = accountNodes.get(ownership.Parent__c);
                Map<String, Object> childNode = accountNodes.get(ownership.Subsidiary__c);
                
                // Create a copy of the child node for the parent's children list
                Map<String, Object> childRef = new Map<String, Object>{
                    'id' => childNode.get('id'),
                    'name' => childNode.get('name'),
                    'insurerType' => childNode.get('insurerType'),
                    'isCurrentAccount' => childNode.get('isCurrentAccount'),
                    'percentage' => ownership.Ownership_Percentage__c
                };
                
                // Add to parent's children
                List<Map<String, Object>> children = (List<Map<String, Object>>)parentNode.get('children');
                children.add(childRef);
                parentNode.put('children', children);
                
                // Add parent reference to child
                Map<String, Object> parentRef = new Map<String, Object>{
                    'id' => parentNode.get('id'),
                    'name' => parentNode.get('name'),
                    'percentage' => ownership.Ownership_Percentage__c
                };
                
                List<Map<String, Object>> parents = (List<Map<String, Object>>)childNode.get('parents');
                parents.add(parentRef);
                childNode.put('parents', parents);
                
                // Update parent info string for the child
                String existingParentInfo = (String)childNode.get('parentInfo');
                String parentInfo = parentNode.get('name') + ' (' + ownership.Ownership_Percentage__c + '%)';
                
                if (String.isNotBlank(existingParentInfo)) {
                    parentInfo = existingParentInfo + ', ' + parentInfo;
                }
                
                childNode.put('parentInfo', parentInfo);
            }
            
            // Find root nodes (accounts with no parents)
            List<Map<String, Object>> rootNodes = new List<Map<String, Object>>();
            for (Map<String, Object> node : accountNodes.values()) {
                List<Map<String, Object>> parents = (List<Map<String, Object>>)node.get('parents');
                if (parents.isEmpty()) {
                    rootNodes.add(node);
                }
            }
            
            // Calculate levels (distance from root)
            calculateLevels(rootNodes, 0);
            
            // Create a flattened structure for the visualforce page to avoid recursion
            List<Map<String, Object>> flattenedHierarchy = new List<Map<String, Object>>();
            flattenHierarchy(rootNodes, flattenedHierarchy, accountNodes);
            
            // Get the complete hierarchy for the specific account
            Map<String, Object> accountHierarchy = accountNodes.get(accountId);
            
            // Create the result
            Map<String, Object> result = new Map<String, Object>{
                'accountName' => currentAccount.Name,
                'generationDate' => System.now(),
                'hierarchy' => accountHierarchy,
                'allNodes' => accountNodes,
                'rootNodes' => rootNodes,
                'flattenedHierarchy' => flattenedHierarchy
            };
            
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error preparing PDF data: ' + e.getMessage());
        }
    }
    
    /**
     * Recursively calculates the level of each node in the hierarchy
     * @param nodes List of nodes to process
     * @param level The current level
     */
    private static void calculateLevels(List<Map<String, Object>> nodes, Integer level) {
        if (nodes == null || nodes.isEmpty()) {
            return;
        }
        
        for (Map<String, Object> node : nodes) {
            node.put('level', level);
            List<Map<String, Object>> children = (List<Map<String, Object>>)node.get('children');
            calculateLevels(children, level + 1);
        }
    }
    
    /**
     * Creates a flattened list of nodes to avoid recursive Visualforce references
     * @param nodes The current nodes to process
     * @param flattenedList The output flattened list
     * @param nodeMap Map of all account nodes by ID
     */
    private static void flattenHierarchy(List<Map<String, Object>> nodes, 
                                         List<Map<String, Object>> flattenedList,
                                         Map<Id, Map<String, Object>> nodeMap) {
        if (nodes == null || nodes.isEmpty()) {
            return;
        }
        
        // Sort nodes by name (basic alphabetical sort)
        List<Map<String, Object>> sortedNodes = new List<Map<String, Object>>(nodes);
        sortedNodes.sort(new NodeSorter());
        
        for (Map<String, Object> node : sortedNodes) {
            // Add the current node to the flattened list
            flattenedList.add(node);
            
            // Process children
            List<Map<String, Object>> childRefs = (List<Map<String, Object>>)node.get('children');
            List<Map<String, Object>> childNodes = new List<Map<String, Object>>();
            
            // Get the full node objects for each child reference
            for (Map<String, Object> childRef : childRefs) {
                Id childId = (Id)childRef.get('id');
                if (nodeMap.containsKey(childId)) {
                    childNodes.add(nodeMap.get(childId));
                }
            }
            
            // Recursively process children
            flattenHierarchy(childNodes, flattenedList, nodeMap);
        }
    }
    
    /**
     * Inner class to sort nodes by name
     */
    private class NodeSorter implements Comparator<Map<String, Object>> {
        public Integer compare(Map<String, Object> node1, Map<String, Object> node2) {
            String name1 = (String)node1.get('name');
            String name2 = (String)node2.get('name');
            return name1.compareTo(name2);
        }
    }
}