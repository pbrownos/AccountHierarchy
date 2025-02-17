# Account Ownership Hierarchy Component

This Lightning Web Component (LWC) provides a clear visualization of complex account ownership relationships in Salesforce. Unlike the standard Account Hierarchy, this component supports multiple parent companies for a single account and displays ownership percentages between related accounts.

## Features

- Displays multi-parent ownership relationships
- Shows ownership percentages between accounts
- Collapsible hierarchy levels
- Easy-to-use expand/collapse all functionality
- Highlights the current account in the hierarchy
- Direct navigation to any account in the hierarchy

## Getting Started

### Prerequisites

- [CumulusCI](https://cumulusci.readthedocs.io/en/latest/get_started.html) installed on your machine
- Have a default DevHub org setup in VS Code and configured in CumulusCI

### Quick Setup

1. Clone this repository
2. Navigate to the repository directory
3. Run the setup script:
   ./bin/DailyScratchCreate

   This will:
   - Create a new scratch org
   - Deploy the component and related metadata
   - Load sample account data with ownership relationships
   - Open the scratch org in a browser

4. Navigate to any Account record to see the Ownership Hierarchy component in action. The component can also be launched in a modal via the View Hierarchy button on the Account detail page.

## Using the Component

The Ownership Hierarchy component appears on Account record pages and shows:
- Parent companies that own the current account (with ownership percentages)
- Subsidiary accounts owned by the current account
- Complete ownership chain both up and down the hierarchy

Use the expand/collapse buttons to:
- Show or hide specific branches of the hierarchy
- Expand or collapse the entire hierarchy at once

Click any account name to navigate directly to that account's record page.

## Sample Data

The included sample data demonstrates various ownership scenarios:
- Single parent-subsidiary relationships
- Multiple parent companies for a single subsidiary
- Multi-level ownership chains
- Various ownership percentages