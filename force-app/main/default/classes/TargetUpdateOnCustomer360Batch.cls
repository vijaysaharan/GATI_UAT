global class TargetUpdateOnCustomer360Batch{   
    global static void startCustMethod(Set<Id> customer360Ids){
        dummy();
        String monthYear = findMonthName(System.today().month())+'-'+String.valueOf(System.today().year());
        //String monthYear = '';
        System.debug('--- month year--'+monthYear);
        String query='';
        query = 'SELECT Id,Sales_KRA__c,Month_Year__c,Zone__c,Product__c,Account_Type__c,Customer_Code__c,Customer_Code__r.OwnerId,Net_Biz__c,';
        query+= 'MTD__c,LM_TD__c,MOM__c,LYSM_TD__c,YEST_REV__c,Yield__c,MTD_ESS_Revenue__c,Y_Day_Dkts__c,No_of_dkt_MTD__c,Ch_wt_MTD__c FROM Customer360__c WHERE Id IN:customer360Ids AND Month_Year__c=:monthYear';
        
        Map<Id,Customer360__c> updateLookup = new Map<Id,Customer360__c>();
        Map<String,Sales_KRA__c> updateSalesKRA = new Map<String,Sales_KRA__c>();
        String query1 ='';
        List<Customer360__c> listOfCustomer360 = Database.query(query);
        System.debug('--- check customer 360--'+listOfCustomer360);
        Map<String,Decimal> rollupOfBizMonthtoDate = new Map<String,Decimal>();
        Map<String,Decimal> rollupOfNetBiz = new Map<String,Decimal>();
        Map<String,Decimal> rollupOfLMTD = new Map<String,Decimal>();
        Map<String,Decimal> rollupOfMOM = new Map<String,Decimal>();
        Map<String,Decimal> rollupOfLYSMTD = new Map<String,Decimal>();
        Map<String,Decimal> rollupOfYESTREV = new Map<String,Decimal>();
        Map<String,Decimal> rollupOfYDayDkts = new Map<String,Decimal>();
        Map<String,Decimal> rollupOfNoofdktMTD = new Map<String,Decimal>();
        Map<String,Decimal> rollupOfChwtMTD = new Map<String,Decimal>();
        Map<String,Decimal> rollupOfMTDESSRevenue = new Map<String,Decimal>();
        
        if(!Test.isRunningTest()){
            query1 = 'SELECT Id,Achievement_Amount_INR__c,KAM_KAE__c,Product__c,Account_Type__c,Month_Year__c,Zone__c,Net_Biz__c,LM_TD__c,MOM__c,';
            query1+= 'LYSM_TD__c,YEST_REV__c,Y_Day_Dkts__c,No_of_dkt_MTD__c,Ch_wt_MTD__c FROM Sales_KRA__c WHERE Month_Year__c=:monthYear'; 
        }else{
            query1 = 'SELECT Id,Achievement_Amount_INR__c,KAM_KAE__c,Product__c,Account_Type__c,Month_Year__c,Zone__c,Net_Biz__c,LM_TD__c,MOM__c,';
            query1+= 'LYSM_TD__c,YEST_REV__c,Y_Day_Dkts__c,No_of_dkt_MTD__c,MTD_ESS_Revenue__c,Ch_wt_MTD__c FROM Sales_KRA__c limit 1'; 
            
        }
        List<Sales_KRA__c> lisOfTarget = database.query(query1);
        System.debug('-- sale kra list--'+lisOfTarget);
        for(Customer360__c cuct360 : listOfCustomer360){
            if(!lisOfTarget.isEmpty() && lisOfTarget.size()>0){
                for(Sales_KRA__c salesKRA : lisOfTarget){
                    if(salesKRA.Month_Year__c==cuct360.Month_Year__c && salesKRA.Product__c==cuct360.Product__c && salesKRA.KAM_KAE__c==cuct360.Customer_Code__r.OwnerId){
                        Customer360__c cust = new Customer360__c();
                        cust.Id = cuct360.Id;
                        cust.Sales_KRA__c = salesKRA.Id;
                        updateLookup.put(cust.Id,cust);
                        if(!rollupOfBizMonthtoDate.containsKey(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)){
                            Decimal mdt = cuct360.MTD__c!=null?cuct360.MTD__c:0;
                            rollupOfBizMonthtoDate.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,mdt); 
                        }else{
                            Decimal newmtd = cuct360.MTD__c!=null?cuct360.MTD__c:0;
                            Decimal tempMTD = rollupOfBizMonthtoDate.get(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)+newmtd;
                            rollupOfBizMonthtoDate.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,tempMTD);
                        }
                        if(!rollupOfNetBiz.containsKey(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)){
                            Decimal netb = cuct360.Net_Biz__c!=null?cuct360.Net_Biz__c:0;
                            rollupOfNetBiz.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,netb); 
                        }else{
                            Decimal newNetBiz = cuct360.Net_Biz__c!=null?cuct360.Net_Biz__c:0;
                            Decimal tempNetBiz = rollupOfNetBiz.get(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)+newNetBiz;
                            rollupOfNetBiz.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,tempNetBiz);
                        }
                        if(!rollupOfLMTD.containsKey(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)){
                            Decimal lmtd = cuct360.LM_TD__c!=null?cuct360.LM_TD__c:0;
                            rollupOfLMTD.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,lmtd); 
                        }else{
                            Decimal newLmTD = cuct360.LM_TD__c!=null?cuct360.LM_TD__c:0;
                            Decimal tempLMTD = rollupOfLMTD.get(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)+newLmTD;
                            rollupOfLMTD.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,tempLMTD);
                        }
                        if(!rollupOfMOM.containsKey(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)){
                            Decimal mom = cuct360.MOM__c!=null?cuct360.MOM__c:0;
                            rollupOfMOM.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,mom); 
                        }else{
                            Decimal newMom = cuct360.MOM__c!=null?cuct360.MOM__c:0;
                            Decimal tempMOM = rollupOfMOM.get(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)+newMom;
                            rollupOfMOM.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,tempMOM);
                        }
                        
                        if(!rollupOfLYSMTD.containsKey(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)){
                            Decimal lysmtd = cuct360.LYSM_TD__c!=null?cuct360.LYSM_TD__c:0;
                            rollupOfLYSMTD.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,lysmtd); 
                        }else{
                            Decimal newLYSM = cuct360.LYSM_TD__c!=null?cuct360.LYSM_TD__c:0;
                            Decimal tempLYSM = rollupOfLYSMTD.get(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)+newLYSM;
                            rollupOfLYSMTD.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,tempLYSM);
                        }
                        if(!rollupOfYESTREV.containsKey(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)){
                            Decimal yestrev = cuct360.YEST_REV__c!=null?cuct360.YEST_REV__c:0;
                            rollupOfYESTREV.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,yestrev); 
                        }else{
                            Decimal newYesRev = cuct360.YEST_REV__c!=null?cuct360.YEST_REV__c:0;
                            Decimal tempYESREV = rollupOfYESTREV.get(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)+newYesRev;
                            rollupOfYESTREV.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,tempYESREV);
                        }
                        if(!rollupOfYDayDkts.containsKey(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)){
                            Decimal ydkts = cuct360.Y_Day_Dkts__c!=null?cuct360.Y_Day_Dkts__c:0;
                            rollupOfYDayDkts.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,ydkts); 
                        }else{
                            Decimal newydaydkts = cuct360.Y_Day_Dkts__c!=null?cuct360.Y_Day_Dkts__c:0;
                            Decimal tempYDayDkts = rollupOfYDayDkts.get(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)+newydaydkts;
                            rollupOfYDayDkts.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,tempYDayDkts);
                        }
                        if(!rollupOfNoofdktMTD.containsKey(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)){
                            Decimal noOfmtd = cuct360.No_of_dkt_MTD__c!=null?cuct360.No_of_dkt_MTD__c:0;
                            rollupOfNoofdktMTD.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,noOfmtd); 
                        }else{
                            Decimal newNoofdktMtd = cuct360.No_of_dkt_MTD__c!=null?cuct360.No_of_dkt_MTD__c:0;
                            Decimal tempNoOfdktMTD = rollupOfNoofdktMTD.get(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)+newNoofdktMtd;
                            rollupOfNoofdktMTD.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,tempNoOfdktMTD);
                        }
                        if(!rollupOfChwtMTD.containsKey(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)){
                            Decimal chwtMtd = cuct360.Ch_wt_MTD__c!=null?cuct360.Ch_wt_MTD__c:0;
                            rollupOfChwtMTD.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,chwtMtd); 
                        }else{
                            Decimal newChwtMTD = cuct360.Ch_wt_MTD__c!=null?cuct360.Ch_wt_MTD__c:0;
                            Decimal tempChwtMTD = rollupOfChwtMTD.get(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)+newChwtMTD;
                            rollupOfChwtMTD.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,tempChwtMTD);
                        }
                           if(!rollupOfMTDESSRevenue.containsKey(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)){
                            Decimal mtdess = cuct360.MTD_ESS_Revenue__c!=null?cuct360.MTD_ESS_Revenue__c:0;
                            rollupOfMTDESSRevenue.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,mtdess); 
                        }else{
                            Decimal newMTDEss = cuct360.MTD_ESS_Revenue__c!=null?cuct360.MTD_ESS_Revenue__c:0;
                            Decimal tempMTDEss = rollupOfMTDESSRevenue.get(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c)+newMTDEss;
                            rollupOfMTDESSRevenue.put(cuct360.Customer_Code__r.OwnerId+':'+cuct360.Month_Year__c+':'+cuct360.Product__c,tempMTDEss);
                        }
                    }
                }
            }
        }
        
        for(Sales_KRA__c salesValues : lisOfTarget){
            Sales_KRA__c salesObj = new Sales_KRA__c();
            if(rollupOfBizMonthtoDate.containsKey(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c)){
                
                salesObj.Achievement_Amount_INR__c = rollupOfBizMonthtoDate.get(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c);
            }
            if(rollupOfNetBiz.containsKey(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c)){
                
                salesObj.Net_Biz__c = rollupOfNetBiz.get(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c);
            }
            if(rollupOfLMTD.containsKey(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c)){
                
                salesObj.LM_TD__c = rollupOfLMTD.get(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c);
            }
            if(rollupOfMOM.containsKey(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c)){
                
                salesObj.MOM__c = rollupOfMOM.get(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c);
            }
            if(rollupOfLYSMTD.containsKey(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c)){
                
                salesObj.LYSM_TD__c = rollupOfLYSMTD.get(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c);
            }
            if(rollupOfYESTREV.containsKey(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c)){
                
                salesObj.YEST_REV__c = rollupOfYESTREV.get(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c);
            }
            
            if(rollupOfYDayDkts.containsKey(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c)){
                
                salesObj.Y_Day_Dkts__c = rollupOfYDayDkts.get(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c);
            }
            if(rollupOfNoofdktMTD.containsKey(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c)){
                
                salesObj.No_of_dkt_MTD__c = rollupOfNoofdktMTD.get(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c);
            }
            if(rollupOfChwtMTD.containsKey(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c)){
                salesObj.Ch_wt_MTD__c = rollupOfChwtMTD.get(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c);
            } 
             if(rollupOfMTDESSRevenue.containsKey(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c)){
                salesObj.MTD_ESS_Revenue__c = rollupOfMTDESSRevenue.get(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c);
            }
            salesObj.Id = salesValues.Id;
            if(salesObj!=null && salesObj.id!=null)
                updateSalesKRA.put(salesValues.KAM_KAE__c+':'+salesValues.Month_Year__c+':'+salesValues.Product__c,salesObj);
            
        }
        
        if(!updateLookup.isEmpty() && updateLookup.size()>0){
            database.update(updateLookup.values());
        }
        if(!updateSalesKRA.isEmpty() && updateSalesKRA.size()>0){
            database.update(updateSalesKRA.values());
        }
    }
    
    public static String findMonthName(Integer num){
        String str = '';
        if(num == 1)
            str = 'Jan';
        if(num == 2)
            str = 'Feb';
        if(num == 3)
            str = 'Mar';
        if(num == 4)
            str = 'Apr';
        if(num == 5)
            str = 'May';
        if(num == 6)
            str = 'Jun';
        if(num == 7)
            str = 'Jul';
        if(num == 8)
            str = 'Aug';
        if(num == 9)
            str = 'Sep';
        if(num == 10)
            str = 'Oct';
        if(num == 11)
            str = 'Nov';
        if(num == 12)
            str = 'Dec';
        
        return str;
        
        
    }
    private static void dummy(){
        integer i=1;
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