public with sharing class SalesKRARollupUpdateBatch implements Database.Batchable<SObject>{
    public Boolean runMonthly = true;
    
    public Database.QueryLocator start (Database.BatchableContext bc) {        
        if (runMonthly) {
            Integer currentDay = System.today().day();
            Integer monthToConsider = System.today().month();
            Integer yearToConsider = System.today().year();
            if(currentDay == 1){
                monthToConsider = System.today().addDays(-1).month();
                yearToConsider = System.today().addDays(-1).year();
            }
            return Database.getQueryLocator([SELECT Id,Achievement_Amount_INR__c,KAM_KAE__c,Product__c,
                                             Account_Type__c,Month_Year__c,Zone__c,Net_Biz__c,LM_TD__c,MOM__c,
                                             LYSM_TD__c,YEST_REV__c,Y_Day_Dkts__c,No_of_dkt_MTD__c,Ch_wt_MTD__c,
                                             Month__c,Year__c,Achievement_Percentage__c,KAM_KAE__r.Type__c,
                                             NBD_LMTD__c,NBDNetBiz__c
                                             FROM Sales_KRA__c 
                                             WHERE Month__c = :String.valueOf(monthToConsider)
                                             AND Year__c = :String.valueOf(yearToConsider)
                                            ]);
        } 
        else {
            return Database.getQueryLocator([SELECT Id,Achievement_Amount_INR__c,KAM_KAE__c,Product__c,
                                             Account_Type__c,Month_Year__c,Zone__c,Net_Biz__c,LM_TD__c,MOM__c,
                                             LYSM_TD__c,YEST_REV__c,Y_Day_Dkts__c,No_of_dkt_MTD__c,Ch_wt_MTD__c,
                                             Month__c,Year__c,Achievement_Percentage__c,KAM_KAE__r.Type__c
                                             FROM Sales_KRA__c
                                            ]);
        }
        
    }
    
    public void execute (Database.BatchableContext bc, List<Sales_KRA__c> kraRecords) {
        List<Sales_KRA__c> recordToOperate = IncentiveUtility.rollupCalculations(kraRecords);
        if (recordToOperate != null) {
            update recordToOperate;
        }
    }
    
    public void finish (Database.BatchableContext bc) {
        IncentiveRollupBatch i = new IncentiveRollupBatch();
        Database.executeBatch(i,5);
    }
}