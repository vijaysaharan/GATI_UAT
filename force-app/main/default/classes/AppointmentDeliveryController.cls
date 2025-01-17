public with sharing class AppointmentDeliveryController {
    @AuraEnabled
    public static list<DatatoReturn>  csvData(list<map<string,string>> data){
        Set<String> caseNumbers = new Set<String>();
        Map<String,Id> caseNumberWithCaseIds  = new Map<String,Id>();
        for(map<string,string> casen:data){
            if(casen.get('Docket_Number__c')!=null && casen.containsKey('Docket_Number__c')){
                caseNumbers.add(casen.get('Docket_Number__c'));
            }
        }
        System.debug('-- checking case number--'+caseNumbers);

        List<Case> caseList = [SELECT Id,CaseNumber,Docket_Number__c FROM Case WHERE Docket_Number__c IN:caseNumbers AND RecordType.Name='Service Request' AND Type='Appointment Delivery' AND Status='Open(Assigned)'];
        if(!caseList.isEmpty() && caseList.size()>0){
            for(Case cc:caseList){
                if(!caseNumberWithCaseIds.containsKey(cc.Docket_Number__c)){
                    caseNumberWithCaseIds.put(cc.Docket_Number__c,cc.Id);
                }
            }
        }

        try {
            system.debug(data);
            list<SObject> objects= new list<SObject>();
            list<DatatoReturn> exception_List= new list<DatatoReturn>();
                                      
            list<string> dockets=new list<string>();      
            for(map<string,string> sc:data){                  
                SObject sobjectRecord = Schema.getGlobalDescribe().get('Case').newSObject();  
                sobjectRecord.put('Id',caseNumberWithCaseIds.get(sc.get('Docket_Number__c'))); 
                sobjectRecord.put('Docket_Number__c',sc.get('Docket_Number__c'));   
                sobjectRecord.put('Appointment_Contact_Number__c',sc.get('Appointment_Contact_Number__c'));
                sobjectRecord.put('Appointment_Contact_Person__c',sc.get('Appointment_Contact_Person__c'));                
                sobjectRecord.put('Appointment_Date__c',DateTime.valueOf(sc.get('Appointment_Date__c')));
                sobjectRecord.put('Approval_Status__c','Y');
                sobjectRecord.put('Approver_Remarks__c','Appointment Fixed');
                objects.add(sobjectRecord);
            }     
            
            if(objects.size()>0)
            {
                system.debug(objects);
                Database.SaveResult[] sveResult = Database.update(objects, false);
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