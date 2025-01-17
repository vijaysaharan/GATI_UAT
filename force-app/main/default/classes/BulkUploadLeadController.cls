public with sharing class BulkUploadLeadController {
    @AuraEnabled
    public static list<DatatoReturn>  csvData(list<map<string,string>> data){
        Set<String> postalPinCode = new Set<String>();
        Map<String,Id> organizationWithPincode  = new Map<String,Id>();
        for(map<string,string> pCode:data){
            if(pCode.get('PostalCode')!=null && pCode.containsKey('PostalCode')){
                postalPinCode.add(pCode.get('PostalCode'));
                System.debug('PostalCode===>>'+postalPinCode);
            }
        }
        
        List<Organization_Master__c> listOfOrg = [SELECT Id,Pincode__c FROM Organization_Master__c WHERE Pincode__c IN:postalPinCode AND Operational_Status__c='O' AND Status__c='V'];
        if(!listOfOrg.isEmpty() && listOfOrg.size()>0){
            for(Organization_Master__c org : listOfOrg){
                if(!organizationWithPincode.containsKey(org.Pincode__c)){
                    organizationWithPincode.put(org.Pincode__c,org.Id);
                }
            }
            
        }
        
        try {
            system.debug(data);
            list<SObject> objects= new list<SObject>();
            list<DatatoReturn> exception_List= new list<DatatoReturn>();
            
            list<string> dockets=new list<string>();      
            for(map<string,string> sc:data){                  
                SObject sobjectRecord = Schema.getGlobalDescribe().get('Lead').newSObject();
                sobjectRecord.put('Title',sc.get('Title'));                
                sobjectRecord.put('Salutation',sc.get('Title'));
                system.debug('Salutation==>'+sc.get('Title'));
                sobjectRecord.put('FirstName',sc.get('FirstName'));
                sobjectRecord.put('LastName',sc.get('LastName'));                
                sobjectRecord.put('Status',sc.get('Status'));
                sobjectRecord.put('LeadSource',sc.get('LeadSource'));
                sobjectRecord.put('Campaign_Name__c',sc.get('Campaign_Name__c'));
                sobjectRecord.put('Lead_Data__c',sc.get('Lead_Data__c'));                              
                if(sc.get('PostalCode')!=null && sc.containsKey('PostalCode')){
                    sobjectRecord.put('Lead_Assigned_OU__c',organizationWithPincode.get(sc.get('PostalCode')));
                }                                      
                sobjectRecord.put('GATI_Company_Code__c',sc.get('GATI_Company_Code__c'));
                sobjectRecord.put('Product__c',sc.get('Product__c'));
                Decimal customerPotential = Decimal.valueOf(sc.get('Customer_Potential__c'));
                sobjectRecord.put('Customer_Potential__c',customerPotential);
                sobjectRecord.put('Designation__c',sc.get('Designation__c'));
                sobjectRecord.put('Company',sc.get('Company'));
                sobjectRecord.put('Email',sc.get('Email'));
                sobjectRecord.put('Phone',sc.get('Phone'));
                sobjectRecord.put('MobilePhone',sc.get('MobilePhone'));
                sobjectRecord.put('Street',sc.get('Street'));
                sobjectRecord.put('City',sc.get('City'));
                sobjectRecord.put('State',sc.get('State'));
                sobjectRecord.put('PostalCode',sc.get('PostalCode'));
                sobjectRecord.put('Country',sc.get('Country'));
                sobjectRecord.put('Cross_Sell_CFS_Locations__c', sc.get('Cross_Sell_CFS_Locations__c'));
                sobjectRecord.put('Payment_mode__c', sc.get('Payment_mode__c'));
                sobjectRecord.put('Description', sc.get('Description'));
                sobjectRecord.put('Cross_Sell_Lead_Status__c',sc.get('Cross Sell Lead Status'));
                if(sc.get('GATI_Company_Code__c') == '104'){
                    sobjectRecord.put('Lost_Reason__c',sc.get('Lost Reason'));
                    sobjectRecord.put('Other_Reason__c',sc.get('Lost Reason'));
                }else{
                    sobjectRecord.put('Lost_Reason__c',sc.get('Lost Reason'));
                }
                sobjectRecord.put('Description__c',sc.get('Cross Sell Description'));
                sobjectRecord.put('Manually_Uploaded__c', true);
                objects.add(sobjectRecord);
                
            }     
            
            if(objects.size()>0)
            {
                system.debug(objects);
                Database.SaveResult[] sveResult = Database.insert(objects, false);
                system.debug('saveres '+sveResult);
                for(Integer i=0;i<sveResult.size();i++){
                    DatatoReturn ret= new DatatoReturn();
                    if (sveResult.get(i).isSuccess()){                        
                        ret.done=true;
                        ret.Id = sveResult.get(i).getId();
                        ret.title=sveResult.get(i).getId()+' Success';                                               
                    }
                    else if (!sveResult.get(i).isSuccess()){
                        ret.done=false;     
                        ret.Id = null;                   
                        // DML operation failed
                        Database.Error error = sveResult.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        ret.title=failedDML;
                        //failed record from the list
                        system.debug('Failed ID'+objects.get(i));
                    }
                    ret.obj= objects.get(i);
                    exception_List.add(ret);
                    system.debug(exception_List);
                }
                return exception_List;
            }
            else 
            {
                return null;
            }
        }
        catch (Exception e) {
            System.debug('exception occured '+ e.getLineNumber()+'  '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public  class DatatoReturn {
        @AuraEnabled
        public string Id; 
        @AuraEnabled
        public string title;        
        @AuraEnabled
        public SObject obj;
        @AuraEnabled
        public boolean done;      
    }
}