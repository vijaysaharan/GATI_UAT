/*
 *  CreatedBy : Arpit Shrivastava
 *  Description : For Case Update
 *  CreatedDate: 15/07/2021 
 */
@RestResource(urlMapping='/CaseUpdateAPI/*')
global without sharing class CaseUpdateAPI {
    @HttpPost
    global static SuccessErrorWrapper doPost() {
        CaseWrapper caseWrapperObj = (CaseWrapper)System.JSON.deserialize(
            RestContext.request.requestBody.tostring(), 
            CaseWrapper.class);
        
        system.debug('caseWrapperObj.caseObj.CaseNumber '+caseWrapperObj.caseObj.CaseNumber);
        Case caseRecordObj = [select id from case where CaseNumber =:caseWrapperObj.caseObj.CaseNumber];
        system.debug('caseRecordObj '+caseRecordObj);
        try{
            if(caseWrapperObj.caseObj.CaseNumber != null){
                   caseWrapperObj.caseObj.Id = caseRecordObj.Id;
                   caseRecordObj = caseWrapperObj.caseObj;
                   Database.SaveResult result = Database.update(caseRecordObj, false);
            
                   if(result.isSuccess()){
                       Case caseSuccessObj = [select CaseNumber from case where  id=:result.id]; 
                       SuccessErrorWrapper successObj  = new SuccessErrorWrapper();
                       successObj.CaseNumber = caseSuccessObj.CaseNumber;
                       successObj.Status = 'Updated';
                       return successObj; 
                     } 
                   else{
                       SuccessErrorWrapper errorObj = new SuccessErrorWrapper();
                       errorObj.Status ='Not Updated';
                       for(Database.Error er: result.geterrors()){
                             errorObj.error= er.getMessage() ;}
                       return errorObj;
                     }
            }

        }   
        catch(Exception e)
        {
            Integration_Log__c log = new Integration_Log__c();
            log.Component_Name__c='Case Update';
            log.Error_Message__c=e.getMessage();
            log.IsIntegration__c=true; 
            insert log; 
        }
            return null;
    }
    
    private class CaseWrapper {
        Case caseObj;
    } 
    
    global class SuccessErrorWrapper {
        String caseNumber {get;set;}
        String status {get;set;}
        String error {get;set;}  
    }
}