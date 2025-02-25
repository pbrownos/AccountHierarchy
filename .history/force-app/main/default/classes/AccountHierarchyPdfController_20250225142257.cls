public with sharing class AccountHierarchyPdfController {
    
    /**
     * Properties to access from Visualforce page
     */
    public Map<String, Object> hierarchyData { get; set; }
    public List<HierarchyNode> formattedNodes { get; set; }
    
    /**
     * Constructor for Visualforce
     */
    public AccountHierarchyPdfController() {
        this.formattedNodes = new List<HierarchyNode>();
        
        String accountId = ApexPages.currentPage().getParameters().get('accountId');
        System.debug('PDF Controller - Account ID: ' + accountId);
        
        if (String.isNotBlank(accountId)) {
            try {
                // Get the raw hierarchy data
                this.hierarchyData = getPdfHierarchyData(accountId);
                System.debug('PDF Controller - Hierarchy data loaded successfully');
                
                // Convert the raw data into a format that's easier for Visualforce to handle
                List<Map<String, Object>> flattenedHierarchy = (List<Map<String, Object>>)this.hierarchyData.get('flattenedHierarchy');
                System.debug('PDF Controller - Flattened hierarchy size: ' + (flattenedHierarchy != null ? flattenedHierarchy.size() : 0));
                
                if (flattenedHierarchy != null && !flattenedHierarchy.isEmpty()) {
                    for (Map<String, Object> node : flattenedHierarchy) {
                        // Add null checks to prevent NullPointerException
                        String name = (String)node.get('name');
                        Integer level = node.get('level') != null ? (Integer)node.get('level') : 0;
                        Boolean isCurrentAccount = node.get('isCurrentAccount') != null ? (Boolean)node.get('isCurrentAccount') : false;
                        String insurerType = (String)node.get('insurerType');
                        String parentInfo = (String)node.get('parentInfo');
                        
                        this.formattedNodes.add(new HierarchyNode(
                            name,
                            level,
                            isCurrentAccount,
                            insurerType,
                            parentInfo
                        ));
                    }
                    System.debug('PDF Controller - Added ' + this.formattedNodes.size() + ' formatted nodes');
                } else {
                    System.debug('PDF Controller - No flattened hierarchy data found');
                    // Add a default message node if no data
                    this.formattedNodes.add(new HierarchyNode(
                        'No hierarchy data available',
                        0,
                        false,
                        null,
                        null
                    ));
                }
            } catch (Exception e) {
                System.debug('PDF Controller - Error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Error loading hierarchy data: ' + e.getMessage()
                ));
                
                // Add an error node
                this.formattedNodes.add(new HierarchyNode(
                    'Error loading hierarchy: ' + e.getMessage(),
                    0,
                    false,
                    null,
                    null
                ));
            }
        } else {
            System.debug('PDF Controller - No account ID provided');
            // Add a message for missing account ID
            this.formattedNodes.add(new HierarchyNode(
                'No account ID provided',
                0,
                false,
                null,
                null
            ));
        }
    }
    
    /**
     * Public inner class to represent a node in the hierarchy for Visualforce binding
     */
    public class HierarchyNode {
        public String name { get; set; }
        public Integer level { get; set; }
        public Boolean isCurrentAccount { get; set; }
        public String insurerType { get; set; }
        public String parentInfo { get; set; }
        public String cssClass { get; set; }
        public String indentStyle { get; set; }
        
        public HierarchyNode(String name, Integer level, Boolean isCurrentAccount, String insurerType, String parentInfo) {
            this.name = name != null ? name : 'Unknown';
            this.level = level;
            this.isCurrentAccount = isCurrentAccount;
            this.insurerType = insurerType;
            this.parentInfo = parentInfo;
            
            // Calculate the CSS class based on type and current status
            this.cssClass = '';
            if (isCurrentAccount) {
                this.cssClass += 'current ';
            }
            if (insurerType == 'Certified') {
                this.cssClass += 'certified ';
            } else if (insurerType == 'Admitted Reinsurer') {
                this.cssClass += 'admitted ';
            }
            this.cssClass = this.cssClass.trim();
            
            // Ensure level is within acceptable range (0-5)
            if (this.level < 0) this.level = 0;
            if (this.level > 5) this.level = 5;
            
            // Calculate the indent style - used as a fallback
            this.indentStyle = 'margin-left: ' + (level * 20) + 'px;';
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
            System.debug('Generate Hierarchy PDF - Starting for account: ' + accountId);
            
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
            System.debug('Generate Hierarchy PDF - Completed successfully');
            return base64Data;
        } catch (Exception e) {
            System.debug('Generate Hierarchy PDF - Error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
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
            System.debug('Get PDF Hierarchy Data - Starting for account: ' + accountId);
            
            // Get the account name for the title
            Account currentAccount = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
            
            // Get the hierarchy data
            AccountHierarchyController.HierarchyWrapper hierarchyData = 
                AccountHierarchyController.getAccountHierarchy(accountId);
            
            if (hierarchyData.accounts == null || hierarchyData.accounts.isEmpty()) {
                System.debug('Get PDF Hierarchy Data - No accounts found in hierarchy data');
                return new Map<String, Object>{
                    'accountName' => currentAccount.Name,
                    'generationDate' => System.now(),
                    'flattenedHierarchy' => new List<Map<String, Object>>()
                };
            }
            
            System.debug('Get PDF Hierarchy Data - Processing ' + hierarchyData.accounts.size() + ' accounts');
            
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
            if (hierarchyData.ownerships != null && !hierarchyData.ownerships.isEmpty()) {
                System.debug('Get PDF Hierarchy Data - Processing ' + hierarchyData.ownerships.size() + ' ownership relationships');
                
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
            } else {
                System.debug('Get PDF Hierarchy Data - No ownership relationships found');
            }
            
            // Find root nodes (accounts with no parents)
            List<Map<String, Object>> rootNodes = new List<Map<String, Object>>();
            for (Map<String, Object> node : accountNodes.values()) {
                List<Map<String, Object>> parents = (List<Map<String, Object>>)node.get('parents');
                if (parents.isEmpty()) {
                    rootNodes.add(node);
                }
            }
            
            System.debug('Get PDF Hierarchy Data - Found ' + rootNodes.size() + ' root nodes');
            
            // Calculate levels (distance from root)
            calculateLevels(rootNodes, 0);
            
            // Create a flattened structure for the visualforce page to avoid recursion
            List<Map<String, Object>> flattenedHierarchy = new List<Map<String, Object>>();
            flattenHierarchy(rootNodes, flattenedHierarchy, accountNodes);
            
            System.debug('Get PDF Hierarchy Data - Created flattened hierarchy with ' + flattenedHierarchy.size() + ' nodes');
            
            // Sort the flattened hierarchy by custom sort rules
            flattenedHierarchy = sortNodes(flattenedHierarchy);
            
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
            
            System.debug('Get PDF Hierarchy Data - Completed successfully');
            return result;
        } catch (Exception e) {
            System.debug('Get PDF Hierarchy Data - Error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
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
     * Simple sorting function to sort nodes by name
     */
    private static List<Map<String, Object>> sortNodes(List<Map<String, Object>> nodes) {
        if (nodes == null || nodes.isEmpty()) {
            return nodes;
        }
        
        List<NodeWrapper> wrappedNodes = new List<NodeWrapper>();
        for (Map<String, Object> node : nodes) {
            wrappedNodes.add(new NodeWrapper(node));
        }
        
        wrappedNodes.sort();
        
        List<Map<String, Object>> sortedNodes = new List<Map<String, Object>>();
        for (NodeWrapper wrapper : wrappedNodes) {
            sortedNodes.add(wrapper.node);
        }
        
        return sortedNodes;
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
        
        // Sort the nodes by name before processing
        List<Map<String, Object>> sortedNodes = sortNodes(nodes);
        
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
     * Inner class to wrap nodes for sorting
     */
    private class NodeWrapper implements Comparable {
        public Map<String, Object> node;
        
        public NodeWrapper(Map<String, Object> node) {
            this.node = node;
        }
        
        public Integer compareTo(Object obj) {
            NodeWrapper other = (NodeWrapper)obj;
            
            String name1 = (String)this.node.get('name');
            String name2 = (String)other.node.get('name');
            
            if (name1 == null) name1 = '';
            if (name2 == null) name2 = '';
            
            return name1.compareTo(name2);
        }
    }
}