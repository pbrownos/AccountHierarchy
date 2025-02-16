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
                        cssClass: "slds-modal_medium",
                        closeCallback: function() {
                            console.log("Modal closed");
                        }
                    });
                    // Close the quick action container modal so that only your overlay remains.
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    console.error("Error creating modal content: " + status);
                }
            }
        );
    }
})