@isTest
private class AccountHierarchyPdfControllerTest {
    @testSetup
    static void setupTestData() {
        // Create test accounts
        Account parentAccount = new Account(
            Name = 'Test Parent Corp',
            sims_Insurer_Type__c = 'Certified'
        );
        insert parentAccount;
        
        Account subsidiaryAccount = new Account(
            Name = 'Test Subsidiary Inc',
            sims_Insurer_Type__c = 'Admitted Reinsurer'
        );
        insert subsidiaryAccount;
        
        // Create ownership relationship
        Ownership__c ownership = new Ownership__c(
            Parent__c = parentAccount.Id,
            Subsidiary__c = subsidiaryAccount.Id,
            Ownership_Percentage__c = 75.5
        );
        insert ownership;
    }
    
    @isTest
    static void testGenerateHierarchyPdf() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Parent Corp' LIMIT 1];
        
        Test.startTest();
        String pdfBase64 = AccountHierarchyPdfController.generateHierarchyPdf(testAccount.Id);
        Test.stopTest();
        
        // Verify we get a result (in test context, this is a placeholder)
        System.assertNotEquals(null, pdfBase64, 'PDF data should not be null');
        System.assertEquals('VGVzdCBQREYgQ29udGVudA==', pdfBase64, 'PDF content should match test value');
    }
    
    @isTest
    static void testGetPdfHierarchyData() {
        Account parentAccount = [SELECT Id FROM Account WHERE Name = 'Test Parent Corp' LIMIT 1];
        
        Test.startTest();
        Map<String, Object> hierarchyData = AccountHierarchyPdfController.getPdfHierarchyData(parentAccount.Id);
        Test.stopTest();
        
        // Verify hierarchy data
        System.assertNotEquals(null, hierarchyData, 'Hierarchy data should not be null');
        System.assertEquals('Test Parent Corp', hierarchyData.get('accountName'), 'Account name should match');
        
        // Check that we have root nodes
        List<Map<String, Object>> rootNodes = (List<Map<String, Object>>)hierarchyData.get('rootNodes');
        System.assertNotEquals(null, rootNodes, 'Root nodes should not be null');
        System.assert(!rootNodes.isEmpty(), 'Root nodes should not be empty');
        
        // Check that we have flattened hierarchy
        List<Map<String, Object>> flattenedHierarchy = (List<Map<String, Object>>)hierarchyData.get('flattenedHierarchy');
        System.assertNotEquals(null, flattenedHierarchy, 'Flattened hierarchy should not be null');
        
        // Check that the hierarchy structure is correct
        Map<String, Object> accountHierarchy = (Map<String, Object>)hierarchyData.get('hierarchy');
        System.assertNotEquals(null, accountHierarchy, 'Account hierarchy should not be null');
        System.assertEquals(parentAccount.Id, accountHierarchy.get('id'), 'Hierarchy ID should match parent account ID');
        
        // Check children
        List<Map<String, Object>> children = (List<Map<String, Object>>)accountHierarchy.get('children');
        System.assertNotEquals(null, children, 'Children list should not be null');
        System.assertEquals(1, children.size(), 'Should have 1 child account');
        
        // Check that we have the child account with correct percentage
        Boolean foundChild = false;
        for (Map<String, Object> child : children) {
            if (child.get('percentage') == 75.5) {
                foundChild = true;
                break;
            }
        }
        System.assert(foundChild, 'Should find child with correct ownership percentage');
    }
    
    @isTest
    static void testGetPdfHierarchyDataWithInvalidId() {
        Id invalidId = '001000000000000';
        
        Test.startTest();
        try {
            Map<String, Object> hierarchyData = AccountHierarchyPdfController.getPdfHierarchyData(invalidId);
            System.assert(false, 'Should have thrown an exception for invalid ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error preparing PDF data'), 'Exception message should indicate error preparing PDF data');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testVisualforcePage() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Parent Corp' LIMIT 1];
        
        Test.startTest();
        // Create the page reference
        PageReference pageRef = Page.AccountHierarchyPdf;
        pageRef.getParameters().put('accountId', testAccount.Id);
        
        // Set the page reference
        Test.setCurrentPage(pageRef);
        
        // Instantiate the controller
        AccountHierarchyPdfController controller = new AccountHierarchyPdfController();
        
        // Check that hierarchyData is populated
        System.assertNotEquals(null, controller.hierarchyData, 'Hierarchy data property should not be null');
        
        // Check that the account name is correct
        System.assertEquals('Test Parent Corp', controller.hierarchyData.get('accountName'), 'Account name should match');
        Test.stopTest();
    }
}