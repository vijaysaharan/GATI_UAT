public  with sharing class visitStartAndEndController {
    @AuraEnabled
    public static Travel_Policy__c getTravelPriceForCurrentUser(){
        try{
            Id currUserId =  UserInfo.getUserId();
            User uData = [Select Id,Grade__c From User Where Id =: currUserId];
            List<Travel_Policy__c> travelPriceData = [Select Id, Name, TwoWheelerEntitlement__c, FourWheelerEntitlement__c From Travel_Policy__c Where Name =:uData.Grade__c];
            if(travelPriceData != Null && travelPriceData.size()>0){
                return travelPriceData[0];
            }
            return new Travel_Policy__c();
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String checkForButton(){
        String returnString = 'visitStart';
        Date currentDate = System.today();
        Id currentUser = UserInfo.getUserId();
        List<Visit__c> visitRec = new List<Visit__c> ();
        try{
            visitRec = [Select Id,Visit_End_DateTime__c,Visit_Start_DateTime__c,Visit_Date__c,	Source_Geo_Coordinate__Latitude__s,Source_Geo_Coordinate__Longitude__s,Destination_Geo_Coordinate__Latitude__s,Destination_Geo_Coordinate__Longitude__s	 From Visit__c Where (DAY_ONLY(CreatedDate) = :currentDate) And OwnerId =:currentUser And Visit_End_DateTime__c = null];
            if(visitRec.size() > 0){
                returnString = visitRec[0].Id;
            }
            return returnString;
        }
        catch(Exception e){
            return returnString;
        }
    }
    
    @AuraEnabled
    public static Visit__c createTodaysVisit(Visit__c visitData){
        Visit__c returnData = new Visit__c();
        visitData.Visit_Date__c = System.today();
        visitData.Employee_Name__c = UserInfo.getUserId();
        visitData.Visit_Start_DateTime__c = System.now();
        if(visitData.Source_Geo_Coordinate__Latitude__s != null && visitData.Source_Geo_Coordinate__Longitude__s != null){
            String geoCheckInAddress1 = GoogleApiApex.parseJSONResponse(visitData.Source_Geo_Coordinate__Latitude__s,visitData.Source_Geo_Coordinate__Longitude__s);
            visitData.Source_Address__c = geoCheckInAddress1;
            insert visitData;
            returnData = [Select Id, Name From Visit__c Where Id =: visitData.Id];
        }
        return returnData;
    }
    
    @AuraEnabled
    public static Boolean endTodaysVisit(Decimal latitude,Decimal longitude,String recordId, String EndPoint, String EndingNote){
        Boolean returnVal = false;
        Visit__c visitData = [Select Id,Visit_End_DateTime__c,Visit_Start_DateTime__c,Visit_Date__c,Source_Geo_Coordinate__Latitude__s,Source_Geo_Coordinate__Longitude__s,Destination_Geo_Coordinate__Latitude__s,Destination_Geo_Coordinate__Longitude__s	 From Visit__c Where Id =:recordId And Visit_End_DateTime__c = null];
        visitData.Destination_Geo_Coordinate__Latitude__s = latitude;
        visitData.Destination_Geo_Coordinate__Longitude__s = longitude;
        visitData.End_Point__c = EndPoint;
        visitData.Ending_Note__c = EndingNote;
        visitData.Visit_End_DateTime__c = System.now();
        if(visitData.Destination_Geo_Coordinate__Latitude__s != null && visitData.Destination_Geo_Coordinate__Longitude__s != null){
            String geoCheckInAddress1 = GoogleApiApex.parseJSONResponse(visitData.Destination_Geo_Coordinate__Latitude__s,visitData.Destination_Geo_Coordinate__Longitude__s);
            visitData.Destination_Address__c = geoCheckInAddress1;
            List<Customer_Connect__c> cusConnectListForCheck = [SELECT Id,Check_Out_Time__c FROM Customer_Connect__c WHERE Check_Out_Time__c = NULL AND Check_In_Time__c !=null AND Visit__c =: recordId];
            if(cusConnectListForCheck != null && cusConnectListForCheck.size() > 0){
            	System.debug('Without Check Out All Customer Connect You Can Not End The Visit.');    
            }else{
                update visitData;
                returnVal = true;
                List<Customer_Connect__c> cusConnectList = [SELECT Id FROM Customer_Connect__c WHERE Visit__c =: recordId];
                if(cusConnectList != null && cusConnectList.size() > 0)
                    createLastExpense(recordId);
            }
        }
        return returnVal;
    }
    
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
    public static ReturnVisitCustomer getCustomerConnectData(){
        
        ReturnVisitCustomer returnData = new ReturnVisitCustomer();
        String currLogInUser = UserInfo.getUserId();
        List<Visit__c> visitData = [Select Id,Name,Source_Address__c,Employee_Name__c,Visit_Start_DateTime__c,Visit_End_DateTime__c,Visit_Date__c,Source_Geo_Coordinate__Latitude__s,Source_Geo_Coordinate__Longitude__s From Visit__c Where DAY_ONLY(CreatedDate) = :System.today() And OwnerId =:currLogInUser];
        
        if(visitData.size() > 0){
            returnData.visitRec = visitData;
        }
        List<Customer_Connect__c> cusRecList = [SELECT Id,Lead__r.Name, Check_In_Address__c, Name,OwnerId,Visit_Date__c, CreatedDate,Check_In_Location__Latitude__s, Check_In_Location__Longitude__s,Check_In_Time__c,Visit_Start_Date__c,Check_Out_Time__c,Check_Out_Location__Longitude__s,Check_Out_Location__Latitude__s,Customer_Code__r.Name FROM Customer_Connect__c WHERE DAY_ONLY(Visit_Start_Date__c) = :System.today() And OwnerId =:currLogInUser Order By Visit_Start_Date__c];
        if(cusRecList != null){
            returnData.CustomerRec = cusRecList;
        }
        
        System.debug(returnData);
        return returnData;
    }
    
    @future(callout=true)
    private static void createLastExpense(Id visitId){
        Expense__c exp = new Expense__c();
        exp.RecordTypeId = Schema.SObjectType.Expense__c.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        Visit__c visitData = [Select Id,Destination_Geo_Coordinate__Latitude__s,Destination_Geo_Coordinate__Longitude__s,Mode__c,Destination_Address__c,Source_Address__c,Employee_Name__c,Visit_Start_DateTime__c,Visit_End_DateTime__c,Visit_Date__c,Source_Geo_Coordinate__Latitude__s,Source_Geo_Coordinate__Longitude__s From Visit__c Where Id =: visitId limit 1];
        User uData = [Select Id,Grade__c From User Where Id =: visitData.Employee_Name__c];
        List<Customer_Connect__c> customerConnectList = [SELECT Id,Accompanied__c,AcompaniedWith__c,Check_Out_Address__c, Check_In_Address__c, Name,OwnerId,Visit_Date__c, CreatedDate,Check_In_Location__Latitude__s, Check_In_Location__Longitude__s,Check_In_Time__c,Check_Out_Time__c,Check_Out_Location__Longitude__s,Check_Out_Location__Latitude__s,Customer_Code__r.Name FROM Customer_Connect__c WHERE DAY_ONLY(Visit_Start_Date__c) = :visitData.Visit_Date__c And Check_In_Time__c != Null And OwnerId =:visitData.Employee_Name__c  AND Visit__c =: visitData.Id  Order By Check_In_Time__c];
        if(customerConnectList != null && customerConnectList.size() > 0){
            List<Travel_Policy__c> travelPriceData = [Select Id, Name, TwoWheelerEntitlement__c, FourWheelerEntitlement__c From Travel_Policy__c Where Name =:uData.Grade__c];
            Integer customerConnectListSize = customerConnectList.size();
            String ToPlace = visitData.Destination_Address__c;
            String FromPlace = customerConnectList[customerConnectListSize-1].Check_In_Address__c;
            Decimal distance = 0;
            Decimal d = GoogleApiApex.getDistanceBetweenLatLog(customerConnectList[customerConnectListSize-1].Check_In_Location__Latitude__s,customerConnectList[customerConnectListSize-1].Check_In_Location__Longitude__s,visitData.Destination_Geo_Coordinate__Latitude__s,visitData.Destination_Geo_Coordinate__Longitude__s);
            
            if(d != null){
                distance = d/1000;
            }else{
                distance =0;
            }
            
            exp.Customer_Connect__c = customerConnectList[customerConnectListSize-1].Id;
            exp.Visit__c = visitData.Id;
            exp.Employee_Name__c = visitData.Employee_Name__c;
            exp.From_Date__c = customerConnectList[customerConnectListSize-1].Visit_Date__c;
            exp.To_Date__c = customerConnectList[customerConnectListSize-1].Visit_Date__c;
            exp.From__c = FromPlace;
            exp.To__c = ToPlace;
            exp.Distance__c = distance.setScale(2);
            exp.Mode__c = visitData.Mode__c;
            if(exp.Mode__c == 'Two wheeler' && !travelPriceData.isEmpty()){
                exp.Amount__c = ((exp.Distance__c)*(travelPriceData[0].TwoWheelerEntitlement__c)).setScale(2);
            }
            else if(exp.Mode__c == 'Four wheeler' && !travelPriceData.isEmpty()){
                exp.Amount__c = ((exp.Distance__c)*(travelPriceData[0].FourWheelerEntitlement__c)).setScale(2);
            }
            else{
                exp.Amount__c = 0;
            }
            exp.Accepted_Amount__c = exp.Amount__c;
            exp.Accompanied__c = customerConnectList[customerConnectListSize-1].Accompanied__c;
            if(customerConnectList[customerConnectListSize-1].Accompanied__c == 'Yes'){
                exp.Distance__c = 0;
                exp.Amount__c = 0;
                exp.Accompanied_With__c = customerConnectList[customerConnectListSize-1].AcompaniedWith__c;
            }
            insert exp; 
        }
    }
    
    public class ReturnVisitCustomer {
        @AuraEnabled public List<Visit__c> visitRec;
        @AuraEnabled public List<Customer_Connect__c> CustomerRec;
    }
}