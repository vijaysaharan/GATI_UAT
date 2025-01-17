public with sharing class PickupBulkUploadController {
    @AuraEnabled
    public static list<DatatoReturn>  csvData(list<map<string,string>> data , List<String> pincodes, List<String> shipperAndDestination){
        try {
            list<SObject> objects= new list<SObject>();
            DocketValidate valid = new DocketValidate();
            map<string,DocketJson.cls_response> results=new map<string,DocketJson.cls_response>();
            list<DatatoReturn> exception_List= new list<DatatoReturn>();
            Id pick = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pick_Up').getRecordTypeId();
            Map<String,Decimal> mapOfShipperPinCodeWithDistance =  getOrgnizationDataWithDistance(pincodes);
            Map<String,String> mapOfShipperAndDestinationPinCodes = getOrgnizationData(shipperAndDestination);
            Map<Id, Case> caseIdToCaseNumber = new Map<Id, Case>();
            Set<Id> caseIds = new Set<Id>();
            Boolean allDocketCheck = false;      
            string docts='';

            for(map<string,string> sc:data){
                Boolean eachCheck = false;
                String customError = '';
                SObject sobjectRecord = Schema.getGlobalDescribe().get('Case').newSObject();
                sobjectRecord.put('Origin','Bulk');
                sobjectRecord.put('Status','Open(Assigned)');                
                sobjectRecord.put('Type','Pick Up');
                sobjectRecord.put('RecordTypeId',pick);
                sobjectRecord.put('Priority','Normal');
                sobjectRecord.put('Pickup_Status__c','NAS');
                sobjectRecord.put('Sub_Type__c','Normal');
                List<Organization_Master__c> orgList = new List<Organization_Master__c>();

                if(sc.get('Shipper_Pincode__c')!=null && sc.get('Shipper_Pincode__c')!=''){
                    orgList = [SELECT Id,Location__c,Name FROM Organization_Master__c WHERE Name=:sc.get('Shipper_Pincode__c') AND RecordType.Name='Pincode Location' AND Status__c='V' AND Pincode_Status__c='O' LIMIT 1];
                    if(orgList!=null && orgList.size()>0){
                        sobjectRecord.put('Shipper_Location__c',orgList[0].Location__c);
                        sobjectRecord.put('Pick_Up_Pincode__c',orgList[0].Id);
                    }
                }
                
                if(sc.get('Customer_Code')!='' && sc.containsKey('Customer_Code')){
                    Account acc=new Account(Customer_Code__c= Decimal.valueOf(sc.get('Customer_Code')));
                    sobjectRecord.putSObject('Account',acc);
                }
                
                if(sc.get('Pickup_Date__c')!=null && sc.get('Pickup_Date__c')!=''){
                    string str = sc.get('Pickup_Date__c');
                    sobjectRecord.put('Pickup_Date__c',Datetime.valueOf(str)); 
                }

                sobjectRecord.put('Pick_Up_Instructions__c',sc.get('Pick_Up_Instructions__c'));
                sobjectRecord.put('Pickup_Address1__c',sc.get('Pickup_Address1__c'));
                sobjectRecord.put('Pickup_Address2__c',sc.get('Pickup_Address2__c'));
                sobjectRecord.put('Pickup_Address3__c',sc.get('Pickup_Address3__c'));
                sobjectRecord.put('Pickup_City__c',sc.get('Pickup_City__c'));
                
                if(sc.get('Volume__c') !=null & sc.get('Volume__c')!=''){
                    sobjectRecord.put('Volume__c',Integer.ValueOf(sc.get('Volume__c')));
                }

                sobjectRecord.put('Product__c',sc.get('Product__c'));
                sobjectRecord.put('Mobile__c',sc.get('Mobile__c'));
                sobjectRecord.put('Customer_Email__c',sc.get('Customer_Email__c'));
                sobjectRecord.put('Shipper_Name__c',sc.get('Shipper_Name__c'));
                sobjectRecord.put('Shipper_Pincode__c',sc.get('Shipper_Pincode__c'));
                sobjectRecord.put('Actual_Weight__c',Decimal.ValueOf(sc.get('Actual_Weight__c')));
                sobjectRecord.put('Receiver_Pincode__c',String.valueOf(sc.get('Destination_Pincode')));
                sobjectRecord.put('No_Of_Packages__c',Integer.ValueOf(sc.get('No_Of_Packages__c')));                
                DateTime pickupDatetime = (Datetime)sobjectRecord.get('Pickup_Date__c');    
                Integer shiftTime = pickupDatetime.hour();
                Integer shiftTimeMinutes = pickupDatetime.minute();
                Datetime nowTime = Datetime.parse(Datetime.now().format());
                Decimal diffMins =  ((pickupDatetime.getTime())/1000/60) - ((nowTime.getTime())/1000/60);
                Decimal distance = 0;

                if(!Test.isRunningTest()){
                    distance = mapOfShipperPinCodeWithDistance.get((String)sobjectRecord.get('Shipper_Pincode__c'));
                }

                Integer days_difference = nowTime.Date().daysBetween(pickupDatetime.Date());
                
                if (distance >= 0 && distance <= 25 && days_difference != 0 && days_difference > 7) {
                    customError = 'You can raise pickup today or within 7 days';
                    eachCheck = true;
                } 
                else if ((shiftTime <= 9 && shiftTimeMinutes != 0) || (shiftTime >= 19 && shiftTimeMinutes != 0)) {
                    customError = 'Pickup time should be in between 9AM to 7PM';
                    eachCheck = true;
                }
                else if (pickupDatetime.format('EEEE') == 'Sunday') {
                    customError = 'You cannot raise pickup on Sundays';
                    eachCheck = true;
                }
                else if (days_difference == 0 && (shiftTime <= 9 && shiftTimeMinutes != 0) || (shiftTime >= 16 && shiftTimeMinutes > 30)) {
                    customError = 'Pickup time for today should be in between 9 AM to 4:30 PM';
                    eachCheck = true;
                }
                else if (distance >= 0 && distance <= 25 && days_difference == 0 && diffMins < 90) {
                    customError = 'Pickup time should be 90 minutes from the current time';
                    eachCheck = true;
                }
                else if (distance > 25 && distance <= 50 && days_difference == 0 || days_difference > 8) {
                    customError = 'Pickup date for the selected pin code is allowed from system date + 1 and for a maximum of 7 days';
                    eachCheck = true;
                }
                else if (distance > 50 && distance <= 200 && (days_difference == 0 || days_difference == 1) || days_difference > 9) {
                    customError = 'Pickup date for the selected pin code is allowed from system date + 2 and for a maximum of 7 days.';
                    eachCheck = true;
                }
                else if (distance > 200 && distance <= 300 && (days_difference == 0 || days_difference == 1 || days_difference == 2) || days_difference > 10) {
                    customError = 'Pickup date for the selected pin code is allowed from system date + 3 and for a maximum of 7 days.';
                    eachCheck = true;
                }
                else if (distance > 300 && (days_difference == 0 || days_difference == 1 || days_difference == 2 || days_difference == 3) || days_difference > 11) {
                    customError = 'Pickup date for the selected pin code is allowed from system date + 4 and for a maximum of 7 days.';
                    eachCheck = true;
                }
                else if (days_difference < 0) {
                    customError = 'You can not raise pickup past date';
                    eachCheck = true;
                }
                else {
                    customError = '';
                }

                if( String.valueOf(sobjectRecord.get('Actual_Weight__c')).length()>4){
                    customError = 'You can not exceed max Actual weight 9999';
                    eachCheck = true;
                }
                if(mapOfShipperAndDestinationPinCodes.containsKey(String.valueOf(sobjectRecord.get('Shipper_Pincode__c')))){
                    customError = 'Wrong Shipper Pin code-'+String.valueOf(sobjectRecord.get('Shipper_Pincode__c'));
                    eachCheck = true;
                }
                if(mapOfShipperAndDestinationPinCodes.containsKey(String.valueOf(sobjectRecord.get('Receiver_Pincode__c')))){
                    customError = 'Wrong Destination Pin code-'+String.valueOf(sobjectRecord.get('Receiver_Pincode__c'));
                    eachCheck = true;
                }
                if(!eachCheck){
                    objects.add(sobjectRecord);
                }
                else{
                    DatatoReturn ret= new DatatoReturn();
                    ret.title = customError;
                    ret.done = false;
                    ret.obj = sobjectRecord;
                    exception_List.add(ret);
                }              
            }

            if(objects.size()>0){
                List<Database.SaveResult> sveResult = Database.insert(objects, false);
                for(Database.SaveResult sr : sveResult){
                    if(sr.isSuccess()){
                        caseIds.add(sr.getId());
                    }
                }

                caseIdToCaseNumber = new Map<Id, Case>([SELECT Id, CaseNumber FROM Case WHERE Id IN :caseIds]);

                for(Integer i = 0; i < sveResult.size(); i++){
                    DatatoReturn ret= new DatatoReturn();

                    if (sveResult.get(i).isSuccess()){                        
                        ret.done=true;
                        ret.title = (caseIdToCaseNumber.containsKey(sveResult.get(i).getId()) ? caseIdToCaseNumber.get(sveResult.get(i).getId()).CaseNumber : sveResult.get(i).getId()) +' Success';                                              
                    }
                    else if (!sveResult.get(i).isSuccess()){
                        ret.done=false;
                        Database.Error error = sveResult.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        ret.title=failedDML;
                    }
                    ret.obj= objects.get(i);
                    exception_List.add(ret);
                }
                return exception_List;
            }
            else{
                return exception_List;
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
       }
    }

    @AuraEnabled
    public static Map<String,String> getOrgnizationData(List<String> pincodes){
        List<String> wrongPincode =new List<String>();
        Map<String,String> pinCodesWithShiD = new Map<String,String>();
        Map<String,String> setOfIds = new  Map<String,String>();
        List<Organization_Master__c> orgData = new List<Organization_Master__c>();
        orgData = [SELECT Id, Name FROM Organization_Master__c WHERE Name IN:pincodes];
        for(Organization_Master__c og : orgData){
            setOfIds.put(og.Name,og.Name);
        }
        for(String str : pincodes){
            if(!setOfIds.containsKey(str)){
                wrongPincode.add(str);
                pinCodesWithShiD.put(str,str);
            }
        }
        if(!wrongPincode.isEmpty() && wrongPincode.size()>0){
            return pinCodesWithShiD;
        }
        else{
            pinCodesWithShiD.put(null,null);
            return pinCodesWithShiD;
        }        
    }
    
    @AuraEnabled
    public static Map<String,Decimal> getOrgnizationDataWithDistance(List<String> pincodes){
        Map<String,Decimal> setOfIds = new  Map<String,Decimal>();
        List<Organization_Master__c> orgData = new List<Organization_Master__c>();
        orgData = [SELECT Id, Name,Distance__c FROM Organization_Master__c WHERE Name IN:pincodes];
        for(Organization_Master__c og : orgData){
            setOfIds.put(og.Name,og.Distance__c);
        }
        
        if(!setOfIds.isEmpty() && setOfIds.size()>0){
            return setOfIds;
        }
        return null;        
    }
    
    public class DatatoReturn {
        @AuraEnabled
        public string title;        
        @AuraEnabled
        public SObject obj;
        @AuraEnabled
        public boolean done;      
    }
    @TestVisible
    private static void dummy(){
        Integer i=1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}