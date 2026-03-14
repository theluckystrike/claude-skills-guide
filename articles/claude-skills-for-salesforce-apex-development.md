---
layout: default
title: "Claude Skills for Salesforce Apex Development"
description: "Practical guide to using Claude Code skills for Salesforce Apex development: code generation, testing, debugging, and deployment automation."
date: 2026-03-14
categories: [salesforce, apex, development]
tags: [claude-code, claude-skills, salesforce, apex, force.com]
author: theluckystrike
---

# Claude Skills for Salesforce Apex Development

Salesforce Apex development presents unique challenges that differ from traditional object-oriented programming. The platform's governor limits, trigger patterns, and declarative customization options require specific workflows. Claude Code skills can help you navigate these requirements efficiently, reducing boilerplate code and improving test coverage.

## apex-generator: Scaffold Classes and Triggers Quickly

The **apex-generator** skill creates boilerplate Apex classes, triggers, and supporting structures. This skill understands Salesforce naming conventions and generates code that follows platform best practices.

```bash
# Generate a trigger with helper class
"Create an Apex trigger on the Opportunity object that updates a custom field when the stage changes"
```

This generates a trigger with proper handler class separation:

```apex
// OpportunityTrigger.trigger
trigger OpportunityTrigger on Opportunity (before update) {
    OpportunityTriggerHandler.handleStageChange(Trigger.new, Trigger.oldMap);
}

// OpportunityTriggerHandler.cls
public class OpportunityTriggerHandler {
    public static void handleStageChange(List<Opportunity> newRecords, 
                                          Map<Id, Opportunity> oldMap) {
        for (Opportunity opp : newRecords) {
            Opportunity old = oldMap.get(opp.Id);
            if (opp.StageName != old.StageName && 
                opp.StageName == 'Closed Won') {
                opp.Custom_Field__c = System.now();
            }
        }
    }
}
```

The generated code includes proper null checks and bulkification patterns from the start.

## test-generator: Create Comprehensive Test Classes

Testing in Salesforce is mandatory for deployment. The **test-generator** skill builds test classes with realistic test data, assert statements, and proper coverage targets.

```bash
# Generate test class for OpportunityTriggerHandler
"Create a test class for OpportunityTriggerHandler with test methods for stage change scenarios including closed won, closed lost, and stage progression"
```

This produces:

```apex
@IsTest
private class OpportunityTriggerHandlerTest {
    
    @TestSetup
    static void setup() {
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;
    }
    
    @IsTest
    static void testStageChangeToClosedWon() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        
        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();
        
        Opportunity updated = [SELECT Custom_Field__c FROM Opportunity 
                               WHERE Id = :opp.Id];
        System.assertNotEquals(null, updated.Custom_Field__c);
    }
    
    @IsTest
    static void testStageChangeToClosedLost() {
        // Additional test method for closed lost scenario
    }
}
```

The test class includes TestSetup methods for reusable test data and covers multiple execution paths.

## soql-builder: Construct Complex Queries

The **soql-builder** skill helps construct optimized SOQL queries with proper relationship traversal and filter conditions. This skill is particularly useful for complex reporting queries or data migration scripts.

```bash
# Generate SOQL query with subquery
"Write a SOQL query to retrieve all contacts from accounts where the account has more than 5 opportunities in the Closed Won stage"
```

The output:

```apex
List<Account> accounts = [
    SELECT Id, Name, 
           (SELECT Id, Name, Email FROM Contacts)
    FROM Account
    WHERE Id IN (
        SELECT AccountId FROM Opportunity
        WHERE StageName = 'Closed Won'
        GROUP BY AccountId
        HAVING COUNT(Id) > 5
    )
];
```

This query uses a subquery and HAVING clause correctly, avoiding inefficient loops.

## debug-analyzer: Interpret Debug Logs

Salesforce debug logs can be overwhelming. The **debug-analyzer** skill parses debug output, identifies governor limit violations, and suggests optimizations.

```bash
# Analyze a debug log for performance issues
"Identify the cause of CPU time limit exceeded in this debug log excerpt"
```

The skill highlights problematic areas:

```apex
// Common issue: Nested loops causing CPU timeout
for (List<Opportunity> opps : [SELECT Id, Amount FROM Opportunity]) {
    for (Opportunity o : opps) {
        // Query inside loop - major performance issue
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :o.Id];
    }
}

// Solution: Pre-query and map
Map<Id, List<Task>> taskMap = new Map<Id, List<Task>>();
for (Task t : [SELECT Id, WhatId FROM Task 
               WHERE WhatId IN :oppsById.keySet()]) {
    if (!taskMap.containsKey(t.WhatId)) {
        taskMap.put(t.WhatId, new List<Task>());
    }
    taskMap.get(t.WhatId).add(t);
}
```

## deployment-helper: Package and Deploy Metadata

The **deployment-helper** skill generates deployment scripts using Salesforce CLI or Ant migration tools. It creates package.xml files and validates components before deployment.

```bash
# Generate deployment package
"Create a deployment package for moving a custom object, its fields, and related Apex classes from sandbox to production"
```

This produces the necessary metadata package:

```xml
<!-- package.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>Custom_Object__c</members>
        <name>CustomObject</name>
    </types>
    <types>
        <members>Custom_Object__c.Custom_Field__c</members>
        <name>CustomField</name>
    </types>
    <types>
        <members>MyApexClass</members>
        <name>ApexClass</name>
    </types>
    <version>58.0</version>
</Package>
```

Combined with a deployment script:

```bash
# Using Salesforce CLI
sf project deploy metadata \
  --source-dir ./metadata/package.xml \
  --target-org production \
  --test-level RunLocalTests
```

## flow-to-apex: Convert Declarative Elements

When declarative automation reaches its limits, the **flow-to-apex** skill helps translate Flow Builder elements into Apex code. This is useful for complex calculations or logic that requires fine-grained control.

```bash
# Convert a flow to Apex
"Convert this Flow Builder logic to an Apex class: loop through opportunity line items, calculate discount based on quantity tiers, and update the opportunity amount"
```

## Practical Workflow Example

Here is how these skills work together in a real development scenario:

1. **Scaffold**: Use `apex-generator` to create a new trigger and handler for account validation
2. **Test**: Generate tests with `test-generator` to achieve required coverage
3. **Query**: Build complex SOQL with `soql-builder` for data retrieval
4. **Debug**: Run the code and use `debug-analyzer` to fix any limit issues
5. **Deploy**: Package with `deployment-helper` for sandboxes or production

This workflow reduces manual coding time significantly, especially for repetitive patterns like trigger handlers and test classes.

## Limitations and Considerations

These skills work best with standard Salesforce patterns. Complex scenarios involving Platform Events, Big Objects, or Experience Cloud may require manual refinement. Always review generated code against your organization's coding standards and security requirements.

For example, CRUD/FLS enforcement needs explicit handling that may not be included in initial generations:

```apex
// Always add field-level security checks
if (Schema.sObjectType.Opportunity.fields.Amount.isUpdateable()) {
    opp.Amount = calculatedAmount;
}
```

Add these security checks before deploying to production environments.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
