public without sharing class IncentiveRollupBatch implements Database.Batchable<SObject>{
    private Boolean runQuarterly = true;
    public IncentiveRollupBatch() {}
    public IncentiveRollupBatch(Boolean runQuarterlyTemp){
        runQuarterly = runQuarterlyTemp;
    }
    public Database.QueryLocator start (Database.BatchableContext bc) {
        String currentYear = getCurrentYear();
        if (runQuarterly) {
            return Database.getQueryLocator([SELECT Id, AccountType__c, SalesExecutive__c, 
                                            Quarter__c, Year__c,  
                                            Target__c, Achievement__c, NBDIncentive__c, QuarterYear__c,
                                            AchievementPercentage__c, Product__c, QuarterKey__c, 
                                            NBDMSMECount__c, NBDStrategicCount__c, 
                                            NBD__c, BaseIncentivePercentage__c, SalesExecutive__r.Type__c,
                                            CumulativeNetRevenue__c,
                                            NetOS__c,CYTQRevenue242__c,CYTQEssRevenue242__c,
                                            CYTQChWt242__c,LYTQRevenue242__c,LYTQEssRevenue242__c,
                                            LYTQChWt242__c,TQRevenue212223__c,TQEssRevenue212223__c,
                                            TQChWt212223__c,LQRevenue212223__c,LQEssRevenue212223__c,
                                            LQChWt212223__c
                                            FROM Incentive__c 
                                            WHERE Quarter__c =: getCurrentQuarter(System.today().month())
                                            AND Year__c =:currentYear
            ]);
        } else {
            return Database.getQueryLocator([SELECT Id, AccountType__c, SalesExecutive__c, 
                                            Quarter__c, Year__c,  
                                            Target__c, Achievement__c, NBDIncentive__c, QuarterYear__c,
                                            AchievementPercentage__c, Product__c, QuarterKey__c, 
                                            NBDMSMECount__c, NBDStrategicCount__c, 
                                            NBD__c, BaseIncentivePercentage__c, SalesExecutive__r.Type__c,
                                            CumulativeNetRevenue__c,
                                            NetOS__c,CYTQRevenue242__c,CYTQEssRevenue242__c,
                                            CYTQChWt242__c,LYTQRevenue242__c,LYTQEssRevenue242__c,
                                            LYTQChWt242__c,TQRevenue212223__c,TQEssRevenue212223__c,
                                            TQChWt212223__c,LQRevenue212223__c,LQEssRevenue212223__c,
                                            LQChWt212223__c
                                            FROM Incentive__c
            ]);
        }
    }
    public void execute (Database.BatchableContext bc, List<Incentive__c> incentiveToProcess) {
        if (incentiveToProcess != null && incentiveToProcess.size() > 0){
            incentiveToProcess = IncentiveUtility.updateQuarterIncentive(incentiveToProcess);
            List<FormulaRecalcResult> results = Formula.recalculateFormulas(incentiveToProcess);
            incentiveToProcess = IncentiveUtility.incentivePercentage(incentiveToProcess);
            incentiveToProcess = IncentiveUtility.updateQuarterSummaryOnIncentive(incentiveToProcess);
            incentiveToProcess = IncentiveUtility.updateNBDOnIncentive(incentiveToProcess);
            incentiveToProcess = IncentiveUtility.updateDSOOnIncentive(incentiveToProcess);
            incentiveToProcess = IncentiveUtility.updateRetailOutstanding(incentiveToProcess);
            update incentiveToProcess;
        }
    }
    public void finish (Database.BatchableContext bc) {
        if (!Test.isRunningTest()) {
            database.executeBatch(new UpdateLastTradeDateCustomerDashboard(),1);
        }
    }

    @TestVisible
    private String getCurrentQuarter(Integer month) {
        switch on month {
            when 1 {
                return 'Q4';
            }
            when 2 {
                return 'Q4';
            }
            when 3 {
                return 'Q4';
            }
            when 4 {
                return 'Q1';
            }
            when 5 {
                return 'Q1';
            }
            when 6 {
                return 'Q1';
            }
            when 7 {
                return 'Q2';
            }
            when 8 {
                return 'Q2';
            }
            when 9 {
                return 'Q2';
            }
            when 10 {
                return 'Q3';
            }
            when 11 {
                return 'Q3';
            }
            when 12 {
                return 'Q3';
            }
            when else {
                return null;
            }
        }
    }

    private String getCurrentYear(){
        if (System.today().month() < 4) {
            return String.valueOf(System.today().year()- 1) + '-' + String.valueOf(System.today().year());
        } else {
            return String.valueOf(System.today().year()) + '-' + String.valueOf(System.today().year() + 1);
        }
    } 
}