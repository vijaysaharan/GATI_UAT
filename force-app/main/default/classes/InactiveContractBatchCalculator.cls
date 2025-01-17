public class InactiveContractBatchCalculator implements Database.Batchable<sObject>,Schedulable, Database.Stateful{
    Public Map<Id,Date> accIdToLastTradingDate ;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<Id> accIds = new Set<Id>();
        accIdToLastTradingDate = new Map<Id,Date>();
        
        List<CustomerDashboard__c> cusData = [SELECT AccountName__c,LastTradeDate__c 
                                              FROM CustomerDashboard__c
                                              WHERE LastTradeDate__c != null
                                             ];
        if(cusData != null && cusData.size()>0 ){
            for(CustomerDashboard__c cdash : cusData){
                accIds.add(cdash.AccountName__c);
                accIdToLastTradingDate.put(cdash.AccountName__c,cdash.LastTradeDate__c);
            }
        }
        String query = 'SELECT Id,Customer_Code__c,Customer_Code__r.ParentId,MTD__c,Last_Trade_Date__c,Non_Trading_Days__c,As_on_date__c FROM Customer360__c Where (Customer_Code__c  IN: accIds OR Customer_Code__r.ParentId IN: accIds) And As_on_date__c = LAST_N_DAYS:730';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Customer360__c> scope){
        Map<Id,Decimal> contractIdTo0To30MTD = new Map<Id,Decimal>();
        Map<Id,Decimal> contractIdTo31To90MTD = new Map<Id,Decimal>();
        Map<Id,Decimal> contractIdTo91To180MTD = new Map<Id,Decimal>();
        Map<Id,Decimal> contractIdTo181To360MTD = new Map<Id,Decimal>();
        Set<Id> contractIds = new Set<Id>();
        List<CustomerDashboard__c> dashboardDataToUpdate = new List<CustomerDashboard__c>();
        for(Customer360__c cus : scope){
            Id key = null;
            if(cus.Customer_Code__r.ParentId != null){
                key = cus.Customer_Code__r.ParentId;
            }
            else{
                key = cus.Customer_Code__c;
            }
            contractIds.add(key);
            if(accIdToLastTradingDate.containsKey(key)){
                Date lastTradeDate = accIdToLastTradingDate.get(key);
                Integer NonTradingDays = lastTradeDate.daysBetween(System.today());
                Integer diffDays = cus.As_on_date__c.daysBetween(lastTradeDate);
                System.debug('NonTradingDays'+NonTradingDays);
                System.debug('diffDays '+diffDays);
                if(NonTradingDays <= 30 && diffDays >= 0 && diffDays <=365){
                    if(contractIdTo0To30MTD.containsKey(key)){
                        contractIdTo0To30MTD.put(key,(contractIdTo0To30MTD.get(key)+cus.MTD__c));
                    }
                    else{
                        contractIdTo0To30MTD.put(key,cus.MTD__c);
                    }
                }
                if(NonTradingDays > 30 && NonTradingDays <= 90 && diffDays >= 0 && diffDays <=365){
                    if(contractIdTo31To90MTD.containsKey(key)){
                        contractIdTo31To90MTD.put(key,(contractIdTo31To90MTD.get(key)+cus.MTD__c));
                    }
                    else{
                        contractIdTo31To90MTD.put(key,cus.MTD__c);
                    }
                }
                if(NonTradingDays > 90 && NonTradingDays <= 180 && diffDays >= 0 && diffDays <=365){
                    if(contractIdTo91To180MTD.containsKey(key)){
                        contractIdTo91To180MTD.put(key,(contractIdTo91To180MTD.get(key)+cus.MTD__c));
                    }
                    else{
                        contractIdTo91To180MTD.put(key,cus.MTD__c);
                    }
                }
                if(NonTradingDays > 180 && NonTradingDays <= 365 && diffDays >= 0 && diffDays <=365){
                    if(contractIdTo181To360MTD.containsKey(key)){
                        contractIdTo181To360MTD.put(key,(contractIdTo181To360MTD.get(key)+cus.MTD__c));
                    }
                    else{
                        contractIdTo181To360MTD.put(key,cus.MTD__c);
                    }
                }
            }
        }
        
        List<CustomerDashboard__c> dashboardData = [SELECT AccountName__c,X030Revenue__c,X3190Revenue__c,X91180Revenue__c,X181365Revenue__c 
                                                    FROM CustomerDashboard__c 
                                                    WHERE AccountName__c IN: contractIds
                                                    FOR UPDATE
                                                   ];
        
        if(dashboardData != null && dashboardData.size() >0) {
            for(CustomerDashboard__c cd : dashboardData){
                if(contractIdTo0To30MTD.containsKey(cd.AccountName__c)){
                    cd.X030Revenue__c += contractIdTo0To30MTD.get(cd.AccountName__c);
                }
                if(contractIdTo31To90MTD.containsKey(cd.AccountName__c)){
                    cd.X3190Revenue__c += contractIdTo31To90MTD.get(cd.AccountName__c);
                }
                if(contractIdTo91To180MTD.containsKey(cd.AccountName__c)){
                    cd.X91180Revenue__c += contractIdTo91To180MTD.get(cd.AccountName__c);
                }
                if(contractIdTo181To360MTD.containsKey(cd.AccountName__c)){
                    cd.X181365Revenue__c += contractIdTo181To360MTD.get(cd.AccountName__c);
                }
                dashboardDataToUpdate.add(cd);
            }
        }
        
        if(dashboardDataToUpdate != null && dashboardDataToUpdate.size()>0){
            update dashboardDataToUpdate;
        }
    }
    public void finish(Database.BatchableContext BC){
        //FINISHED
    }
    public void execute(SchedulableContext SC){
        database.executeBatch(new InactiveContractBatchCalculator(),2000);
    }
}