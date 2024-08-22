trigger AccountTrigger on Account (before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        for (Account acct : Trigger.new) {
            if (acct.Type == null){
                acct.Type = 'Prospect';
            }
            if (acct.ShippingStreet != null || acct.ShippingCity != null || acct.ShippingState != null || acct.ShippingPostalCode != null || acct.ShippingCountry != null) {
                acct.BillingStreet = acct.ShippingStreet;
                acct.BillingCity = acct.ShippingCity;
                acct.BillingState = acct.ShippingState;
                acct.BillingPostalCode = acct.ShippingPostalCode;
                acct.BillingCountry = acct.ShippingCountry;
            }
            if (acct.Phone != null && acct.Website != null && acct.Fax != null) {
                acct.Rating = 'Hot';
            }
        }
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        List<Contact> contactList = new List<Contact>();
        for (Account acct : Trigger.new) {
            Contact newContact = new Contact(LastName = 'DefaultContact', Email = 'default@email.com', AccountId = acct.Id);
            contactList.add(newContact);
        }
        insert contactList;
    }
}