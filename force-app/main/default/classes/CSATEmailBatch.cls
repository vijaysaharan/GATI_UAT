public class CSATEmailBatch implements Database.Batchable<sobject>, Database.Stateful {
     
    private List<Account> accounts;
    private String ContactType;
    private  Map<String, Contact> contactsByEmail;
    private Id orgWideDefaultId;
    private EmailTemplate emailTemplate;
    private String url;
	
	public CSATEmailBatch(List<Account> accounts,Id orgWideDefaultId,EmailTemplate emailTemplate,String url) {
        this.accounts = accounts;
        this.ContactType = 'CSAT';
        this.contactsByEmail = new Map<String, Contact>();
		this.orgWideDefaultId = orgWideDefaultId;
        this.emailTemplate = emailTemplate;
        this.url = url;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Name, Email,Account.GATI_Customer_Code__c,Account.Name, AccountId, Contact_type__c FROM Contact WHERE AccountId IN :accounts AND Email != Null AND Contact_type__c =: ContactType';
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Contact> scope) {
		List<Messaging.SingleEmailMessage> allResultEmails = new List<Messaging.SingleEmailMessage>(); 
		List<Contact> conDetail = new List<Contact>();
		for (Contact con : scope) {
            String email = con.Email;
            if (contactsByEmail.containsKey(email)) {
            }else{
				contactsByEmail.put(email,con);
				conDetail.add(con);
                Messaging.SingleEmailMessage emailResult = MassEmailUtility.sendEmail(email, con.AccountId, con.Id,orgWideDefaultId,emailTemplate,url);
				allResultEmails.add(emailResult);
			}
        }
		if(allResultEmails != null && allResultEmails.size()>0){
			List<Messaging.SendEmailResult> allResponses = Messaging.sendEmail(allResultEmails);
			if(allResponses != null && allResponses.size()>0 && conDetail != null && conDetail.size()>0) {
				List<Customer_Feedback_Email_Status__e> eventList = new List<Customer_Feedback_Email_Status__e>();
				for(Integer i=0; i<allResponses.size(); i++){
					Customer_Feedback_Email_Status__e event = new Customer_Feedback_Email_Status__e();
					event.Account_Id__c = conDetail[i].AccountId;
					event.Contact__c = JSON.serialize(conDetail[i]);
					if(allResponses[i].isSuccess()){
						event.done__c = true;
						event.Title__c = conDetail[i].AccountId + ' Success';
						event.Result__c = 'Success';
					}else{
						event.done__c = false;
						event.Title__c = 'Email Not Sent';
						event.Result__c = allResponses[i].getErrors()[0].getMessage();
					}
					eventList.add(event);
				}
				if(eventList != null && eventList.size()>0){
					Integer successCount = 0;
					Integer errorCount = 0;
					List<Database.SaveResult> results = EventBus.publish(eventList);
					for (Database.SaveResult sr : results) {
						if (sr.isSuccess()) {
							successCount++;
						} else {
							for(Database.Error err : sr.getErrors()) {
								System.debug('Error returned: ' +
											err.getStatusCode() +
											' - ' +
											err.getMessage());
							}
							errorCount++;
						}       
					}
					System.debug('successCount'+successCount);
					System.debug('errorCount'+errorCount);
				}
			}
		}
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Finished');
    }
    
}