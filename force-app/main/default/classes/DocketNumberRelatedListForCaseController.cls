public without sharing class DocketNumberRelatedListForCaseController {
    @AuraEnabled
    public static List<Case> getRelatedCases(Id recordId) {
        try {
            List<Case> currentCase = [SELECT Id,Docket_Number__c FROM Case WHERE Id =:recordId];
            List<Case> caseList = New List<Case>();
            if(currentCase != null && currentCase.size()>0){
                caseList = [
                            SELECT Id,CaseNumber,Docket_Number__c,Status,Subject,CreatedDate 
                            FROM Case 
                            WHERE Docket_Number__c =: currentCase[0].Docket_Number__c
                            AND Docket_Number__c != null
                            AND Id !=: currentCase[0].Id
                            ORDER BY CreatedDate DESC
                            ];
            }
            return caseList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}