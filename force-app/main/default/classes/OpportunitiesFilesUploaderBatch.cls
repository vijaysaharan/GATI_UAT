public class OpportunitiesFilesUploaderBatch implements Database.Batchable<sObject>, Database.Stateful{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Account.GATI_Customer_Code__c FROM Opportunity';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, String> opportunityIdToCustomerCode = new Map<Id, String>();
        Set<Id> documentIds = new Set<Id>();
        Map<Id, Id> documentIdToOpportunityId = new Map<Id, Id>();
        
        for(Opportunity opp : scope){
        	opportunityIds.add(opp.Id);
            if(opp.Account.GATI_Customer_Code__c != null && opp.Account.GATI_Customer_Code__c != ''){
             	opportunityIdToCustomerCode.put(opp.Id,opp.Account.GATI_Customer_Code__c);   
            }
        }
        
        List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: opportunityIds];
        
        if(contentLinks != null && contentLinks.size() > 0){            
            for(ContentDocumentLink link : contentLinks){
                documentIdToOpportunityId.put(link.ContentDocumentId, link.LinkedEntityId);
                documentIds.add(link.ContentDocumentId);
            }
            
            List<ContentVersion> contentVersions = [SELECT VersionData,Title,ContentDocumentId,FileExtension,FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId IN: documentIds];
            
            for(ContentVersion cv : contentVersions){
                String fileName = opportunityIdToCustomerCode.containsKey(documentIdToOpportunityId.get(cv.ContentDocumentId)) ?  opportunityIdToCustomerCode.get(documentIdToOpportunityId.get(cv.ContentDocumentId))+'-'+cv.Title+'.'+cv.FileExtension : documentIdToOpportunityId.get(cv.ContentDocumentId)+'-'+cv.Title+'.'+cv.FileExtension;
                String fileData = EncodingUtil.base64Encode(cv.VersionData);
                Boolean isSuccess = UploadVerificationDocumentsController.sendFileToAWS(fileData, fileName);
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('All Opportunities files send to AWS.');
    }
}