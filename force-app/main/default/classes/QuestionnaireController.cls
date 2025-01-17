public without sharing class QuestionnaireController {
    @AuraEnabled
    public static List<Questionare__c> getQuestions() {
        return [Select Id ,Name,  Question__c, IsActive__c, Sequence__c, Options__c, OptionsType__c, RowLength__c, Create_Lead__c, Lead_Criteria__c, Specify_Others__c from Questionare__c Where IsActive__c=true Order By Sequence__c];
    }
    
    @AuraEnabled
    public static String insertConsigneeFeedback(ConsigneeFeedback__c lstToInsert){
        System.debug('___'+lstToInsert);
        try{
            System.debug('___'+lstToInsert);
            if(lstToInsert != null ){
                insert lstToInsert;
                String ConsigneeFeedbackId = [Select Id From ConsigneeFeedback__c Where Id =:lstToInsert.Id limit 1].Id;
                return ConsigneeFeedbackId;
            }
            return '';
        } catch(Exception e){
            System.debug('---->'+e);
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    @AuraEnabled
    public static Boolean insertConsigneeQuestionnaire(List<ConsigneeQuestionnaire__c> lstToInsert){
        System.debug('--->'+lstToInsert);
        try{
            if(lstToInsert != null && lstToInsert.size() > 0){
                insert lstToInsert;
                return true;
            }
            return false;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    @AuraEnabled
    public static Map<String,Lead> insertLeadFromConsignee(Map<String,Lead> lstToInsert){
        System.debug('--->' + lstToInsert);
        try {
            if (lstToInsert != null && !lstToInsert.isEmpty()) {
                insert lstToInsert.values();
                System.debug('Map==>'+lstToInsert);
                return lstToInsert;
            }
            return new Map<String, Lead>();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistOptions(String objectName, String fieldName) {
        List<String> options = new List<String>();
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        
        Schema.DescribeFieldResult fieldDescribe = describeResult.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
        
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            options.add(picklistEntry.getValue());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static Boolean getAllStaffCode(String staffCode){
        try{
            List<Contact> conList = [Select Id, StaffCode__c, STAFF_STATUS__c  From Contact Where STAFF_STATUS__c = 'W' And StaffCode__c =:staffCode];
            if(!conList.isEmpty() && conList.size()>0){
                System.debug('conList>>'+conList);
                return true;
            }
            return false; 
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}