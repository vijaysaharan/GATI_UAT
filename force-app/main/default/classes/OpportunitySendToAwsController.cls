public with sharing class OpportunitySendToAwsController {
    @AuraEnabled
    public static List<Id> getAllAccounts(){
        try {
            Set<Id> accountIdToReturn = new Set<Id>();
            Map<Id, Opportunity> OppIds = new Map<Id, Opportunity>([SELECT Id, AccountId From Opportunity WHERE AccountId != null AND Account.GATI_Customer_Code__c != null AND DAY_ONLY(CreatedDate) >= 2022-12-31]);
            List<ContentDocumentLink> cdls = [SELECT Id, LinkedEntityId From ContentDocumentLink Where LinkedEntityId In :OppIds.keySet()];
            for(ContentDocumentLink cdl : cdls){                
                accountIdToReturn.add(OppIds.get(cdl.LinkedEntityId).AccountId);
            }
            List<Id> returnIds = new List<Id>();
            returnIds.addAll(accountIdToReturn);
            return returnIds;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, List<contentData>> getContentVersions(List<Id> accIds){
        try {
            Set<Id> opportunityIds = new Set<Id>();
            Map<Id, String> opportunityIdToCustomerCode = new Map<Id, String>();
            Set<Id> documentIds = new Set<Id>();
            Map<Id, Id> documentIdToOpportunityId = new Map<Id, Id>();
            List<Opportunity> scope = [SELECT Id,Account.GATI_Customer_Code__c FROM Opportunity WHERE AccountId IN :accIds];
            Map<String, List<contentData>> returnData = new Map<String, List<contentData>>();
            
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
                    if(cv.FileExtension != null && Label.FileExtentionsAccepted.contains(cv.FileExtension.toUpperCase())){
                        contentData cd = new contentData();
                        cd.fileName = opportunityIdToCustomerCode.containsKey(documentIdToOpportunityId.get(cv.ContentDocumentId)) ?  opportunityIdToCustomerCode.get(documentIdToOpportunityId.get(cv.ContentDocumentId))+'-'+cv.Title.deleteWhitespace()+'.'+cv.FileExtension : documentIdToOpportunityId.get(cv.ContentDocumentId)+'-'+cv.Title.deleteWhitespace()+'.'+cv.FileExtension;
                        cd.fileData = EncodingUtil.base64Encode(cv.VersionData);
                        if(returnData.containsKey(opportunityIdToCustomerCode.get(documentIdToOpportunityId.get(cv.ContentDocumentId)))){
                            returnData.get(opportunityIdToCustomerCode.get(documentIdToOpportunityId.get(cv.ContentDocumentId))).add(cd);
                        }
                        else{
                            returnData.put(opportunityIdToCustomerCode.get(documentIdToOpportunityId.get(cv.ContentDocumentId)), new List<contentData>{cd}); 
                        }   
                    }
                }
            }            
            return returnData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class contentData{
        @AuraEnabled public String fileName;
        @AuraEnabled public String fileData;
    }
}