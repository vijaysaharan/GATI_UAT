public with sharing class addExpenseInVisitController {
    @AuraEnabled
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
    public static nameOrder getExpenseLabelOptions() {
        nameOrder returnData = new nameOrder();
        List<labelOptions> labelPicklist = new List<labelOptions>();
        List<String> recordPageNameOrder = Label.expenseRecordPageNamesOrder.split(';');
        List<RecordType> recTyp = [Select Id, Name, DeveloperName, SobjectType, IsActive from RecordType Where SobjectType = 'Expense__c' And IsActive = true];
        for(RecordType rec : recTyp){
            labelOptions option = new labelOptions();
            option.Label = rec.DeveloperName;
            option.Value = rec.Id;
            labelPicklist.add(option);
        }
        
        returnData.recordNameOrder = recordPageNameOrder;
        returnData.pickList = labelPicklist;
        
        return returnData;
    }
    
    public class labelOptions{
        @AuraEnabled public String Label{get;set;}
        @AuraEnabled public String Value{get;set;}
    }
    
    public class nameOrder{
        @AuraEnabled public List<String> recordNameOrder{get;set;}
        @AuraEnabled public List<labelOptions> pickList{get;set;}
    }
    
    @AuraEnabled
    public static Boolean upsertExpense(List<Expense__c> lstToUpsert){
        System.debug('UpsertList'+lstToUpsert);
        try{
            if(lstToUpsert != Null){
                upsert lstToUpsert;
                return true;
            }
            return false;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static List<returnMap> expenseListForVisit(Id visitId){
        List<returnMap> mapOfExpense = new List<returnMap>();
        List<Expense__c> expenseListForVisit = [Select Id,RecordTypeId,To__c,From__c,Employee_Name__c,From_Date__c,To_Date__c,No_of_Days__c,State_Name__c,City_Name__c,HotelLodgeName__c,Bill_No__c,Accepted_Amount__c,Paticulars__c,Distance__c,Customer_Connect__c,Amount__c,Visit__c,Mode__c,Description__c From Expense__c Where  Visit__c =:visitId];  
        Map<Id,List<Expense__c>> customerIdExpenseMap = new Map<Id,List<Expense__c>>();
        Map<Id,Customer_Connect__c> customerMap = new Map<Id,Customer_Connect__c>();
        Set<Id> cusIds = new Set<Id>();
        for(Expense__c exp : expenseListForVisit){
            cusIds.add(exp.Customer_Connect__c);
            if(customerIdExpenseMap.containsKey(exp.Customer_Connect__c)){
                customerIdExpenseMap.get(exp.Customer_Connect__c).add(exp);
            }
            else{
                customerIdExpenseMap.put(exp.Customer_Connect__c,new List<Expense__c>{ exp });
            }
        }
        Visit__c visitData = [Select Id,Visit_Date__c,Employee_Name__c,Visit_Start_DateTime__c,Visit_End_DateTime__c,Source_Geo_Coordinate__Latitude__s,Source_Geo_Coordinate__Longitude__s From Visit__c Where Id =:visitId];
        List<Customer_Connect__c> customerConnectList = [SELECT Id, Name,OwnerId,Visit_Date__c, CreatedDate,Check_In_Location__Latitude__s, Check_In_Location__Longitude__s,Check_In_Time__c,Check_Out_Time__c,Check_Out_Location__Longitude__s,Check_Out_Location__Latitude__s,Customer_Code__r.Name,Lead__r.Name FROM Customer_Connect__c WHERE DAY_ONLY(Visit_Start_Date__c) = :visitData.Visit_Date__c And Check_In_Time__c != Null And OwnerId =:visitData.Employee_Name__c Order By Check_In_Time__c];
        for(Customer_Connect__c cc : customerConnectList){
            customerMap.put(cc.Id,cc);
            if(customerIdExpenseMap.containsKey(cc.Id)){
            }
            else{
                customerIdExpenseMap.put(cc.Id,new List<Expense__c> {});
            }
        }
        for(Id cusId : customerIdExpenseMap.keySet()){
            returnMap mp = new returnMap();
            mp.customerData = customerMap.get(cusId);
            mp.expenseDataList = customerIdExpenseMap.get(cusId);
            mapOfExpense.add(mp);
        }
        SYstem.debug(mapOfExpense);
        return mapOfExpense;
    }
    
    @AuraEnabled
    public static Travel_Policy__c getPricePolicyDetail(Id visitId){
        try{
            Visit__c visitData = [Select Id, Employee_Name__c From Visit__c Where Id =:visitId];
            User uData = [Select Id,Grade__c From User Where Id =: visitData.Employee_Name__c];
            Travel_Policy__c travelPriceData = [Select Id, Name, TwoWheelerEntitlement__c, FourWheelerEntitlement__c From Travel_Policy__c Where Name =:uData.Grade__c];
            if(travelPriceData != Null){
                return travelPriceData;
            }
            return new Travel_Policy__c();
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class returnMap{
        @AuraEnabled public Customer_Connect__c customerData{get;set;}
        @AuraEnabled public List<Expense__c> expenseDataList{get;set;}
    }
    
    @AuraEnabled 
    public static Boolean deleteExpenseRecord(Expense__c expenseData){
        if(expenseData != Null){
            delete expenseData;
            return true;
        }
        return false;
    }
    
    @AuraEnabled 
    public static returnToAndFrom getFromPlaceAndToPlace(Id visitId, Id customerConnectId){
        returnToAndFrom returnData = new returnToAndFrom();
        Visit__c visitData = [Select Id,Source_Address__c,Employee_Name__c,Visit_Start_DateTime__c,Visit_End_DateTime__c,Visit_Date__c,Source_Geo_Coordinate__Latitude__s,Source_Geo_Coordinate__Longitude__s From Visit__c Where Id =: visitId];
        Customer_Connect__c currCustomer = [SELECT Id,Check_In_Address__c, Name,Visit_Start_Date__c,OwnerId,Visit_Date__c, CreatedDate,Check_In_Location__Latitude__s, Check_In_Location__Longitude__s,Check_In_Time__c,Check_Out_Time__c,Check_Out_Location__Longitude__s,Check_Out_Location__Latitude__s,Customer_Code__r.Name FROM Customer_Connect__c WHERE Id =: customerConnectId];
        List<Customer_Connect__c> customerConnectList = [SELECT Id,Check_In_Address__c, Name,OwnerId,Visit_Date__c, CreatedDate,Check_In_Location__Latitude__s, Check_In_Location__Longitude__s,Check_In_Time__c,Check_Out_Time__c,Check_Out_Location__Longitude__s,Check_Out_Location__Latitude__s,Customer_Code__r.Name FROM Customer_Connect__c WHERE DAY_ONLY(Visit_Start_Date__c) = :visitData.Visit_Date__c And Check_In_Time__c != Null And OwnerId =:visitData.Employee_Name__c Order By Check_In_Time__c];
        returnData.ToAddress = currCustomer.Check_In_Address__c;
        Integer index = 0;
        for (Integer i = 0; i < customerConnectList.size(); i++) {
            if (customerConnectList[i].Id == customerConnectId) {
                index = i;
                break; 
            }
        }
        if(index == 0){
            returnData.FromAddress = visitData.Source_Address__c;
        }
        else{
            returnData.FromAddress = customerConnectList[index-1].Check_In_Address__c;
        }
        
        return returnData;
    }
    
    public class returnToAndFrom{
        @AuraEnabled public String FromAddress{get;set;}
        @AuraEnabled public String ToAddress{get;set;}
    }
    
    @AuraEnabled
    public static Boolean createExpenseDataWithAttachment(Map<String, Expense__c> fakeIdRecordMap, Map<String, List<String>> fakeIdsAttachmentMap) {
        Boolean returnVal = false;
        Map<String, Expense__c> mapOfExpense = new Map<String, Expense__c>();
        Map<String, List<String>> mapOfAttachments = new Map<String, List<String>>();
        if(!fakeIdRecordMap.isEmpty()){
            mapOfExpense = fakeIdRecordMap;
        }
        if(!fakeIdsAttachmentMap.isEmpty()){
            mapOfAttachments = fakeIdsAttachmentMap;
        }
        if(fakeIdsAttachmentMap.isEmpty() && fakeIdRecordMap.isEmpty()){
            returnVal = true;
        }
        List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>(); 

        if(mapOfExpense != null && !mapOfExpense.values().isEmpty()){
            upsert mapOfExpense.values();
            if(fakeIdsAttachmentMap.isEmpty()){
                returnVal = true;
            }
        }
        if(!mapOfAttachments.isEmpty()){
            for(String fakeId : mapOfAttachments.keySet()){
                if(mapOfAttachments.get(fakeId) != null && mapOfAttachments.get(fakeId).size()>0){
                    for(String each : mapOfAttachments.get(fakeId)){
                        ContentDocumentLink newCd = new ContentDocumentLink();
                        ContentDocumentLink newCd1 = new ContentDocumentLink();
                        newCd.ShareType = 'V';
                        newCd1.ShareType = 'V';
                        newCd.ContentDocumentId = each;
                        newCd1.ContentDocumentId = each;
                        if(mapOfExpense.get(fakeId) != null && mapOfExpense.get(fakeId).Id != null){
                            newCd.LinkedEntityId = mapOfExpense.get(fakeId).Id;
                            if(mapOfExpense.get(fakeId).Visit__c != null){
                             	newCd1.LinkedEntityId = mapOfExpense.get(fakeId).Visit__c;   
                            }
                        }
                        ContentDocumentLinkList.add(newCd);
                        ContentDocumentLinkList.add(newCd1);
                    }
                }
            }
        }
        
        if(!ContentDocumentLinkList.isEmpty()){
            insert ContentDocumentLinkList;
            returnVal = true;
        }
        return returnVal;
    }
}