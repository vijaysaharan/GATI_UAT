public class customerFeedbackController {
    public string accountId {get;set;} 
    public string contactId {get;set;} 
    public string accountName {get;set;}
    public string contactName {get;set;}
    public string Designation {get;set;}
    public string contactEmail {get;set;}
    public string contactPhone {get;set;}
    
    public customerFeedbackController(){
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        //system.debug('accountId'+accountId);
        //system.debug('contactId'+contactId);
        
        if (accountId != null) {
            Account account = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
            accountName = account != null ? account.Name : null;
        }
        
        if (contactId != null) {
            Contact contact = [SELECT Id, FirstName, LastName, Designation__c, Email, MobilePhone FROM Contact WHERE Id = :contactId LIMIT 1];
            contactName = contact != null ? contact.FirstName + ' ' + contact.LastName : null;
            Designation = contact != null ? contact.Designation__c : null;
            contactEmail = contact != null ? contact.Email : null;
            contactPhone = contact != null ? contact.MobilePhone : null;
        }
        
        //system.debug('accountName: ' + accountName);
        //system.debug('contactName: ' + contactName);
    }
}