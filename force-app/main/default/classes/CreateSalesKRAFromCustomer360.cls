public class CreateSalesKRAFromCustomer360 implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    //public Date startDate;
    //public Date endDate;
    public Set<String> insertedSalesKRA;
    /*
    public CreateSalesKRAFromCustomer360(Date sDate, Date eDate){
        this.startDate = sDate;
        this.endDate = eDate;
    }
    */
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        insertedSalesKRA = new Set<String>();
        /*
        if(startDate != null && endDate != null){
            query = 'Select Id,As_on_date__c,Account_Type__c, AccountOwner__c, AccountOwner__r.Zone__c, Customer_Code__r.OwnerId, Customer_Code__r.Customer_Category__c, Customer_Code__r.Owner.Zone__c,Product__c From Customer360__c Where CreatedDate >=: startDate AND CreatedDate <=: endDate And Product__c IN (\'STANDARD\', \'AIR EXPRESS\', \'SUR EXPRESS\', \'MVATS\') AND Customer_Code__r.Customer_Category__c IN (\'Retail\',\'MSME\',\'KEA\',\'Strategic\')';
        }
        else{
            query = 'Select Id,As_on_date__c,Account_Type__c, AccountOwner__c, AccountOwner__r.Zone__c, Customer_Code__r.OwnerId, Customer_Code__r.Customer_Category__c, Customer_Code__r.Owner.Zone__c,Product__c From Customer360__c Where CreatedDate = THIS_MONTH And Product__c IN (\'STANDARD\', \'AIR EXPRESS\', \'SUR EXPRESS\', \'MVATS\')';
        }
        */
        query = 'Select Id,As_on_date__c,Account_Type__c, AccountOwner__c, AccountOwner__r.Zone__c, Customer_Code__r.OwnerId, Customer_Code__r.Customer_Category__c, Customer_Code__r.Owner.Zone__c,Product__c From Customer360__c Where CreatedDate = THIS_MONTH And Product__c IN (\'STANDARD\', \'AIR EXPRESS\', \'SUR EXPRESS\', \'MVATS\')';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Customer360__c> scope){
        Map<String, Customer360__c> uniqueKeyToCustomer360 = new Map<String, Customer360__c>();
        List<Sales_KRA__c> salesKRAToInsert = new List<Sales_KRA__c>();
        Map<String, Sales_KRA__c> uniqueKeyToSalesKRA = new Map<String, Sales_KRA__c>();
        Map<String, String> userZoneToSalesKRAZone = new Map<String, String>{
            	'North' => 'DELZ',
                'West' => 'BOMZ',
                'South' => 'BLRZ',
                'East' => 'CCUZ',
                'ALL'  => 'ALL'
                };
        
        for(Customer360__c c360 : scope){
            if(c360.Customer_Code__r.OwnerId != null){
                String key = c360.AccountOwner__c + c360.Account_Type__c + c360.Product__c + c360.As_on_date__c.month() + c360.As_on_date__c.year();
                uniqueKeyToCustomer360.put(key, c360);
            }
        }
                
        List<Sales_KRA__c> salesKRAList = [SELECT Id,UniqueKey__c,KAM_KAE__c, Account_Type__c,Zone__c,Product__c 
                                           FROM Sales_KRA__c 
                                           WHERE UniqueKey__c IN: uniqueKeyToCustomer360.keySet()
                                          ];
        
        for(Sales_KRA__c sKRA : salesKRAList){
            uniqueKeyToSalesKRA.put(sKRA.UniqueKey__c, sKRA);
        }
        
        for(Customer360__c c360 : scope){
            String key = c360.AccountOwner__c + c360.Account_Type__c + c360.Product__c + c360.As_on_date__c.month() + c360.As_on_date__c.year();
            if(c360.AccountOwner__c != null && !uniqueKeyToSalesKRA.containsKey(key) && !insertedSalesKRA.contains(key)){
                Sales_KRA__c sKRA = new Sales_KRA__c();
                sKRA.KAM_KAE__c = c360.AccountOwner__c;
                sKRA.Account_Type__c = c360.Account_Type__c;
                sKRA.Zone__c = userZoneToSalesKRAZone.get(c360.AccountOwner__r.Zone__c);
                sKRA.Product__c = c360.Product__c;
                sKRA.Month__c = String.valueOf(c360.As_on_date__c.month());
                sKRA.Year__c = String.valueOf(c360.As_on_date__c.year());
                sKRA.Target__c = 0;
                sKRA.OwnerId = c360.AccountOwner__c;
                sKRA.Unique__c = key;
                insertedSalesKRA.add(key);
                salesKRAToInsert.add(sKRA);
            }
        }
        
        if(salesKRAToInsert != null && salesKRAToInsert.size() > 0){
            insert salesKRAToInsert;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        SalesKRARollupUpdateBatch b = new SalesKRARollupUpdateBatch();
        if (!Test.isRunningTest()) {
            Database.executeBatch(b,20);
        }
    }
    
    public void execute(SchedulableContext SC){
        //database.executeBatch(new CreateSalesKRAFromCustomer360(null, null),2000);
        database.executeBatch(new CreateSalesKRAFromCustomer360(),2000);
    }
}