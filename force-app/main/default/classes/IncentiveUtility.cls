public without sharing class IncentiveUtility {

    public static String getMonthName (Integer monthCount) {
        switch on monthCount {
            when 1 {
               return 'JAN'; 
            }
            when 2 {
                return 'FEB';
            }
            when 3 {
                return 'MAR';
            }
            when 4 {
                return 'APR';
            }
            when 5 {
                return 'MAY';
            }
            when 6 {
                return 'JUN';
            }
            when 7 {
                return 'JUL';
            }
            when 8 {
                return 'AUG';
            }
            when 9 {
                return 'SEP';
            }
            when 10 {
                return 'OCT';
            }
            when 11 {
                return 'NOV';
            }
            when 12 {
                return 'DEC';
            }
            when else {
                return null;
            }
        }
    }

    public static List<Sales_KRA__c> rollupCalculations (List<Sales_KRA__c> sKRAToProcess) {
        Map<String,Sales_KRA__c> keyTosKRA = new Map<String,Sales_KRA__c>();
        Map<String,String> lastYearKeyMap = new Map<String,String>();
        Map<String,String> lastMonthKeyMap = new Map<String,String>();


        Set<String> products = new Set<String>();
        Set<String> accountTypes = new Set<String>();
        Set<Id> targetUsers = new Set<Id>();
        Set<String> monthYearSet = new Set<String>();
        
        Date startDateOfFiscalYear = System.today().month() > 3 ? Date.NewInstance(System.today().year(), 4, 1) : Date.NewInstance(System.today().year() + 1, 4, 1);
		Date endDateOfFiscalYear = System.today().month() > 3 ? Date.NewInstance(System.today().year()+1,3,31) : Date.NewInstance(System.today().year(),3,31);

        if (sKRAToProcess != null && sKRAToProcess.size() > 0) {
            for (Sales_KRA__c sKRA : sKRAToProcess) {
                if (sKRA.Product__c != null) {
                    products.add(sKRA.Product__c);
                }
                if (sKRA.Account_Type__c != null) {
                    accountTypes.add(sKRA.Account_Type__c);
                }
                if (sKRA.KAM_KAE__c != null) {
                    targetUsers.add(sKRA.KAM_KAE__c);
                }
                String lastMonthRecKey;
                String lastYearRecKey;
                if (sKRA.Month_Year__c != null) {
                    monthYearSet.add(sKRA.Month_Year__c);
                    Integer currentMonth = Integer.valueOf(sKRA.Month__c);
                    Integer currentYear = Integer.valueOf(sKRA.Year__c);
                    Integer lastMonthNum =  (currentMonth - 1) > 0 ? (currentMonth - 1) : (12);
                    String  lastMonth = getMonthName(lastMonthNum);
                    Integer lastYear = currentYear - 1;
                    lastMonthRecKey = lastMonth + '-' + ( (lastMonthNum == 12) ? String.valueOf(lastYear) : String.valueOf(currentYear));
                    lastYearRecKey = getMonthName(currentMonth) + '-' + String.valueOf(lastYear);
                    monthYearSet.add(lastMonthRecKey);
                    monthYearSet.add(lastYearRecKey);
                    System.debug(lastMonthRecKey);
                }
        
                sKRA.MTD_ESS_Revenue__c = 0;
                sKRA.Ch_wt_MTD__c = 0;
                sKRA.No_of_dkt_MTD__c = 0;
                sKRA.Y_Day_Dkts__c = 0;
                sKRA.YEST_REV__c = 0;
                sKRA.LYSM_TD__c = 0;
                sKRA.MOM__c = 0;
                sKRA.LM_TD__c = 0;
                sKRA.Net_Biz__c = 0;
                sKRA.Achievement_Amount_INR__c = 0;
                sKRA.NBD_LMTD__c = 0;
                sKRA.NBDNetBiz__c = 0;
                String key = sKRA.Month_Year__c + sKRA.Product__c + sKRA.Account_Type__c + String.valueOf(sKRA.KAM_KAE__c);
                String lastMonthKey = lastMonthRecKey + sKRA.Product__c + sKRA.Account_Type__c + String.valueOf(sKRA.KAM_KAE__c);
                String lastYearKey = lastYearRecKey + sKRA.Product__c + sKRA.Account_Type__c + String.valueOf(sKRA.KAM_KAE__c);
                keyTosKRA.put(key,sKRA);
                lastYearKeyMap.put(lastYearKey, key);
                lastMonthKeyMap.put(lastMonthKey, key);
            }
        }

        List<Customer360__c> c360sToRollup = [SELECT Id,Sales_KRA__c,Month_Year__c,Zone__c,As_on_date__c,
                                              Product__c,Account_Type__c,Customer_Code__c,AccountOwner__c,Net_Biz__c,
                                              MTD__c,LM_TD__c,MOM__c,LYSM_TD__c,YEST_REV__c,Yield__c,MTD_ESS_Revenue__c,Y_Day_Dkts__c,
                                              No_of_dkt_MTD__c,Ch_wt_MTD__c,Customer_Code__r.Docket_Date__c,Customer_Code__r.Customer_Category__c,
                                              Customer_Code__r.ContractActivationDate__c,Customer_Code__r.FirstDocketBookingDate__c  
                                              FROM Customer360__c 
                                              WHERE AccountOwner__c IN :targetUsers
                                              AND Product__c IN :products
                                              AND Account_Type__c IN :accountTypes
                                              AND Month_Year__c IN: monthYearSet
                                              WITH SECURITY_ENFORCED
                                             ];

        if (c360sToRollup != null && c360sToRollup.size() > 0) {
            for (Customer360__c c360 : c360sToRollup) {
                Date sDate = System.today().month() >= 4 ? Date.newInstance(System.today().year(), 4, 1) : Date.newInstance(System.today().year() - 1, 4, 1);
                Date eDate = System.today().month() >= 4 ? Date.newInstance(System.today().year() + 1, 3, 31) : Date.newInstance(System.today().year(), 3, 31);
                //Date sDate = Date.NewInstance(c360.As_on_date__c.addMonths(-3).year(),c360.As_on_date__c.addMonths(-3).month(),1);
                //Date eDate = Date.NewInstance(c360.As_on_date__c.addMonths(1).year(),c360.As_on_date__c.addMonths(1).month(),0);
                String key = c360.Month_Year__c  + c360.Product__c + c360.Account_Type__c + c360.AccountOwner__c;
                if ( keyTosKRA.containsKey(key) ) {
                    Sales_KRA__c sKRA = keyTosKRA.get(key);
                    sKRA.MTD_ESS_Revenue__c += c360.MTD_ESS_Revenue__c!=null?c360.MTD_ESS_Revenue__c:0;
                    sKRA.Ch_wt_MTD__c += c360.Ch_wt_MTD__c!=null?c360.Ch_wt_MTD__c:0;
                    sKRA.No_of_dkt_MTD__c += c360.No_of_dkt_MTD__c!=null?c360.No_of_dkt_MTD__c:0;
                    sKRA.Y_Day_Dkts__c += c360.Y_Day_Dkts__c!=null?c360.Y_Day_Dkts__c:0;
                    sKRA.YEST_REV__c += c360.YEST_REV__c!=null?c360.YEST_REV__c:0;
                    // sKRA.LYSM_TD__c += c360.LYSM_TD__c!=null?c360.LYSM_TD__c:0;
                    sKRA.LM_TD__c += c360.LM_TD__c!=null?c360.LM_TD__c:0;
                    sKRA.Net_Biz__c += c360.Net_Biz__c!=null?c360.Net_Biz__c:0;
                    sKRA.Achievement_Amount_INR__c += c360.MTD__c!=null?c360.MTD__c:0;
                    /*Changes for calculation of NBD Net Biz And LMTD */
                    if(c360.Customer_Code__r.FirstDocketBookingDate__c != null){
                        Date filterDate = c360.Customer_Code__r.FirstDocketBookingDate__c;                    
                        if(filterDate != null && filterDate <= eDate && filterDate >= sDate && (c360?.Customer_Code__r?.Customer_Category__c != 'KEA' && c360?.Customer_Code__r?.Customer_Category__c != 'MSME')){
                            sKRA.NBDNetBiz__c += c360.MTD__c != null ? c360.MTD__c : 0;
                        }
                        if(filterDate != null && filterDate <= eDate && filterDate >= sDate && (c360?.Customer_Code__r?.Customer_Category__c != 'KEA' && c360?.Customer_Code__r?.Customer_Category__c != 'MSME')){
                            sKRA.NBD_LMTD__c += c360.LM_TD__c!=null?c360.LM_TD__c:0;
                        }
                    }
                    keyTosKRA.put(key,sKRA);
                }

                if (lastYearKeyMap.containsKey(key) && keyTosKRA.containsKey(lastYearKeyMap.get(key))) {
                    Sales_KRA__c sKRA = keyTosKRA.get(lastYearKeyMap.get(key));
                    sKRA.LYSM_TD__c += c360.LYSM_TD__c!=null?c360.LYSM_TD__c:0;
                    keyTosKRA.put(lastYearKeyMap.get(key),sKRA);
                }

                if (lastMonthKeyMap.containsKey(key) && keyTosKRA.containsKey(lastMonthKeyMap.get(key))) {
                    Sales_KRA__c sKRA = keyTosKRA.get(lastMonthKeyMap.get(key));
                    //sKRA.LM_TD__c += c360.MTD__c!=null?c360.MTD__c:0;
                    /*Date filterDate = c360.Customer_Code__r.FirstDocketBookingDate__c;
                    if(filterDate != null && filterDate <= eDate && filterDate >= sDate && (c360?.Customer_Code__r?.Customer_Category__c != 'KEA' && c360?.Customer_Code__r?.Customer_Category__c != 'MSME')){
                        sKRA.NBD_LMTD__c += c360.MTD__c!=null?c360.MTD__c:0;
                    }*/
                    keyTosKRA.put(lastMonthKeyMap.get(key),sKRA);
                }
            }
        }

        if (!keyTosKRA.isEmpty()) {
            return keyTosKRA.values();
        } else {
            return null;
        }
    }

    public static List<Customer360__c> updateAccountOwner (List<Customer360__c> customer360sToProcess) {
        Set<Id> accountIds = new Set<Id>();
        if (customer360sToProcess != null && customer360sToProcess.size() > 0) {
            for (Customer360__c customer360 : customer360sToProcess) {
                accountIds.add(customer360.Customer_Code__c);
            }
        }

        Map<Id,Account> accountList;
        if (accountIds != null && accountIds.size() > 0) {
            accountList = new Map<Id,Account>([SELECT ID, OwnerId FROM ACCOUNT WHERE ID IN :accountIds]);
        }

        List<Customer360__c> listToReturn = new List<Customer360__c>();
        if (customer360sToProcess != null && customer360sToProcess.size() > 0 && accountList != null) {
            for (Customer360__c customer360 : customer360sToProcess) {
                if (accountList.containsKey(customer360.Customer_Code__c) && accountList.get(customer360.Customer_Code__c).OwnerId != customer360.AccountOwner__c) {
                    customer360.AccountOwner__c = accountList.get(customer360.Customer_Code__c).OwnerId;
                    listToReturn.add(customer360);
                }
            }
        }

        return listToReturn;
    }

    public static List<Incentive__c> incentivePercentage (List<Incentive__c> incentiveToUpdate){
        Set<Id> userIds = new Set<Id>();
        for (Incentive__c incentive : incentiveToUpdate) {
            userIds.add(incentive.SalesExecutive__c);
        }
        Map<Id,User> userMap = new Map<Id,User>([SELECT Type__c FROM USER WHERE ID =: userIds]);

        for (Incentive__c incentive : incentiveToUpdate) {
            System.debug('incentive.AchievementPercentage__c-->' + incentive.AchievementPercentage__c);
            System.debug('incentive.AccountType__c-->' + incentive.AccountType__c);
            System.debug('System.today-->' + System.today());
            incentive.BaseIncentivePercentage__c = 0;
            List<IncentivePlan__mdt> appliedIncentive = new List<IncentivePlan__mdt>();
            appliedIncentive = [SELECT Incentive__c FROM IncentivePlan__mdt  
                                WHERE  EndDate__c >= :System.today() 
                                AND StartDate__c <= :System.today()
                                AND AccountType__c = :incentive.AccountType__c
                                AND Role__c = :userMap.get(incentive.SalesExecutive__c).Type__c
                                AND Max__c >= :incentive.AchievementPercentage__c
                                AND Min__c <= :incentive.AchievementPercentage__c
            ];
            if (appliedIncentive.size() == 0) {
                appliedIncentive = [SELECT Incentive__c FROM IncentivePlan__mdt  
                                    WHERE  EndDate__c >= :System.today() 
                                    AND StartDate__c <= :System.today()
                                    AND AccountType__c = :incentive.AccountType__c
                                    AND Role__c = :userMap.get(incentive.SalesExecutive__c).Type__c
                                    AND Max__c = null
                                    AND Min__c <= :incentive.AchievementPercentage__c
                ]; 
            }
 
            if (appliedIncentive.size() > 0) {
                incentive.BaseIncentivePercentage__c = appliedIncentive[0].Incentive__c;
            }
        }

        return incentiveToUpdate;
    }

    public static List<Incentive__c> updateQuarterIncentive(List<Incentive__c> incentiveToUpdate) {
        Set<String> quarterKey = new Set<String>();
        // Map<String, Decimal> targetMap = new Map<String, Decimal>();
        Map<String, Decimal> achievementMap = new Map<String, Decimal>();
        for (Incentive__c incentive : incentiveToUpdate) {
            quarterKey.add(incentive.QuarterKey__c);
        }

        List<Customer360__c> salesList = [SELECT QuarterKey__c,Net_Biz__c
                                        FROM Customer360__c 
                                        WHERE QuarterKey__c IN:quarterKey
                                        WITH SECURITY_ENFORCED
        ];

        if (salesList != null && salesList.size() > 0) {
            for (Customer360__c sales : salesList) {
                // if ( targetMap.containsKey(sales.QuarterKey__c) && sales.Target__c != null) {
                //     targetMap.put(sales.QuarterKey__c, targetMap.get(sales.QuarterKey__c) + sales.Target__c);
                // } else if ( sales.Target__c != null ) {
                //     targetMap.put(sales.QuarterKey__c, sales.Target__c);
                // }

                if ( achievementMap.containsKey(sales.QuarterKey__c) && sales.Net_Biz__c != null) {
                    achievementMap.put(sales.QuarterKey__c, achievementMap.get(sales.QuarterKey__c) + sales.Net_Biz__c);
                } else if ( sales.Net_Biz__c != null ) {
                    achievementMap.put(sales.QuarterKey__c, sales.Net_Biz__c);
                }
            }
        }

        for (Incentive__c incentive : incentiveToUpdate) {
            // if (targetMap.containsKey(incentive.QuarterKey__c)) {
            //     incentive.Target__c = targetMap.get(incentive.QuarterKey__c);
            // }

            if (achievementMap.containsKey(incentive.QuarterKey__c)) {
                incentive.Achievement__c = achievementMap.get(incentive.QuarterKey__c);
            }
        }

        return incentiveToUpdate;
    }

    public static List<Incentive__c> updateQuarterSummaryOnIncentive(List<Incentive__c> incentiveToUpdate) {
        Set<String> yieldKeys = new Set<String>();
        Set<Id> salesExecutives = new Set<Id>();
        Map<String,String> codeToOwner = new Map<String,String>();
        Map<String,Incentive__c> keyToIncentive = new Map<String,Incentive__c>();
        for (Incentive__c incentive : incentiveToUpdate) {
            incentive.CYTQRevenue242__c = 0;
            incentive.CYTQEssRevenue242__c = 0;
            incentive.CYTQChWt242__c = 0;
            incentive.LYTQRevenue242__c = 0;
            incentive.LYTQEssRevenue242__c = 0;
            incentive.LYTQChWt242__c = 0;
            incentive.TQRevenue212223__c = 0;
            incentive.TQEssRevenue212223__c = 0;
            incentive.TQChWt212223__c = 0;
            incentive.LQRevenue212223__c = 0;
            incentive.LQEssRevenue212223__c = 0;
            incentive.LQChWt212223__c = 0;
            salesExecutives.add(incentive.SalesExecutive__c);
            keyToIncentive.put(incentive.QuarterKey__c, incentive);
            yieldKeys.add(incentive.QuarterYear__c + incentive.AccountType__c);
        }

        List<Account> accountData = [SELECT OwnerId,GATI_Customer_Code__c FROM ACCOUNT WHERE OwnerId IN :salesExecutives WITH SECURITY_ENFORCED];
        if (accountData != null && accountData.size() > 0) {
            for (Account acc : accountData) {
                codeToOwner.put(acc.GATI_Customer_Code__c, acc.OwnerId);
            }
        }

        System.debug(yieldKeys);
        List<QuarterSummary__c> quarterSummaryData = [SELECT Id, CustomerCode__c, ESSRevenue__c, ChWt__c, 
                                    Product__c,QuarterKey__c,NextQuarterKey__c,NextYearQuarterKey__c,
                                    Revenue__c
                                    FROM QuarterSummary__c 
                                    WHERE (QuarterKey__c IN :yieldKeys
                                    OR NextQuarterKey__c IN :yieldKeys
                                    OR NextYearQuarterKey__c IN :yieldKeys)
                                    AND CustomerCode__c IN :codeToOwner.keySet()
                                    WITH SECURITY_ENFORCED
        ];

        if (quarterSummaryData != null && quarterSummaryData.size() > 0) {
            for (QuarterSummary__c quarterSummary : quarterSummaryData) {
                String key = quarterSummary.QuarterKey__c + codeToOwner.get(quarterSummary.CustomerCode__c);
                String keyNextQuarter = quarterSummary.NextQuarterKey__c + codeToOwner.get(quarterSummary.CustomerCode__c);
                String keyNextYearQuarter = quarterSummary.NextYearQuarterKey__c + codeToOwner.get(quarterSummary.CustomerCode__c);
                System.debug(key);
                if ( keyToIncentive.containsKey(key) && (quarterSummary.Product__c == '21' || quarterSummary.Product__c == '22' || quarterSummary.Product__c == '23')) {
                    keyToIncentive.get(key).TQRevenue212223__c  += quarterSummary.Revenue__c;
                    keyToIncentive.get(key).TQEssRevenue212223__c += quarterSummary.ESSRevenue__c;
                    keyToIncentive.get(key).TQChWt212223__c += quarterSummary.ChWt__c;
                }

                if ( keyToIncentive.containsKey(key) && (quarterSummary.Product__c == '2' || quarterSummary.Product__c == '24' || quarterSummary.Product__c == '84')) {
                    keyToIncentive.get(key).CYTQRevenue242__c += quarterSummary.Revenue__c;
                    keyToIncentive.get(key).CYTQEssRevenue242__c += quarterSummary.ESSRevenue__c;
                    keyToIncentive.get(key).CYTQChWt242__c += quarterSummary.ChWt__c;
                }

                if ( keyToIncentive.containsKey(keyNextQuarter) && (quarterSummary.Product__c == '21' || quarterSummary.Product__c == '22' || quarterSummary.Product__c == '23')) {
                    keyToIncentive.get(keyNextQuarter).LQRevenue212223__c += quarterSummary.Revenue__c;
                    keyToIncentive.get(keyNextQuarter).LQEssRevenue212223__c += quarterSummary.ESSRevenue__c;
                    keyToIncentive.get(keyNextQuarter).LQChWt212223__c += quarterSummary.ChWt__c;
                }

                if ( keyToIncentive.containsKey(keyNextYearQuarter) && (quarterSummary.Product__c == '2' || quarterSummary.Product__c == '24' || quarterSummary.Product__c == '84')) {
                    keyToIncentive.get(keyNextYearQuarter).LYTQRevenue242__c += quarterSummary.Revenue__c;
                    keyToIncentive.get(keyNextYearQuarter).LYTQEssRevenue242__c += quarterSummary.ESSRevenue__c;
                    keyToIncentive.get(keyNextYearQuarter).LYTQChWt242__c += quarterSummary.ChWt__c;
                }
            }
        }

        return keyToIncentive.values();
    }

    public static List<Incentive__c> updateNBDOnIncentive(List<Incentive__c> incentiveToUpdate) {
        Set<String> quarterKeys = new Set<String>();
        Map<String,Incentive__c> quarterKeyToIncentive = new Map<String,Incentive__c>();
        for (Incentive__c incentive : incentiveToUpdate) {
            incentive.NBDStrategicCount__c = 0;
            incentive.NBDMSMECount__c = 0;
            quarterKeys.add(incentive.QuarterKey__c); 
            quarterKeyToIncentive.put(incentive.QuarterKey__c, incentive); 
        }
        List<Account> accountToCount = [SELECT Id,QuarterKey__c,CreatedById,Customer_Category__c 
                                        FROM Account 
                                        WHERE QuarterKey__c  IN: quarterKeys
                                        AND RecordType.Name='Contract'
                                        WITH SECURITY_ENFORCED
        ];

        if (accountToCount != null && accountToCount.size() > 0) {
            for (Account acc : accountToCount) {
                if ( quarterKeyToIncentive.containsKey(acc.QuarterKey__c) && acc.Customer_Category__c == 'Strategic') {
                    quarterKeyToIncentive.get(acc.QuarterKey__c).NBDStrategicCount__c += 1; 
                }

                if ( quarterKeyToIncentive.containsKey(acc.QuarterKey__c) && acc.Customer_Category__c == 'MSME') {
                    quarterKeyToIncentive.get(acc.QuarterKey__c).NBDMSMECount__c += 1; 
                }
            }
        }  
        
        return quarterKeyToIncentive.values();
    }

    public static List<Incentive__c> updateDSOOnIncentive(List<Incentive__c> incentiveToUpdate) {
        Set<String> dsoKeys = new Set<String>();
        Set<Id> salesExecutives = new Set<Id>();
        Map<String,String> codeToOwner = new Map<String,String>();
        Map<String,Incentive__c> keyToIncentive = new Map<String,Incentive__c>();
        for (Incentive__c incentive : incentiveToUpdate) {
            incentive.CumulativeNetRevenue__c = 0;
            incentive.NetOS__c = 0;
            salesExecutives.add(incentive.SalesExecutive__c);
            keyToIncentive.put(incentive.QuarterKey__c, incentive);
            dsoKeys.add(incentive.QuarterYear__c + incentive.AccountType__c);
        }

        List<Account> accountData = [SELECT OwnerId,GATI_Customer_Code__c FROM ACCOUNT WHERE OwnerId IN :salesExecutives WITH SECURITY_ENFORCED];
        if (accountData != null && accountData.size() > 0) {
            for (Account acc : accountData) {
                codeToOwner.put(acc.GATI_Customer_Code__c, acc.OwnerId);
            }
        }

        List<DSO__c> dsoData = [SELECT Id, CustomerCode__c, QuarterKey__c,
                                    NetOS__c, CumulativeNetRevenue__c
                                    FROM DSO__c 
                                    WHERE QuarterKey__c IN :dsoKeys
                                    AND CustomerCode__c IN :codeToOwner.keySet()
                                    WITH SECURITY_ENFORCED
        ];

        if (dsoData != null && dsoData.size() > 0) {
            for (DSO__c dso : dsoData) {
                String key = dso.QuarterKey__c + codeToOwner.get(dso.CustomerCode__c);
                if ( keyToIncentive.containsKey(key)) {
                    keyToIncentive.get(key).CumulativeNetRevenue__c += dso.CumulativeNetRevenue__c;
                    keyToIncentive.get(key).NetOS__c += dso.NetOS__c;
                }
            }
        }

        return keyToIncentive.values();
    }

    public static List<Incentive__c> updateRetailOutstanding(List<Incentive__c> incentiveToUpdate){
        Set<String> retailOutstandingKeys = new Set<String>();
        Set<Id> salesExecutives = new Set<Id>();
        Map<String,String> codeToOwner = new Map<String,String>();
        Map<String,Incentive__c> keyToIncentive = new Map<String,Incentive__c>();
        for (Incentive__c incentive : incentiveToUpdate) {
            incentive.RetailOutstanding__c = 0;
            salesExecutives.add(incentive.SalesExecutive__c);
            keyToIncentive.put(incentive.QuarterKey__c, incentive);
            retailOutstandingKeys.add(incentive.QuarterYear__c + incentive.AccountType__c);
        }

        List<Account> accountData = [SELECT OwnerId,GATI_Customer_Code__c FROM ACCOUNT WHERE OwnerId IN :salesExecutives WITH SECURITY_ENFORCED];
        if (accountData != null && accountData.size() > 0) {
            for (Account acc : accountData) {
                codeToOwner.put(acc.GATI_Customer_Code__c, acc.OwnerId);
            }
        }

        List<RetailOutStanding__c> retailOutstandingData = [SELECT Id, QuarterKey__c,
                                    Outstanding__c,CustomerCode__c
                                    FROM RetailOutStanding__c
                                    WHERE QuarterKey__c IN :retailOutstandingKeys
                                    AND CustomerCode__c IN :codeToOwner.keySet()
                                    WITH SECURITY_ENFORCED
        ];

        if (retailOutstandingData != null && retailOutstandingData.size() > 0) {
            for (RetailOutStanding__c retailOutstanding : retailOutstandingData) {
                String key = retailOutstanding.QuarterKey__c + codeToOwner.get(retailOutstanding.CustomerCode__c);
                if ( keyToIncentive.containsKey(key)) {
                    keyToIncentive.get(key).RetailOutstanding__c += retailOutstanding.Outstanding__c;
                }
            }
        }

        return keyToIncentive.values();
    }
}