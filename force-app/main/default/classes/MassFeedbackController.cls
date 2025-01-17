public without sharing class MassFeedbackController {
    @AuraEnabled
    public static Boolean csvData(List<Map<String, String>> data) {
        Set<String> gatiCustomerCodes = new Set<String>();
        Map<String, Account> accountsByCustomerCode = new Map<String, Account>();
		List<Account> accounts = new List<Account>();
        Boolean returnData = false;
		List<OrgWideEmailAddress> orgWideDefault = [select id, Address, DisplayName from OrgWideEmailAddress Where Address = 'gsalesforce@gatikwe.com' LIMIT 1];
        List<EmailTemplate> emailTemplateList = [Select Id, Subject, HtmlValue,Body From EmailTemplate Where DeveloperName ='Mass_Customer_Feedback_Template'];
        List<Domain> reqDomain = [Select Domain from Domain where HttpsOption = 'SitesAlt' limit 1];
        string url = '';
        If(reqDomain != null && reqDomain.size()>0){
            url = 'https://'+ reqDomain[0].Domain + '/CustomerFeedback';
        }
        if(data != null && data.size()>0 ){
			for (Map<String, String> rowData : data) {
				String customerCode = rowData.get('CUSTOMER CODE');
				gatiCustomerCodes.add(customerCode);
			}
		}
        if(gatiCustomerCodes != null && gatiCustomerCodes.size()>0)
        	accounts = [SELECT Id, Name, GATI_Customer_Code__c FROM Account WHERE GATI_Customer_Code__c IN :gatiCustomerCodes];
        
        if(accounts != null && accounts.size()>0 && orgWideDefault != null && orgWideDefault.size()>0){
            EmailTemplate emailTemplate = new EmailTemplate();
            if(emailTemplateList != null && emailTemplateList.size()>0)
            	emailTemplate = emailTemplateList[0];
            Integer batchSize = Integer.valueOf(label.CustomerFeedbackBatchSize);
            If(url != null && url != ''){
                CSATEmailBatch batch = new CSATEmailBatch(accounts,orgWideDefault[0].Id,emailTemplate,url);
                Id jobId = Database.executeBatch(batch,batchSize);
                if(jobId != null)
                    returnData = true;
            }
        }
        return returnData;
    }
}