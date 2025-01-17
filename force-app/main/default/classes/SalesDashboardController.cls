public with sharing class SalesDashboardController {
    @AuraEnabled
    public static Map<String,Integer> getNBDCustomerData(WhereWrapper inpData){
        Date thisMonthStart = inpData.thisMonthStartDate;
        Date thisMonthEnd = inpData.thisMonthEndDate;
        Date lastMonthStart = inpData.lastMonthStartDate;
        Date lastMonthEnd = inpData.lastMonthEndDate;
        List<Id> userIds = inpData.userSelectedIds;
        List<String> zones = inpData.zoneSelectedList;
        List<String> accountTypes = inpData.accountTypesSelected;

        Map<String,Integer> returnMap = new Map<String,Integer>();

        String baseQuery = 'SELECT Count() FROM Customer_Connect__c';

        if(thisMonthEnd != null && thisMonthStart != null){
            String queryForThisMonth = baseQuery +  ' WHERE Sub_Type__c = \'NBD\' AND Visit_Date__c >=: thisMonthStart AND Visit_Date__c <=: thisMonthEnd';  
            queryForThisMonth += (userIds != null && userIds.size()>0) ? ' AND OwnerId IN: userIds' : '';
            queryForThisMonth += (zones != null && zones.size()>0) ? ' AND Zone__c IN: zones' : '';
            queryForThisMonth += (accountTypes != null && accountTypes.size()>0) ? ' AND Vertical__c IN: accountTypes' : '';
            Integer cusCountToThisMonth = Database.countQuery(queryForThisMonth);
            returnMap.put('THIS_MONTH',cusCountToThisMonth);
        }
        else{
            returnMap.put('THIS_MONTH',0);
        }
        if(lastMonthStart != null && lastMonthEnd != null){
            String queryForLastMonth = baseQuery +  ' WHERE Customer_Code__r.Docket_Date__c  = THIS_FISCAL_YEAR AND Visit_Date__c >=: lastMonthStart AND Visit_Date__c <=: lastMonthEnd';  
            queryForLastMonth += (userIds != null && userIds.size()>0) ? ' AND OwnerId IN: userIds' : '';
            queryForLastMonth += (zones != null && zones.size()>0) ? ' AND Customer_Code__r.Zone_Name__c IN: zones' : '';
            queryForLastMonth += (accountTypes != null && accountTypes.size()>0) ? ' AND Customer_Code__r.Customer_Category__c IN: accountTypes' : '';
            Integer cusCountToLastMonth = Database.countQuery(queryForLastMonth);
            returnMap.put('LAST_MONTH',cusCountToLastMonth);
        }
        else{
            returnMap.put('LAST_MONTH',0);
        }
        if(userIds != null && zones != null && accountTypes != null){
            String queryForFiscalYear = baseQuery +  ' WHERE Customer_Code__r.Docket_Date__c  = THIS_FISCAL_YEAR AND Visit_Date__c = THIS_FISCAL_YEAR';  
            queryForFiscalYear += (userIds != null && userIds.size()>0) ? ' AND OwnerId IN: userIds' : '';
            queryForFiscalYear += (zones != null && zones.size()>0) ? ' AND Customer_Code__r.Zone_Name__c IN: zones' : '';
            queryForFiscalYear += (accountTypes != null && accountTypes.size()>0) ? ' AND Customer_Code__r.Customer_Category__c IN: accountTypes' : '';
            Integer cusCountToFiscalYear = Database.countQuery(queryForFiscalYear);
            returnMap.put('FISCAL_YEAR',cusCountToFiscalYear);
        }
        else{
            returnMap.put('FISCAL_YEAR',0);
        }
        return returnMap;
    }
	
    @AuraEnabled
    public static List<MonthlyTradeDashboard__c> getTradeData(WhereWrapperForTrade whrClause){
        String sortType = whrClause.sortingMethod;
        List<Id> userIds = whrClause.userSelectedIds;
        List<String> zones = whrClause.zoneSelectedList;
        List<String> accountTypes = whrClause.accountTypesSelected;
        String monthYear = whrClause.monthYear;
        List<MonthlyTradeDashboard__c> returnList = new List<MonthlyTradeDashboard__c>();
        String queryString = 'SELECT ContractName__r.Id,ContractName__r.Name,UpDownTrade__c,ContractName__r.Contract_Number__c,RevenueMTD__c,RevenueLMTD__c,RevenueYTD__c,MoM__c FROM MonthlyTradeDashboard__c';
        if(userIds != null && zones != null && accountTypes != null){
        	queryString += (userIds != null && userIds.size()>0) ? ' WHERE ContractName__r.OwnerId IN: userIds AND' : ' WHERE';
        	queryString += (zones != null && zones.size()>0) ? ' ContractName__r.Zone_Name__c IN: zones AND' : '';
            queryString += (accountTypes != null && accountTypes.size()>0) ? ' ContractName__r.Customer_Category__c IN: accountTypes AND' : '';
            queryString += (monthYear != null && monthYear != '') ? ' MonthYear__c =: monthYear AND' : '';
        }
        queryString = queryString.trim();
        if (queryString.endsWith('AND')) {
            queryString = queryString.substring(0, queryString.length() - 3).trim();
        }
        queryString += ' ORDER BY UpDownTrade__c '+sortType+' LIMIT 10';
        System.debug('Query '+queryString);
        returnList = Database.query(queryString);
        return returnList;
    }

    @AuraEnabled
    public static Map<String,Decimal> getOpportunityClosedData(WhereWrapperForOpportunity whrClause){
        Map<String,Decimal> returnMap = new Map<String,Decimal>();
        Date thisMonthStart = whrClause.thisMonthStartDate;
        Date thisMonthEnd = whrClause.thisMonthEndDate;
        Date lastMonthStartTill = whrClause.lastMonthStartTillDate;
        Date lastMonthEndTill = whrClause.lastMonthEndTillDate;
        List<Id> userIds = whrClause.userSelectedIds;
        List<String> accountTypes = whrClause.accountTypesSelected;
        String baseQuery = 'SELECT Count(Id) num, SUM(Commited_Gati_Potentail__c) sum FROM Opportunity WHERE Opportunity_Type_Contract__c =\'New Contract\' And (LOF_CON__c LIKE \'%CON%\' OR LOF_CON__c LIKE \'%ROF%\') ';
        if(thisMonthStart != null && thisMonthEnd != null){
            String thisMonthQuery = baseQuery + ' AND Account.Contract_Activation_Date__c <=: thisMonthEnd AND Account.Contract_Activation_Date__c >=: thisMonthStart';
            thisMonthQuery += (userIds != null && userIds.size()>0) ? ' AND OwnerId IN: userIds' : '';
            thisMonthQuery += (accountTypes != null && accountTypes.size()>0) ? ' AND Account.Customer_Category__c IN: accountTypes' : '';
            List<AggregateResult> aggrigationThisMonth = Database.query(thisMonthQuery);
            returnMap.put('THIS_MONTH_MTD',(Decimal)aggrigationThisMonth[0].get('num'));
            returnMap.put('THIS_MONTH_REVENUE',(Decimal)aggrigationThisMonth[0].get('sum'));
        }
        if(lastMonthStartTill != null && lastMonthEndTill != null){
            String lastMonthQuery = baseQuery + ' AND Account.Contract_Activation_Date__c <=: lastMonthEndTill AND Account.Contract_Activation_Date__c >=: lastMonthStartTill';
            lastMonthQuery += (userIds != null && userIds.size()>0) ? ' AND OwnerId IN: userIds' : '';
            lastMonthQuery += (accountTypes != null && accountTypes.size()>0) ? ' AND Account.Customer_Category__c IN: accountTypes' : '';
            List<AggregateResult> aggrigationLastMonth = Database.query(lastMonthQuery);
            returnMap.put('LAST_MONTH_MTD',(Decimal)aggrigationLastMonth[0].get('num'));
            returnMap.put('LAST_MONTH_REVENUE',(Decimal)aggrigationLastMonth[0].get('sum'));
        }
        if(userIds != null){
            String thisYearQuery = baseQuery + ' AND Account.Contract_Activation_Date__c = THIS_FISCAL_YEAR';
            thisYearQuery += (userIds != null && userIds.size()>0) ? ' AND OwnerId IN: userIds' : '';
            thisYearQuery += (accountTypes != null && accountTypes.size()>0) ? ' AND Account.Customer_Category__c IN: accountTypes' : '';
            List<AggregateResult> aggrigationThisYear = Database.query(thisYearQuery);
            returnMap.put('THIS_YEAR_MTD',(Decimal)aggrigationThisYear[0].get('num'));
            returnMap.put('THIS_YEAR_REVENUE',(Decimal)aggrigationThisYear[0].get('sum'));
        }
        return returnMap;
    }

    @AuraEnabled
    public static Map<String, Decimal> getTargets(whereWrapperTarget whereClause){
        Map<String, Decimal> returnTargets = new Map<String, Decimal>();
        Map<String,Decimal> labelToPercentage = new Map<String, Decimal>();
        Decimal nbdTarget = 0;
        Decimal target = 0;
        Decimal totalTarget = 0;

        String month = String.valueOf(whereClause.salesKRAStartDate.month());
        String year = String.valueOf(whereClause.salesKRAStartDate.year());
        List<NBD_Targets__mdt> nbdTargetPercentage = [SELECT Label, Month__c, Year__c, Percentage__c FROM NBD_Targets__mdt WHERE Month__c = :month AND Year__c = :year];
        List<AggregateResult> accountTypesToTarget = [SELECT SUM(Target__c) Target__c,Account_Type__c 
                                                      FROM Sales_KRA__c 
                                                      WHERE Date__c >= :whereClause.salesKRAStartDate 
                                                      AND Date__c <= :whereClause.salesKRAEndDate
                                                      AND KAM_KAE__c IN :whereClause.userSelectedIds
                                                      AND Product__c IN :whereClause.productList
                                                      AND Zone__c IN :whereClause.zoneSelectedList
                                                      AND Account_Type__c IN :whereClause.accountTypes
                                                      GROUP BY Account_Type__c
                                                     ];
        if(nbdTargetPercentage != null && nbdTargetPercentage.size() > 0){
            for(NBD_Targets__mdt nbd : nbdTargetPercentage){
                labelToPercentage.put(nbd.Label, nbd.Percentage__c);
            }
        }
        if(accountTypesToTarget != null && accountTypesToTarget.size() > 0){
            for(AggregateResult ar : accountTypesToTarget){
                String accountType = (String)ar.get('Account_Type__c');
                Decimal targetValue = (Decimal)ar.get('Target__c');
                if(labelToPercentage.containsKey(accountType)){
                   nbdTarget += (targetValue * labelToPercentage.get(accountType))/100;
                   target += (targetValue * (100 - labelToPercentage.get(accountType)))/100;
                }
                else{
                    target += targetValue;
                }
            }
        }
        totalTarget = nbdTarget + target;
        returnTargets.put('Target',target);
        returnTargets.put('NBD_Target',nbdTarget);
        returnTargets.put('Total_Target',totalTarget);
        System.debug(returnTargets);
        return returnTargets;
    }

    public class WhereWrapper{
        @AuraEnabled public Date thisMonthStartDate{get;set;}
        @AuraEnabled public Date thisMonthEndDate{get;set;}
        @AuraEnabled public Date lastMonthStartDate{get;set;}
        @AuraEnabled public Date lastMonthEndDate{get;set;}
        @AuraEnabled public List<Id> userSelectedIds{get;set;}
        @AuraEnabled public List<String> zoneSelectedList{get;set;}
        @AuraEnabled public List<String> accountTypesSelected{get;set;}
    }
    public class WhereWrapperForOpportunity{
        @AuraEnabled public Date thisMonthStartDate{get;set;}
        @AuraEnabled public Date thisMonthEndDate{get;set;}
        @AuraEnabled public Date lastMonthStartTillDate{get;set;}
        @AuraEnabled public Date lastMonthEndTillDate{get;set;}
        @AuraEnabled public List<Id> userSelectedIds{get;set;}
        @AuraEnabled public List<String> accountTypesSelected{get;set;}
    }
    public class WhereWrapperForTrade{
        @AuraEnabled public String sortingMethod{get;set;}
        @AuraEnabled public List<Id> userSelectedIds{get;set;}
        @AuraEnabled public List<String> zoneSelectedList{get;set;}
        @AuraEnabled public List<String> accountTypesSelected{get;set;}
        @AuraEnabled public String monthYear{get;set;}
    }
    public class whereWrapperTarget{
        @AuraEnabled public Date salesKRAStartDate{get;set;}
        @AuraEnabled public Date salesKRAEndDate{get;set;}
        @AuraEnabled public List<Id> userSelectedIds{get;set;}
        @AuraEnabled public List<String> zoneSelectedList{get;set;}
        @AuraEnabled public List<String> productList{get;set;}
        @AuraEnabled public List<String> accountTypes{get;set;}
    }
}