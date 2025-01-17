public with sharing class CreateSalesKRAForLastMonthBatch implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    /*
    public Date currentMonthDate;

    public CreateSalesKRAForLastMonthBatch(Date currDate){
        this.currentMonthDate = currDate;
    }
    */
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, KAM_KAE__c, Product__c, Zone__c, Account_Type__c, Month__c, Year__c, UniqueKey__c FROM Sales_KRA__c';
        /*
        if(currentMonthDate != null){
            query += ' WHERE Month__c = \'' + currentMonthDate.addMonths(-1).month() + '\'';
            query += ' AND Year__c = \'' + currentMonthDate.addMonths(-1).year() + '\'';
        }
        else{
            query += ' WHERE Month__c = \'' + System.today().addMonths(-1).month() + '\'';
            query += ' AND Year__c = \'' + System.today().addMonths(-1).year() + '\'';
        }
        */
        query += ' WHERE Month__c = \'' + System.today().addMonths(-1).month() + '\'';
        query += ' AND Year__c = \'' + System.today().addMonths(-1).year() + '\'';
        query += ' AND Achievement_Amount_INR__c != 0 AND Achievement_Amount_INR__c != null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Sales_KRA__c> scope){
        Map<String, Sales_KRA__c> uniqueKeyToSalesKRA = new Map<String, Sales_KRA__c>();
        Map<String, Sales_KRA__c> existingSalesKRAMap = new Map<String, Sales_KRA__c>();
        List<Sales_KRA__c> salesKRAToInsert = new List<Sales_KRA__c>();
        
        for(Sales_KRA__c sKRA : scope){
            Date nextMonthDate = (Date.newInstance(Integer.valueOf(sKRA.Year__c), Integer.valueOf(sKRA.Month__c), 1)).addMonths(1);
            String key = sKRA.KAM_KAE__c + sKRA.Account_Type__c + sKRA.Product__c + nextMonthDate.month() + nextMonthDate.year();
            Sales_KRA__c newsKRA = new Sales_KRA__c();
            newsKRA.KAM_KAE__c = sKRA.KAM_KAE__c;
            newsKRA.Product__c = sKRA.Product__c;
            newsKRA.Account_Type__c = sKRA.Account_Type__c;
            newsKRA.Month__c = String.valueOf(nextMonthDate.month());
            newsKRA.Year__c = String.valueOf(nextMonthDate.year());
            newsKRA.Zone__c = sKRA.Zone__c;
            newsKRA.Unique__c = key;
            newsKRA.OwnerId = sKRA.KAM_KAE__c;
            newsKRA.Target__c = 0;
            uniqueKeyToSalesKRA.put(key, newSKRA);
        }

        List<Sales_KRA__c> existingSalesKRAs = [SELECT Id,Unique__c 
                                                FROM Sales_KRA__c 
                                                WHERE Unique__c IN: uniqueKeyToSalesKRA.keySet()
                                               ];

        if(existingSalesKRAs != null && existingSalesKRAs.size() > 0){
            for(Sales_KRA__c sKRA : existingSalesKRAs){
                existingSalesKRAMap.put(sKRA.Unique__c, sKRA);
            }
        }

        for(String key : uniqueKeyToSalesKRA.keySet()){
            if(!existingSalesKRAMap.containsKey(key)){
                salesKRAToInsert.add(uniqueKeyToSalesKRA.get(key));
            }
        }

        if(salesKRAToInsert != null && salesKRAToInsert.size() > 0){
            insert salesKRAToInsert;
        }
    }

    public void finish(Database.BatchableContext BC){
        //Batch Finish
    }

    public void execute(SchedulableContext SC){
        database.executeBatch(new CreateSalesKRAForLastMonthBatch(),2000);
    }
}