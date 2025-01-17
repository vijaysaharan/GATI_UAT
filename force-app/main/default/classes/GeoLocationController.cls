public with sharing class GeoLocationController {

    @AuraEnabled
    public static Map<String,Boolean> checkForOwnerAndInOrOut(Id recordId){
        Map<String,Boolean> resultMap = New Map<String,Boolean>();
        try {
            Customer_Connect__c event = [select id,CreatedById, Check_In_Location__Latitude__s, Check_In_Location__Longitude__s from Customer_Connect__c where Id = :recordId];
            if(event.CreatedById == UserInfo.getUserId()){
                resultMap.put('OWNER_CHECK',true);
            }else{
                resultMap.put('OWNER_CHECK',false);
            }
            if(event.Check_In_Location__Latitude__s != null){
                resultMap.put('LOCATION_CHECK',true);
            }else{
                resultMap.put('LOCATION_CHECK',false);
            }
            return resultMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static Boolean checkForOwner(Id recordId){
        Boolean returnValue = false;
        If(recordId != null){
         	Customer_Connect__c event = [select id,CreatedById, Check_In_Location__Latitude__s, Check_In_Location__Longitude__s from Customer_Connect__c where Id = :recordId];
            If(event.CreatedById == UserInfo.getUserId()){
                returnValue = true;
            }   
        }
        System.debug('----->'+returnValue);
        return returnValue;
    } 
    
    @auraEnabled
    public static GeoLocationWrapper CheckGeoLocation(Id recordId) {
        String objName = recordId.getSObjectType().getDescribe().getName();
        GeoLocationWrapper geoLocWrap = new GeoLocationWrapper(recordId);
        
        if(objName == 'Customer_Connect__c'){
            Customer_Connect__c event = [select id, Check_In_Location__Latitude__s, Check_In_Location__Longitude__s from Customer_Connect__c where Id = :recordId];
            if (event.Check_In_Location__Latitude__s != NULL && event.Check_In_Location__Longitude__s != NULL) {
                geoLocWrap.isAlreadyCaptured = true;
                return geoLocWrap;
            } else {
                return geoLocWrap;
            }
            
        }
        
        return null;
    }
    
    @auraEnabled
    public static GeoLocationWrapper CheckGeoLocationCheckOut(Id recordId) {
        String objName = recordId.getSObjectType().getDescribe().getName();
        GeoLocationWrapper geoLocWrap = new GeoLocationWrapper(recordId);
        
        // For Customer_Connect__c 
        if(objName == 'Customer_Connect__c'){
            Customer_Connect__c event = [select id, Check_Out_Location__Latitude__s, Check_Out_Location__Longitude__s from Customer_Connect__c where Id = :recordId];
            if (event.Check_Out_Location__Latitude__s != NULL && event.Check_Out_Location__Longitude__s != NULL) {
                geoLocWrap.isAlreadyCaptured = true;
                return geoLocWrap;
            } else {
                return geoLocWrap;
            }
            
        }
        
        return null;
    }
    
    
    @auraEnabled
    public static UpdateGeoLocationWrapper UpdateCheckInLocationCheckOut(Id recordId, Decimal latitude, Decimal longitude,String Accompanied,Id AccompaniedWith,String KeyDiscussion, String ClosureRemarks) {
        UpdateGeoLocationWrapper upGeoLocWrap = new UpdateGeoLocationWrapper(recordId);
        upGeoLocWrap.message = System.Label.Check_In_Default;
        upGeoLocWrap.isSuccess = false;
        String objName = recordId.getSObjectType().getDescribe().getName();
        
        // Updating Geolocation for Event
        if (objName == 'Customer_Connect__c') {
            Customer_Connect__c event = [SELECT Id,Visit_Start_Date__c,OwnerId,Visit__c,Check_Out_Location__Latitude__s FROM Customer_Connect__c WHERE Id =: recordId];
            If(event.Check_Out_Location__Latitude__s == null){
                event.Check_Out_Location__Latitude__s = latitude;
                event.Check_Out_Location__Longitude__s = longitude;
                event.Check_Out_Time__c = Datetime.now();
                event.Check_Out_Address__c = GoogleApiApex.parseJSONResponse(latitude, longitude);
                event.Accompanied__c = Accompanied;
                if(AccompaniedWith != null){
                 	event.AcompaniedWith__c = AccompaniedWith;   
                }
                event.Key_Discussion_Description__c = KeyDiscussion;
                event.Closure_Remarks__c = ClosureRemarks;
                List<Visit__c> visitDataList = [SELECT Id,Visit_End_DateTime__c FROM Visit__c WHERE Id =: event.Visit__c]; 
                try{
                    if(visitDataList != null && visitDataList.size() > 0 && visitDataList[0].Visit_End_DateTime__c == null){
                        update as system event;
                        upGeoLocWrap.isSuccess = true;
                        upGeoLocWrap.message = System.Label.Check_Out_Success;
                        createExpenseFromCustomerConnect(recordId,AccompaniedWith);
                    }
                    else{
                        upGeoLocWrap.message = 'You can not completing the check-out process because you end the current visit without check-out.';
                    }
                }catch(Exception ex){ upGeoLocWrap.isSuccess = false;  upGeoLocWrap.message = System.Label.Check_Out_Error + ' ' + ex.getMessage();
                                     System.Debug('Event Checkin failed');                
                                    }
            }
        }
        
        return upGeoLocWrap;
    }
    
    @auraEnabled
    public static UpdateGeoLocationWrapper UpdateCheckInLocation(Id recordId, Decimal latitude, Decimal longitude) {
        UpdateGeoLocationWrapper upGeoLocWrap = new UpdateGeoLocationWrapper(recordId);
        upGeoLocWrap.message = System.Label.Check_In_Default;
        upGeoLocWrap.isSuccess = false;
        String objName = recordId.getSObjectType().getDescribe().getName();
        
        // Updating Geolocation for Event
        if (objName == 'Customer_Connect__c') {
            Customer_Connect__c event = [SELECT Id,Visit_Start_Date__c,OwnerId,Customer_Code__c,Lead__c,Check_In_Location__Latitude__s FROM Customer_Connect__c WHERE Id =: recordId];
            If(event.Check_In_Location__Latitude__s == null){
                event.Check_In_Location__Latitude__s = latitude;
                event.Check_In_Location__Longitude__s = longitude;
                event.Check_In_time__c = Datetime.now();
                if(!Test.isRunningTest()){
                    event.Check_In_Address__c = GoogleApiApex.parseJSONResponse(latitude, longitude);   
                }
                try{
                    Date currDate = Date.newInstance(event.Visit_Start_Date__c.year(), event.Visit_Start_Date__c.month(), event.Visit_Start_Date__c.day());
                    List<Visit__c> visitData = [Select Id,Mode__c,Source_Address__c,Employee_Name__c,Visit_Start_DateTime__c,Visit_End_DateTime__c,Visit_Date__c,Source_Geo_Coordinate__Latitude__s,Source_Geo_Coordinate__Longitude__s From Visit__c Where Visit_Date__c =:currDate And Employee_Name__c =:event.OwnerId And Visit_End_DateTime__c = null limit 1];
                    if(visitData != null && visitData.size() > 0){
                        event.Visit__c = visitData[0].Id;
                        update as system event;
                        upGeoLocWrap.isSuccess = true;
                        upGeoLocWrap.message = System.Label.Check_In_Success;                
                        if(event.Customer_Code__c != null){
                            updateAccountLocation(recordId);  
                        }
                        if(event.Lead__c != null){
                            updateLeadLocation(recordId);
                        }
                    }
                    else{
                        upGeoLocWrap.message = 'Please start the visit before completing the check-in process.';
                    }
                }catch(Exception ex){ upGeoLocWrap.isSuccess = false;  upGeoLocWrap.message = System.Label.Check_In_Error + ' ' + ex.getMessage();
                                     System.Debug('Event Checkin failed');                
                                    }
            }
        }
        return upGeoLocWrap;
    }
    
    //Wrapper for Capturing geo-location
    public class GeoLocationWrapper {
        @AuraEnabled public Boolean isAlreadyCaptured;
        @AuraEnabled public Id recordId;
        public GeoLocationWrapper(Id recordId) {
            this.recordId = recordId;
            isAlreadyCaptured = false;
        }
    }
    
    //Wrapper for Updating geo-location
    public class UpdateGeoLocationWrapper {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
        @AuraEnabled public Id recordId;
        public UpdateGeoLocationWrapper(Id recordId) {
            this.recordId = recordId;           
        }
    }
    
    @future(callout=true)
    public static void createExpenseFromCustomerConnect(Id customerId,Id AccompaniedWith){
        Integer index = 0;
        Expense__c exp = new Expense__c();
        exp.RecordTypeId = Schema.SObjectType.Expense__c.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        Customer_Connect__c currCustomer = [SELECT Id,Visit__c,Accompanied__c,Check_In_Address__c, Name,Visit_Start_Date__c,OwnerId,Visit_Date__c, CreatedDate,Check_In_Location__Latitude__s, Check_In_Location__Longitude__s,Check_In_Time__c,Check_Out_Time__c,Check_Out_Location__Longitude__s,Check_Out_Location__Latitude__s,Customer_Code__r.Name FROM Customer_Connect__c WHERE Id =: customerId];
        Date currDate = Date.newInstance(currCustomer.Visit_Start_Date__c.year(), currCustomer.Visit_Start_Date__c.month(), currCustomer.Visit_Start_Date__c.day());
        List<Visit__c> visitData = [Select Id,Mode__c,Source_Address__c,Employee_Name__c,Visit_Start_DateTime__c,Visit_End_DateTime__c,Visit_Date__c,Source_Geo_Coordinate__Latitude__s,Source_Geo_Coordinate__Longitude__s From Visit__c Where Visit_Date__c =:currDate And Employee_Name__c =:currCustomer.OwnerId And Visit_End_DateTime__c = null AND Id =: currCustomer.Visit__c limit 1];
        if(visitData != null && visitData.size() > 0 ){
            User uData = [Select Id,Grade__c From User Where Id =: visitData[0].Employee_Name__c];
            List<Customer_Connect__c> customerConnectList = new List<Customer_Connect__c>();
            customerConnectList = [SELECT Id, Check_In_Address__c, Name,OwnerId,Visit_Date__c, CreatedDate,Check_In_Location__Latitude__s, Check_In_Location__Longitude__s,Check_In_Time__c,Check_Out_Time__c,Check_Out_Location__Longitude__s,Check_Out_Location__Latitude__s,Customer_Code__r.Name FROM Customer_Connect__c WHERE DAY_ONLY(Visit_Start_Date__c) = :visitData[0].Visit_Date__c And Check_In_Time__c != Null  And OwnerId =:visitData[0].Employee_Name__c AND Visit__c =: visitData[0].Id Order By Check_In_Time__c]; 
            if(!customerConnectList.isEmpty())    
                index = customerConnectList.size()-1;
            Travel_Policy__c travelPriceData = [Select Id, Name, TwoWheelerEntitlement__c, FourWheelerEntitlement__c From Travel_Policy__c Where Name =:uData.Grade__c];
            String ToPlace = currCustomer.Check_In_Address__c;
            String FromPlace = '';
            Decimal distance = 0;
            if(index == 0){
                Decimal d = GoogleApiApex.getDistanceBetweenLatLog(visitData[0].Source_Geo_Coordinate__Latitude__s,visitData[0].Source_Geo_Coordinate__Longitude__s,currCustomer.Check_In_Location__Latitude__s,currCustomer.Check_In_Location__Longitude__s);
                
                if(d != null){
                    distance = d/1000;
                }else{
                    distance =0;
                }
                FromPlace = visitData[0].Source_Address__c;
            }
            else{
                Decimal d = GoogleApiApex.getDistanceBetweenLatLog(customerConnectList[index-1].Check_In_Location__Latitude__s,customerConnectList[index-1].Check_In_Location__Longitude__s,currCustomer.Check_In_Location__Latitude__s,currCustomer.Check_In_Location__Longitude__s);
                if(d != null){
                    distance = d/1000;
                }else{
                    distance =0;
                }
                FromPlace = customerConnectList[index-1].Check_In_Address__c;
            }
            exp.Customer_Connect__c = currCustomer.Id;
            exp.Visit__c = visitData[0].Id;
            exp.Employee_Name__c = currCustomer.OwnerId;
            exp.From_Date__c = currCustomer.Visit_Date__c;
            exp.To_Date__c = currCustomer.Visit_Date__c;
            exp.From__c = FromPlace;
            exp.To__c = ToPlace;
            exp.Distance__c = distance.setScale(2);
            exp.Mode__c = visitData[0].Mode__c;
            exp.Accompanied__c = currCustomer.Accompanied__c;
            if(exp.Mode__c == 'Two wheeler'){
                exp.Amount__c = ((exp.Distance__c)*(travelPriceData.TwoWheelerEntitlement__c)).setScale(2);
            }
            else if(exp.Mode__c == 'Four wheeler'){
                exp.Amount__c = ((exp.Distance__c)*(travelPriceData.FourWheelerEntitlement__c)).setScale(2);
            }
            else{
                exp.Amount__c = 0;
            }
            exp.Accepted_Amount__c = exp.Amount__c;
            if(currCustomer.Accompanied__c == 'Yes' && AccompaniedWith != null){
                exp.Distance__c = 0;
                exp.Amount__c = 0;
                exp.Accompanied_With__c = AccompaniedWith;
            }
            List<Expense__c> checkPoint = [Select Id From Expense__c Where Customer_Connect__c =:exp.Customer_Connect__c AND Visit__c =:exp.Visit__c AND Customer_Connect__r.Check_In_Location__Latitude__s =:currCustomer.Check_In_Location__Latitude__s];
            If(checkPoint != null && checkPoint.size()>0){
                System.debug('Duplicate Expense!!!!!');
            }else{
				insert exp;                
            }
        }
    }
    
    public static void updateAccountLocation(Id recordId){
        Customer_Connect__c cusRec = [SELECT Id,Owner.Name,Check_In_Address__c, Name,Visit_Start_Date__c,OwnerId,Visit_Date__c, CreatedDate,Check_In_Location__Latitude__s, Check_In_Location__Longitude__s,Check_In_Time__c,Customer_Code__c,Customer_Code__r.Name FROM Customer_Connect__c WHERE Id =: recordId];
        Account acc = [Select Id,Geolocation_Address__Latitude__s,Geolocation_Address__Longitude__s,Address__c,Last_Visit_Date__c,Last_Visited_By__c From Account Where Id =:cusRec.Customer_Code__c];
        System.debug('cusRec.Check_In_Address__c'+cusRec.Check_In_Address__c);
        if(acc.Geolocation_Address__Latitude__s == null && acc.Geolocation_Address__Longitude__s == null && acc.Address__c == null){
            acc.Last_Visit_Date__c =cusRec.Visit_Start_Date__c.date();
            acc.Geolocation_Address__Latitude__s = cusRec.Check_In_Location__Latitude__s;
            acc.Geolocation_Address__Longitude__s = cusRec.Check_In_Location__Longitude__s;
            acc.Address__c = cusRec.Check_In_Address__c;
            acc.Last_Visited_By__c = cusRec.Owner.Name;
        }
        else{
            acc.Last_Visit_Date__c = cusRec.Visit_Start_Date__c.date();
            acc.Last_Visited_By__c = cusRec.Owner.Name;
        }
        update acc;
    }
    
    public static void updateLeadLocation(Id recordId){
        Customer_Connect__c cusRec = [SELECT Id,Check_In_Address__c,Owner.Name,Lead__c, Name,Visit_Start_Date__c,OwnerId,Visit_Date__c, CreatedDate,Check_In_Location__Latitude__s, Check_In_Location__Longitude__s,Check_In_Time__c,Customer_Code__c,Customer_Code__r.Name FROM Customer_Connect__c WHERE Id =: recordId];
        Lead acc = [Select Id,Geolocation_Address__Latitude__s,Geolocation_Address__Longitude__s,Address__c,Last_Visit_Date__c,Last_Visited_By__c From Lead Where Id =:cusRec.Lead__c];
        System.debug('acc.Geolocation_Address__Latitude__s'+acc.Geolocation_Address__Latitude__s);
        if(acc.Geolocation_Address__Latitude__s == null && acc.Geolocation_Address__Longitude__s == null && acc.Address__c == null){
            acc.Last_Visit_Date__c = cusRec.Visit_Start_Date__c.date();
            acc.Geolocation_Address__Latitude__s = cusRec.Check_In_Location__Latitude__s;
            acc.Geolocation_Address__Longitude__s = cusRec.Check_In_Location__Longitude__s;
            acc.Address__c = cusRec.Check_In_Address__c;
            acc.Last_Visited_By__c = cusRec.Owner.Name;
        }
        else{
            acc.Last_Visit_Date__c = cusRec.Visit_Start_Date__c.date();
            acc.Last_Visited_By__c = cusRec.Owner.Name;
        }
        System.debug('cusRec.Visit_Start_Date__c.date()'+cusRec.Visit_Start_Date__c.date());
        update acc;
    }
    
}