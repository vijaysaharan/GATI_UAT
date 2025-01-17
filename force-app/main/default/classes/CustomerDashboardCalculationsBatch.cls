public class CustomerDashboardCalculationsBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Date StartDate;
    public Date EndDate;
    public String Identifier;
    public String currentMonthYear;
    
    public CustomerDashboardCalculationsBatch(Date StartDate, Date EndDate, String Identifier){
        this.StartDate = StartDate;
        this.EndDate = EndDate;
        this.Identifier = Identifier;
        if(Identifier == 'MTD'){
            this.currentMonthYear = IncentiveUtility.getMonthName(StartDate.month())+'-'+StartDate.year();
        }
        else{
            this.currentMonthYear = IncentiveUtility.getMonthName(System.today().month())+'-'+System.today().year();
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query =	'SELECT Id,AccountName__c,ABSLInboundL12M__c,ABSLOutboundL12M__c,DIFOTL12M__c,DocketL12M__c,OutstandingL12M__c,RevenueL12M__c,VisitsL12M__c,VolumeL12M__c,ABSLInboundL3M__c,ABSLOutboundL3M__c,DIFOTL3M__c,DocketL3M__c,OutstandingL3M__c,RevenueL3M__c,VisitsL3M__c,VolumeL3M__c,ABSLInboundLM__c,ABSLOutboundLM__c,DIFOTLM__c,DocketLM__c,OutstandingLM__c,RevenueLM__c,VisitsLM__c,VolumeLM__c,ABSLInboundMTD__c,ABSLOutboundMTD__c,DIFOTMTD__c,DocketMTD__c,OutstandingMTD__c,RevenueMTD__c,VisitsMTD__c,VolumeMTD__c,ABSLInboundYTD__c,ABSLOutboundYTD__c,DIFOTYTD__c,DocketYTD__c,OutstandingYTD__c,RevenueYTD__c,VisitsYTD__c,VolumeYTD__c,CollectionMTD__c,CollectionLM__c,CollectionL3M__c,CollectionL12M__c,CollectionYTD__c,VisitsLMTD__c,On_time_arrival_Dockets_MTD__c, On_Time_Delivered_With_Out_Deps_MTD__c, Total_Assured_Dockets_MTD__c FROM CustomerDashboard__c';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<CustomerDashboard__c> scope){
        Set<Id> accIds = new Set<Id>();
        Map<Id,Integer> accIdToVisitCount = new Map<Id,Integer>();
        //Map<Id,Decimal> accIdToOutbound = new Map<Id,Decimal>();
        Map<Id,Decimal> accIdToDocketNumber = new Map<Id,Decimal>();
        Map<Id,Decimal> accIdToOutstanding = new Map<Id,Decimal>();
        Map<Id,Decimal> accIdToRevenue = new Map<Id,Decimal>();
        Map<Id,Decimal> accIdToVolume = new Map<Id,Decimal>();
        Map<Id,Decimal> accIdToCollection = new Map<Id,Decimal>();
        Map<Id,Decimal> accIdToRevenueLMTD = new Map<Id,Decimal>();
        Map<Id,Decimal> accIdToDocketLMTD = new Map<Id,Decimal>();
        Map<Id,Decimal> accIdToVolumnLMTD = new Map<Id,Decimal>();
        //Added for Difot And ABSL
        Map<Id,Decimal> accIdToTotalAssured = new Map<Id,Decimal>();
        Map<Id,Decimal> accIdToOnTimeDelivered = new Map<Id,Decimal>();
        Map<Id,Decimal> accIdToOnTimeArrival = new Map<Id,Decimal>();
        List<CustomerDashboard__c> dashboardListToUpdate = new List<CustomerDashboard__c>();
        List<MonthlyTradeDashboard__c> monthlyTradesToUpdate = new List<MonthlyTradeDashboard__c>();
        
        for(CustomerDashboard__c cd : scope){
            accIds.add(cd.AccountName__c);
        }

        List<MonthlyTradeDashboard__c> monthlyTrades = [SELECT Id, Name, ContractName__c, RevenueMTD__c, RevenueLMTD__c, RevenueYTD__c, 
                                                        UpDownTrade__c, MoM__c, MonthYear__c
                                                        FROM MonthlyTradeDashboard__c
                                                        WHERE MonthYear__c = :currentMonthYear
                                                        AND ContractName__c IN :accIds
                                                       ];        
        List<Customer360__c> customer360List = [SELECT Customer_Code__c,Customer_Code__r.ParentId,No_of_dkt_MTD__c,LM_TD__c,
                                                Ch_wt_MTD__c,MTD__c,DIFOT__c,ABSL_Inbound__c,ABSL_Outbound__c,Current_Month_OS__c,
                                                COLL_as_on_date__c,CYLM_No_of_Dockets__c,CYLM_Charged_Wt__c,Total_Assured_Dockets__c,
                                                ON_time_delivered_with_out_deps__c,On_time_arrival_Dockets__c  
                                                FROM Customer360__c 
                                                WHERE As_on_date__c >=: StartDate
                                                AND As_on_date__c <=: EndDate
                                                AND (Customer_Code__c IN: accIds OR Customer_Code__r.ParentId IN: accIds)
                                               ];
        List<Customer_Connect__c> customerConnectList = [SELECT Id, Customer_Code__c,Customer_Code__r.ParentId
                                                         FROM Customer_Connect__c
                                                         WHERE (Customer_Code__c IN: accIds OR Customer_Code__r.ParentId IN: accIds)
                                                         AND Visit_Date__c >=: StartDate
                                                         AND Visit_Date__c <=: EndDate
                                                        ];
        
        if(customer360List != null && customer360List.size()>0){
            for(Customer360__c cm : customer360List){
                Id key = null;
                if(cm.Customer_Code__r.ParentId != null){
                    key = cm.Customer_Code__r.ParentId;
                }
                else{
                    key = cm.Customer_Code__c;
                }
                
                /*if(cm.ABSL_Outbound__c != null){
                    if(accIdToOutbound.containsKey(key)){
                        if(accIdToOutbound.get(key) < cm.ABSL_Outbound__c){
                            accIdToOutbound.put(key,cm.ABSL_Outbound__c);   
                        }
                    }
                    else{
                        accIdToOutbound.put(key,cm.ABSL_Outbound__c);
                    } 
                }*/
                //Added for Difot And ABSL MTD
                if(cm.Total_Assured_Dockets__c != null){
                    if(accIdToTotalAssured.containsKey(key)){
                        accIdToTotalAssured.put(key,(accIdToTotalAssured.get(key)+cm.Total_Assured_Dockets__c));
                    }
                    else{
                        accIdToTotalAssured.put(key,cm.Total_Assured_Dockets__c);
                    }   
                }
                
                if(cm.On_time_arrival_Dockets__c != null){
                    if(accIdToOnTimeArrival.containsKey(key)){
                        accIdToOnTimeArrival.put(key,(accIdToOnTimeArrival.get(key)+cm.On_time_arrival_Dockets__c));
                    }
                    else{
                        accIdToOnTimeArrival.put(key,cm.On_time_arrival_Dockets__c);
                    }   
                }
                
                if(cm.ON_time_delivered_with_out_deps__c != null){
                    if(accIdToOnTimeDelivered.containsKey(key)){
                        accIdToOnTimeDelivered.put(key,(accIdToOnTimeDelivered.get(key)+cm.ON_time_delivered_with_out_deps__c));
                    }
                    else{
                        accIdToOnTimeDelivered.put(key,cm.ON_time_delivered_with_out_deps__c);
                    }   
                }
                
                if(accIdToDocketNumber.containsKey(key)){
                    accIdToDocketNumber.put(key,(accIdToDocketNumber.get(key)+cm.No_of_dkt_MTD__c));
                }
                else{
                    accIdToDocketNumber.put(key,cm.No_of_dkt_MTD__c);
                }
                if(accIdToOutstanding.containsKey(key)){
                    accIdToOutstanding.put(key,(accIdToOutstanding.get(key)+cm.Current_Month_OS__c));
                }
                else{
                    accIdToOutstanding.put(key,cm.Current_Month_OS__c);
                }
                if(accIdToRevenue.containsKey(key)){
                    accIdToRevenue.put(key,(accIdToRevenue.get(key)+cm.MTD__c));
                }
                else{
                    accIdToRevenue.put(key,cm.MTD__c);
                }
                if(accIdToVolume.containsKey(key)){
                    accIdToVolume.put(key,(accIdToVolume.get(key)+cm.Ch_wt_MTD__c));
                }
                else{
                    accIdToVolume.put(key,cm.Ch_wt_MTD__c);
                }
                if(accIdToRevenueLMTD.containsKey(key)){
                    accIdToRevenueLMTD.put(key,(accIdToRevenueLMTD.get(key)+cm.LM_TD__c));
                }
                else{
                    accIdToRevenueLMTD.put(key,cm.LM_TD__c);
                }
                if(cm.CYLM_Charged_Wt__c != null){
                    if(accIdToVolumnLMTD.containsKey(key)){
                        accIdToVolumnLMTD.put(key,(accIdToVolumnLMTD.get(key)+cm.CYLM_Charged_Wt__c));
                    }
                    else{
                        accIdToVolumnLMTD.put(key,cm.CYLM_Charged_Wt__c);
                    }
                }
                if(cm.CYLM_No_of_Dockets__c != null){
                    if(accIdToDocketLMTD.containsKey(key)){
                        accIdToDocketLMTD.put(key,(accIdToDocketLMTD.get(key)+cm.CYLM_No_of_Dockets__c));
                    }
                    else{
                        accIdToDocketLMTD.put(key,cm.CYLM_No_of_Dockets__c);
                    }
                }
                if(accIdToCollection.containsKey(key)){
                    accIdToCollection.put(key,(accIdToCollection.get(key)+cm.COLL_as_on_date__c));
                }
                else{
                    accIdToCollection.put(key,cm.COLL_as_on_date__c);
                }
            }
        }
        if(customerConnectList != null && customerConnectList.size()>0){
            for(Customer_Connect__c cc : customerConnectList){
                Id key = null;
                if(cc.Customer_Code__r.ParentId != null){
                    key = cc.Customer_Code__r.ParentId;
                }
                else{
                    key = cc.Customer_Code__c;
                }
                
                if(accIdToVisitCount.containsKey(key)){
                    accIdToVisitCount.put(key,(accIdToVisitCount.get(key)+1));
                }
                else{
                    accIdToVisitCount.put(key,1);
                }
            }
        }
        
        for(CustomerDashboard__c cdash : scope){
            if(Identifier == 'L12M'){
                cdash.VisitsL12M__c = accIdToVisitCount.containsKey(cdash.AccountName__c) ? accIdToVisitCount.get(cdash.AccountName__c) : 0;
                cdash.DocketL12M__c = accIdToDocketNumber.containsKey(cdash.AccountName__c) ? (accIdToDocketNumber.get(cdash.AccountName__c)) : 0;
                cdash.OutstandingL12M__c = accIdToOutstanding.containsKey(cdash.AccountName__c) ? (accIdToOutstanding.get(cdash.AccountName__c)) : 0;
                cdash.RevenueL12M__c = accIdToRevenue.containsKey(cdash.AccountName__c) ? (accIdToRevenue.get(cdash.AccountName__c)) : 0;
                cdash.VolumeL12M__c = accIdToVolume.containsKey(cdash.AccountName__c) ? (accIdToVolume.get(cdash.AccountName__c)) : 0;
            }
            else if(Identifier == 'L3M'){
                cdash.VisitsL3M__c = accIdToVisitCount.containsKey(cdash.AccountName__c) ? accIdToVisitCount.get(cdash.AccountName__c) : 0;
                cdash.DocketL3M__c = accIdToDocketNumber.containsKey(cdash.AccountName__c) ? (accIdToDocketNumber.get(cdash.AccountName__c)) : 0;
                cdash.OutstandingL3M__c = accIdToOutstanding.containsKey(cdash.AccountName__c) ? (accIdToOutstanding.get(cdash.AccountName__c)) : 0;
                cdash.RevenueL3M__c = accIdToRevenue.containsKey(cdash.AccountName__c) ? (accIdToRevenue.get(cdash.AccountName__c)) : 0;
                cdash.VolumeL3M__c = accIdToVolume.containsKey(cdash.AccountName__c) ? (accIdToVolume.get(cdash.AccountName__c)) : 0;
            }
            else if(Identifier == 'LM'){
                cdash.VisitsLM__c = accIdToVisitCount.containsKey(cdash.AccountName__c) ? accIdToVisitCount.get(cdash.AccountName__c) : 0;
                cdash.DocketLM__c = accIdToDocketNumber.containsKey(cdash.AccountName__c) ? (accIdToDocketNumber.get(cdash.AccountName__c)) : 0;
                cdash.OutstandingLM__c = accIdToOutstanding.containsKey(cdash.AccountName__c) ? (accIdToOutstanding.get(cdash.AccountName__c)) : 0;
                cdash.RevenueLM__c = accIdToRevenue.containsKey(cdash.AccountName__c) ? (accIdToRevenue.get(cdash.AccountName__c)) : 0;
                cdash.VolumeLM__c = accIdToVolume.containsKey(cdash.AccountName__c) ? (accIdToVolume.get(cdash.AccountName__c)) : 0;
            }
            else if(Identifier == 'MTD'){
                cdash.VisitsMTD__c = accIdToVisitCount.containsKey(cdash.AccountName__c) ? accIdToVisitCount.get(cdash.AccountName__c) : 0;
                //cdash.ABSLOutboundMTD__c = accIdToOutbound.containsKey(cdash.AccountName__c) ? accIdToOutbound.get(cdash.AccountName__c) : 0;
                cdash.DocketMTD__c = accIdToDocketNumber.containsKey(cdash.AccountName__c) ? (accIdToDocketNumber.get(cdash.AccountName__c)) : 0;
                cdash.OutstandingMTD__c = accIdToOutstanding.containsKey(cdash.AccountName__c) ? (accIdToOutstanding.get(cdash.AccountName__c)) : 0;
                cdash.RevenueMTD__c = accIdToRevenue.containsKey(cdash.AccountName__c) ? (accIdToRevenue.get(cdash.AccountName__c)) : 0;
                cdash.VolumeMTD__c = accIdToVolume.containsKey(cdash.AccountName__c) ? (accIdToVolume.get(cdash.AccountName__c)) : 0;
				cdash.Revenue_LMTD__c = accIdToRevenueLMTD.containsKey(cdash.AccountName__c) ? (accIdToRevenueLMTD.get(cdash.AccountName__c)) : 0; 
                cdash.CollectionMTD__c = accIdToCollection.containsKey(cdash.AccountName__c) ? (accIdToCollection.get(cdash.AccountName__c)) : 0;
                cdash.VolumeLMTD__c = accIdToVolumnLMTD.containsKey(cdash.AccountName__c) ? (accIdToVolumnLMTD.get(cdash.AccountName__c)) : 0;
                cdash.DocketLMTD__c = accIdToDocketLMTD.containsKey(cdash.AccountName__c) ? (accIdToDocketLMTD.get(cdash.AccountName__c)) : 0;
                //Added for Difot And ABSL
                cdash.On_time_arrival_Dockets_MTD__c = accIdToOnTimeArrival.containsKey(cdash.AccountName__c) ? (accIdToOnTimeArrival.get(cdash.AccountName__c)) : 0;
                cdash.Total_Assured_Dockets_MTD__c = accIdToTotalAssured.containsKey(cdash.AccountName__c) ? (accIdToTotalAssured.get(cdash.AccountName__c)) : 0;
                cdash.On_Time_Delivered_With_Out_Deps_MTD__c = accIdToOnTimeDelivered.containsKey(cdash.AccountName__c) ? (accIdToOnTimeDelivered.get(cdash.AccountName__c)) : 0;
                if(accIdToTotalAssured.containsKey(cdash.AccountName__c) && accIdToOnTimeDelivered.containsKey(cdash.AccountName__c) && accIdToTotalAssured.get(cdash.AccountName__c) != 0){
                    cdash.DIFOTMTD__c = ((accIdToOnTimeDelivered.get(cdash.AccountName__c)) / (accIdToTotalAssured.get(cdash.AccountName__c)))*100;
                }
                else{
                    cdash.DIFOTMTD__c = 0;
                }
                
                if(accIdToTotalAssured.containsKey(cdash.AccountName__c) && accIdToOnTimeArrival.containsKey(cdash.AccountName__c) && accIdToTotalAssured.get(cdash.AccountName__c) != 0){
                    cdash.ABSLInboundMTD__c = ((accIdToOnTimeArrival.get(cdash.AccountName__c)) / (accIdToTotalAssured.get(cdash.AccountName__c)))*100;
                }
                else{
                    cdash.ABSLInboundMTD__c = 0;
                }
            }
            else if(Identifier == 'YTD'){
                cdash.VisitsYTD__c = accIdToVisitCount.containsKey(cdash.AccountName__c) ? accIdToVisitCount.get(cdash.AccountName__c) : 0;
                cdash.DocketYTD__c = accIdToDocketNumber.containsKey(cdash.AccountName__c) ? (accIdToDocketNumber.get(cdash.AccountName__c)) : 0;
                cdash.OutstandingYTD__c = accIdToOutstanding.containsKey(cdash.AccountName__c) ? (accIdToOutstanding.get(cdash.AccountName__c)) : 0;
                cdash.RevenueYTD__c = accIdToRevenue.containsKey(cdash.AccountName__c) ? (accIdToRevenue.get(cdash.AccountName__c)) : 0;
                cdash.VolumeYTD__c = accIdToVolume.containsKey(cdash.AccountName__c) ? (accIdToVolume.get(cdash.AccountName__c)) : 0;
            }
            else if(Identifier == 'LMTD'){
                cdash.VisitsLMTD__c = accIdToVisitCount.containsKey(cdash.AccountName__c) ? accIdToVisitCount.get(cdash.AccountName__c) : 0;
            }
            dashboardListToUpdate.add(cdash);
        }
        for(MonthlyTradeDashboard__c mTrade : monthlyTrades){
            if(Identifier == 'MTD'){
                mTrade.RevenueMTD__c = accIdToRevenue.containsKey(mTrade.ContractName__c) ? (accIdToRevenue.get(mTrade.ContractName__c)) : 0;
                mTrade.RevenueLMTD__c = accIdToRevenueLMTD.containsKey(mTrade.ContractName__c) ? (accIdToRevenueLMTD.get(mTrade.ContractName__c)) : 0;
            }
            else if(Identifier == 'YTD'){
                mTrade.RevenueYTD__c = accIdToRevenue.containsKey(mTrade.ContractName__c) ? (accIdToRevenue.get(mTrade.ContractName__c)) : 0;
            }
            monthlyTradesToUpdate.add(mTrade);
        }
        
        if(dashboardListToUpdate != null && dashboardListToUpdate.size()>0){
            update dashboardListToUpdate;
        }
        if(monthlyTradesToUpdate != null && monthlyTradesToUpdate.size()>0){
            update monthlyTradesToUpdate;
        }
    }
    public void finish(Database.BatchableContext BC){
        Date sDate = null;
        Date eDate = null;
        if(Identifier == 'MTD'){
            sDate = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(-1);
            eDate = Date.newInstance(System.today().year(), System.today().month(), 1).addDays(-1);
            database.executeBatch(new CustomerDashboardCalculationsBatch(sDate,eDate,'LM'));
        }
        else if(Identifier == 'LM'){
            sDate = System.today().addMonths(-3).toStartOfMonth();
            eDate = System.today().toStartOfMonth().addDays(-1);
            database.executeBatch(new CustomerDashboardCalculationsBatch(sDate,eDate,'L3M'));
        }
        else if(Identifier == 'L3M'){
            sDate = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(-12);
            eDate = Date.newInstance(System.today().year(), System.today().month(), 1).addDays(-1);
            database.executeBatch(new CustomerDashboardCalculationsBatch(sDate,eDate,'L12M'));
        }
        else if(Identifier == 'L12M'){
            sDate = System.today().month() >= 4 ? Date.newInstance(System.today().year(), 4, 1) : Date.newInstance(System.today().year() - 1, 4, 1);
            eDate = System.today().month() >= 4 ? Date.newInstance(System.today().year() + 1, 3, 31) : Date.newInstance(System.today().year(), 3, 31);
            database.executeBatch(new CustomerDashboardCalculationsBatch(sDate,eDate,'YTD'));
        }
        else if(Identifier == 'YTD'){
            sDate = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(-1);
            eDate = System.today().addMonths(-1);
            database.executeBatch(new CustomerDashboardCalculationsBatch(sDate,eDate,'LMTD'));
        }
        else if(Identifier == 'LMTD'){
            //Batch Finished
        }
    }
}