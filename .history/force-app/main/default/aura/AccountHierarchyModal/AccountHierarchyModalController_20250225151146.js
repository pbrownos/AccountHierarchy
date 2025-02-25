({
    openModal : function(component, event, helper) {
        $A.createComponent("c:accountHierarchy", 
            {
                // Pass along the recordId so your LWC has context
                recordId : component.get("v.recordId")
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    // Show the modal with the created LWC content
                    component.find("overlayLib").showCustomModal({
                        header: "Account Hierarchy",
                        body: content, 
                        showCloseButton: true,
                        cssClass: "accountHierarchyModal slds-modal_large", // Changed to large and added custom class
                        closeCallback: function() {
                            console.log("Modal closed");
                        }
                    });
                    
                    // Add a small delay to ensure the DOM is ready
                    setTimeout(function() {
                        // Find the modal content area and set its height
                        var modalContent = document.querySelector('.accountHierarchyModal .slds-modal__content');
                        if (modalContent) {
                            // Force the LWC to take full height of the modal content
                            var lwcContainer = modalContent.querySelector('c-account-hierarchy');
                            if (lwcContainer) {
                                lwcContainer.style.height = '100%';
                                lwcContainer.style.display = 'block';
                            }
                        }
                    }, 50);
                    
                    // Close the quick action container modal so that only your overlay remains.
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    console.error("Error creating modal content: " + status);
                }
            }
        );
    }
})