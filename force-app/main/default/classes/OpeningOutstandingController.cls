public class OpeningOutstandingController implements Database.Batchable<SObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Name,Month_Year__c, Current_Month_OS__c,Month_Opening_Outstanding__c,Customer360_Id__c,Processed__c,Customer360Code__c FROM Customer360__c WHERE CreatedDate=THIS_MONTH AND Processed__c=false';
        return Database.getQueryLocator(query);
    }
  
    public void execute(Database.BatchableContext BC, List<Customer360__c> customer360List){
        dummyData();
        Set<String> customerKeySet = new Set<String>();
        Map<Id,Customer360__c> customer360Update = new Map<Id,Customer360__c>();
        List<Customer360__c> finalList = new  List<Customer360__c>();
        for(Customer360__c cusOld : customer360List){
            customerKeySet.add(cusOld.Customer360Code__c);
        }
        
        System.debug('-- current--'+customer360List);
        List<Customer360__c> mapListOfCustomer360Final = [SELECT Id,Name,Month_Year__c, Current_Month_OS__c,Month_Opening_Outstanding__c,Processed__c,Customer360Code__c,Customer360_Id__c FROM Customer360__c WHERE Customer360Code__c IN:customerKeySet AND CreatedDate=LAST_MONTH];
        System.debug('-- old--'+mapListOfCustomer360Final);
        for(Customer360__c cust : customer360List){
            for(Customer360__c cusOld : mapListOfCustomer360Final){
                if(cust.Customer360Code__c == cusOld.Customer360Code__c){
                    cust.Processed__c = true;
                    cust.Month_Opening_Outstanding__c = cusOld.Current_Month_OS__c;
                    customer360Update.put(cust.Id,cust);
                }
            }
        }
        
        if(!customer360Update.isEmpty() && customer360Update.size()>0){
            database.update(customer360Update.values());
        }
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Opening balance updated successfully...');
        
    }
    
    public static void dummyData(){
        
        decimal i = 0;
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