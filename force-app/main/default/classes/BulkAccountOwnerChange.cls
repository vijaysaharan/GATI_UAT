public class BulkAccountOwnerChange {
    @AuraEnabled
    public static list<DatatoReturn>  csvData(list<map<string,string>> data){
        system.debug(data);
        Set<String> gatiCustomerCodes = new Set<String>();
        Map<String,Id> accountsByCustomerCode  = new Map<String,Id>();
        for(map<string,string> cusmCode : data){
            //  system.debug(cusmCode.key());
            system.debug(cusmCode.get('Gati Customer Code'));
            //  if(cusmCode.get('GATI Customer Code')!=null && cusmCode.containsKey('Gati Customer Code')){
            gatiCustomerCodes.add(cusmCode.get('Gati Customer Code'));
            System.debug('Gati Customer Code===>>'+gatiCustomerCodes);
            
        }
        System.debug('Gati Customer Code===>>'+gatiCustomerCodes);
        List<Account> accounts = [SELECT Id, Name , GATI_Customer_Code__c , OwnerId FROM Account WHERE GATI_Customer_Code__c IN :gatiCustomerCodes];
        System.debug('Check1 : ' + accounts);
        if(!accounts.isEmpty() && accounts.size()>0){
            for(Account acc : accounts){
                if(!accountsByCustomerCode.containsKey(acc.GATI_Customer_Code__c)){
                    accountsByCustomerCode.put(acc.GATI_Customer_Code__c,acc.Id);
                    System.debug('Check2 :' +acc.GATI_Customer_Code__c + acc.Id);
                }
            }
            
        }
        
        try {
            system.debug(data);
            list<SObject> objects= new list<SObject>();
            list<DatatoReturn> exception_List= new list<DatatoReturn>();
            
            for(map<string,string> row : data){                  
                SObject sobjectRecord = Schema.getGlobalDescribe().get('Account').newSObject();
                
                sobjectRecord.put('Id', accounts[0].Id);
                system.debug('Id  '+ accounts[0].Id);
                
                /*sobjectRecord.put('Name', accounts[0].Name);
system.debug('Name  '+ accounts[0].Name);*/
                
                if(row.get('Gati Customer Code')!=null && row.containsKey('Gati Customer Code')){
                    sobjectRecord.put('GATI_Customer_Code__c', row.get('Gati Customer Code')); 
                    system.debug('GATI_Customer_Code__c  '+ row.get('Gati Customer Code'));
                    //sobjectRecord.put('GATI_Customer_Code__c',accountsByCustomerCode.get(row.get('GATI_Customer_Code__c')));
                }
                
                //sobjectRecord.put('OwnerId', row.get('Account Owner'));
                //system.debug('OwnerId  '+ row.get('Account Owner'));
                
                String ownerEmail = row.get('Account Owner');
                Id ownerId = [SELECT Id FROM User WHERE Username = :ownerEmail LIMIT 1].Id;
                sobjectRecord.put('OwnerId', ownerId);
                system.debug('OwnerId  ' + ownerId);
                
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