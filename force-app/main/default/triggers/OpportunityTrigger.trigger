trigger OpportunityTrigger on Opportunity (before update, before delete) {
    // Before Update
    // 1. Amount alert
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Opportunity opp : Trigger.new) {
            if (opp.Amount <= 5000) {
                opp.Amount.addError('Opportunity amount must be greater than 5000');
            }
        }
    // 2. Set primary contact
        Set<Id> relatedAccounts = new Set<Id>();
        for (Opportunity opp : Trigger.new) {
            relatedAccounts.add(opp.AccountId);
        }
        List<Contact> queryContacts = 
            [SELECT Id, AccountId, Title 
            FROM Contact 
            WHERE AccountId 
            IN :relatedAccounts 
            AND Title LIKE 'CEO'];
        Map<Id, Contact> relatedCeoContacts = new Map<Id, Contact>();
        // there is probably a better way, but I need to Map Account Id to Contact record so I don't think SOQL right on Map creation will do that automatically
        for (Contact contact : queryContacts) {
            relatedCeoContacts.put(contact.AccountId, contact); 
        }
        List<OpportunityContactRole> ocrsToInsert = new List<OpportunityContactRole>();
        for (Opportunity opp : Trigger.new) {
            if (relatedCeoContacts.get(opp.AccountId) != null) {
                opp.Primary_Contact__c = relatedCeoContacts.get(opp.AccountId).Id;
            }
        }
    }
    
    // Before Delete
    if (Trigger.isBefore && Trigger.isDelete) {
        List<Id> accountIds = new List<Id>();
        for (Opportunity opp : Trigger.old) {
            accountIds.add(opp.AccountId);
        }
        Map<Id, Account> relatedAccounts = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN :accountIds]);
        // This was tricky! I'm beginning to get why Maps are so useful
        for (Opportunity opp : Trigger.old) {
            Account parentAccount = relatedAccounts.get(opp.AccountId);
            if (opp.StageName == 'Closed Won' && parentAccount.Industry == 'Banking') {
                opp.StageName.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }
    }
}