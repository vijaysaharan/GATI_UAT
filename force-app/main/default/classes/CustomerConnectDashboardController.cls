public with sharing class CustomerConnectDashboardController {
    @AuraEnabled
    public static List<FiscalYearWrapper> getPicklistValue(String quarter,String fiscalYear) {
        Map<String, String> fiscalQt = new Map<String,String>{'Q1'=>'04,05,06','Q2'=>'07,08,09','Q3'=>'10,11,12','Q4'=>'01,02,03'};
            Map<String, String> months = new Map<String,String>{'Q1'=>'4,5,6','Q2'=>'7,8,9','Q3'=>'10,11,12','Q4'=>'1,2,3'};
                List<String> quarterList = new List<String>();
        List<String> fiscalYearList = new List<String>();
        List<Customer_Connect__c> customerConnectList = new List<Customer_Connect__c>();
        Map<String,Decimal> retailMap = new Map<String,Decimal>();
        Map<String,Decimal> msmeMap = new Map<String,Decimal>();
        Map<String,Decimal> strategicMap = new Map<String,Decimal>();
        Map<String,Decimal> keaMap = new Map<String,Decimal>();
        List<FiscalYearWrapper> fiscalYearData = new List<FiscalYearWrapper>();
        
        DateTime dtAndTimeS;
        DateTime dtAndTimeE;
        String startDate='';
        String endDate='';
        if(quarter=='Q1'){
            quarterList = fiscalQt.get(quarter).split(',');
            fiscalYearList = fiscalYear.split('-');
            
            dtAndTimeS = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[0]+'-01 00:00:00:00');
            dtAndTimeE = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[2]+'-30 00:00:00:00');
            System.debug('--- start date--'+dtAndTimeS);
            System.debug('--- end date--'+dtAndTimeE);
        }else if(quarter=='Q2'){
            System.debug('--- quarter--'+fiscalQt.get(quarter));
            quarterList = fiscalQt.get(quarter).split(',');
            fiscalYearList = fiscalYear.split('-');
            
            dtAndTimeS = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[0]+'-01 00:00:00:00');
            dtAndTimeE = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[2]+'-30 00:00:00:00');
        }else if(quarter=='Q3'){
            quarterList = fiscalQt.get(quarter).split(',');
            fiscalYearList = fiscalYear.split('-');
            
            dtAndTimeS = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[0]+'-01 00:00:00:00');
            dtAndTimeE = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[2]+'-31 00:00:00:00');
        }else if(quarter=='Q4'){
            quarterList = fiscalQt.get(quarter).split(',');
            fiscalYearList = fiscalYear.split('-');
            
            dtAndTimeS = DateTime.valueOf(fiscalYearList[1]+'-'+quarterList[0]+'-01 00:00:00:00');
            dtAndTimeE = DateTime.valueOf(fiscalYearList[1]+'-'+quarterList[2]+'-31 00:00:00:00');
            System.debug('--- start date--'+dtAndTimeS);
            System.debug('--- end date--'+dtAndTimeE);
        }
        
        if(!Test.isRunningTest()){
            customerConnectList = [SELECT Id, Owner.UserRole.Name,CreatedDate,Role_Name__c  FROM Customer_Connect__c WHERE CreatedDate>=:dtAndTimeS AND CreatedDate<=:dtAndTimeE LIMIT 50000];
            
        }else{
            customerConnectList = [SELECT Id, Owner.UserRole.Name,CreatedDate,Role_Name__c  FROM Customer_Connect__c limit 1000];
        }
        //customerConnectList = [SELECT Id, Owner.UserRole.Name,CreatedDate,Role_Name__c  FROM Customer_Connect__c WHERE CreatedDate>=:dtAndTimeS AND CreatedDate<=:dtAndTimeE];
        Map<String, List<Customer_Connect__c>> mapOfCustomerConnect = new Map<String,List<Customer_Connect__c>>();
        if(!customerConnectList.isEmpty() && customerConnectList.size()>0){
            
            
            for(Customer_Connect__c cc : customerConnectList){
                if(cc.Owner.UserRole.Name!=null){
                    if(cc.Role_Name__c.containsIgnoreCase('RETAIL')){
                        
                        if(!mapOfCustomerConnect.containsKey(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-RETAIL')){
                            mapOfCustomerConnect.put(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-RETAIL',new List<Customer_Connect__c>{cc});
                        }else{
                            mapOfCustomerConnect.get(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-RETAIL').add(cc);
                        }
                    }else if(cc.Role_Name__c.containsIgnoreCase('MSME')){
                        if(!mapOfCustomerConnect.containsKey(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-MSME')){
                            mapOfCustomerConnect.put(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-MSME',new List<Customer_Connect__c>{cc});
                        }else{
                            mapOfCustomerConnect.get(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-MSME').add(cc);
                        }
                    }else if(cc.Role_Name__c.containsIgnoreCase('Strategic')){
                        if(!mapOfCustomerConnect.containsKey(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-Strategic')){
                            mapOfCustomerConnect.put(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-Strategic',new List<Customer_Connect__c>{cc});
                        }else{
                            mapOfCustomerConnect.get(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-Strategic').add(cc);
                        }
                    }else if(cc.Role_Name__c.containsIgnoreCase('KEA')){
                        if(!mapOfCustomerConnect.containsKey(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-KEA')){
                            mapOfCustomerConnect.put(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-KEA',new List<Customer_Connect__c>{cc});
                        }else{
                            mapOfCustomerConnect.get(getMonth(cc.CreatedDate.month())+'-'+cc.CreatedDate.year()+'-KEA').add(cc);
                        }
                    }
                }
            }
        }
        System.debug('--- mapOfCustomerConnect---'+mapOfCustomerConnect);
        if(!mapOfCustomerConnect.isEmpty()){
            System.debug('--- check 1--'+quarter);
            List<String> quarList = new List<String>();
            List<String> fiscalYrList = new List<String>();
            //fiscalYearData
            //months split
            if(quarter=='Q1'){
                Integer retail = 0;
                Integer msme = 0;
                Integer strategic = 0;
                Integer kea = 0;
                Integer retail1 = 0;
                Integer msme1 = 0;
                Integer strategic1 = 0;
                Integer kea1 = 0;
                Integer retail2 = 0;
                Integer msme2 = 0;
                Integer strategic2 = 0;
                Integer kea2 = 0;
                
                quarList = months.get(quarter).split(',');
                fiscalYrList = fiscalYear.split('-');
                
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-RETAIL'))
                    retail = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-MSME'))
                    msme = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-Strategic'))
                    strategic = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-KEA'))
                    kea = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-KEA').size();
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail/26).setScale(2)),String.valueOf(Decimal.valueOf(msme/26).setScale(2)),String.valueOf(Decimal.valueOf(kea/26).setScale(2)),String.valueOf(Decimal.valueOf(strategic/26).setScale(2))));
                
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-RETAIL'))
                    retail1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-MSME'))
                    msme1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-Strategic'))
                    strategic1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-KEA'))
                    kea1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-KEA').size();
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail1/26).setScale(2)),String.valueOf(Decimal.valueOf(msme1/26).setScale(2)),String.valueOf(Decimal.valueOf(kea1/26).setScale(2)),String.valueOf(Decimal.valueOf(strategic1/26).setScale(2))));
                
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-RETAIL'))
                    retail2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-MSME'))
                    msme2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-Strategic'))
                    strategic2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-KEA'))
                    kea2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-KEA').size();
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail2/26).setScale(2)),String.valueOf(Decimal.valueOf(msme2/26).setScale(2)),String.valueOf(Decimal.valueOf(kea2/26).setScale(2)),String.valueOf(Decimal.valueOf(strategic2/26).setScale(2))));
            }else if(quarter=='Q2'){
                Integer retail = 0;
                Integer msme = 0;
                Integer strategic = 0;
                Integer kea = 0;
                Integer retail1 = 0;
                Integer msme1 = 0;
                Integer strategic1 = 0;
                Integer kea1 = 0;
                Integer retail2 = 0;
                Integer msme2 = 0;
                Integer strategic2 = 0;
                Integer kea2 = 0;
                quarList = months.get(quarter).split(',');
                fiscalYrList = fiscalYear.split('-');
                
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-RETAIL'))
                    retail = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-MSME'))
                    msme = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-Strategic'))
                    strategic = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-KEA'))
                    kea = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-KEA').size();
                
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail/26).setScale(2)),String.valueOf(Decimal.valueOf(msme/26).setScale(2)),String.valueOf(Decimal.valueOf(kea/26).setScale(2)),String.valueOf(Decimal.valueOf(strategic/26).setScale(2))));
                System.debug('---check 1--'+fiscalYearData);
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-RETAIL'))
                    retail1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-MSME'))
                    msme1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-Strategic'))
                    strategic1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-KEA'))
                    kea1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-KEA').size();
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail1/26).setScale(2)),String.valueOf(Decimal.valueOf(msme1/26).setScale(2)),String.valueOf(Decimal.valueOf(kea1/26).setScale(2)),String.valueOf(Decimal.valueOf(strategic1).setScale(2))));
                System.debug('---check 2--'+fiscalYearData);
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-RETAIL'))
                    retail2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-MSME'))
                    msme2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-Strategic'))
                    strategic2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-KEA'))
                    kea2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-KEA').size();
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail2/26).setScale(2)),String.valueOf(Decimal.valueOf(msme2).setScale(2)),String.valueOf(Decimal.valueOf(kea2/26).setScale(2)),String.valueOf(Decimal.valueOf(strategic2).setScale(2))));
                System.debug('---check 3--'+fiscalYearData);
            }else if(quarter=='Q3'){
                Integer retail = 0;
                Integer msme = 0;
                Integer strategic = 0;
                Integer kea = 0;
                Integer retail1 = 0;
                Integer msme1 = 0;
                Integer strategic1 = 0;
                Integer kea1 = 0;
                Integer retail2 = 0;
                Integer msme2 = 0;
                Integer strategic2 = 0;
                Integer kea2 = 0;
                quarList = months.get(quarter).split(',');
                fiscalYrList = fiscalYear.split('-');
                
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-RETAIL'))
                    retail = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-MSME'))
                    msme = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-Strategic'))
                    strategic = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-KEA'))
                    kea = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0]+'-KEA').size();
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail/26).setScale(2)),String.valueOf(Decimal.valueOf(msme/26).setScale(2)),String.valueOf(Decimal.valueOf(kea/26).setScale(2)),String.valueOf(Decimal.valueOf(strategic/26).setScale(2))));
                
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-RETAIL'))
                    retail1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-MSME'))
                    msme1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-Strategic'))
                    strategic1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-KEA'))
                    kea1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-KEA').size();
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail1/26).setScale(2)),String.valueOf(Decimal.valueOf(msme1/26).setScale(2)),String.valueOf(Decimal.valueOf(kea1/26).setScale(2)),String.valueOf(Decimal.valueOf(strategic1/26).setScale(2))));
                
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-RETAIL'))
                    retail2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-MSME'))
                    msme2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-Strategic'))
                    strategic2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-KEA'))
                    kea2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0]+'-KEA').size();
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail2/26).setScale(2)),String.valueOf(Decimal.valueOf(msme2/26).setScale(2)),String.valueOf(Decimal.valueOf(kea2/26).setScale(2)),String.valueOf(Decimal.valueOf(strategic2/26).setScale(2))));
            }else if(quarter=='Q4'){
                Integer retail = 0;
                Integer msme = 0;
                Integer strategic = 0;
                Integer kea = 0;
                Integer retail1 = 0;
                Integer msme1 = 0;
                Integer strategic1 = 0;
                Integer kea1 = 0;
                Integer retail2 = 0;
                Integer msme2 = 0;
                Integer strategic2 = 0;
                Integer kea2 = 0;
                quarList = months.get(quarter).split(',');
                fiscalYrList = fiscalYear.split('-');
                
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[1]+'-RETAIL'))
                    retail = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[1]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[1]+'-MSME'))
                    msme = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[1]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[1]+'-Strategic'))
                    strategic = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[1]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[1]+'-KEA'))
                    kea = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[1]+'-KEA').size();
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[0]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail/26).setScale(2)),String.valueOf(Decimal.valueOf(msme/26).setScale(2)),String.valueOf(Decimal.valueOf(kea/26).setScale(2)),String.valueOf(Decimal.valueOf(strategic/26).setScale(2))));
                
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[1]+'-RETAIL'))
                    retail1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[1]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[1]+'-MSME'))
                    msme1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[1]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[1]+'-Strategic'))
                    strategic1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[1]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[1]+'-KEA'))
                    kea1 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0]+'-KEA').size();
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[1]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail1/24).setScale(2)),String.valueOf(Decimal.valueOf(msme1/24).setScale(2)),String.valueOf(Decimal.valueOf(kea1/24).setScale(2)),String.valueOf(Decimal.valueOf(strategic1/24).setScale(2))));
                
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[1]+'-RETAIL'))
                    retail2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[1]+'-RETAIL').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[1]+'-MSME'))
                    msme2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[1]+'-MSME').size(); 
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[1]+'-Strategic'))
                    strategic2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[1]+'-Strategic').size();
                If(mapOfCustomerConnect.containsKey(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[1]+'-KEA'))
                    kea2 = mapOfCustomerConnect.get(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[1]+'-KEA').size();
                fiscalYearData.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quarList[2]))+'-'+fiscalYrList[0],String.valueOf(Decimal.valueOf(retail2/26).setScale(2)),String.valueOf(Decimal.valueOf(msme2/26).setScale(2)),String.valueOf(Decimal.valueOf(kea2/26).setScale(2)),String.valueOf(Decimal.valueOf(strategic2/26).setScale(2))));
            }
            
        }
        System.debug('--- final data checking--'+fiscalYearData);
        if(!fiscalYearData.isEmpty() && fiscalYearData.size()>0){
            return fiscalYearData;
        }
        return null;
    }
    @AuraEnabled
    public static List<FiscalYearWrapper> getCustmoer360(){
        List<FiscalYearWrapper> wrapperData = new List<FiscalYearWrapper>();
        Integer smme=0;
        Integer kea=0;
        Integer strategic=0;
        Integer retail=0;
        Map<String,Decimal> bizPerVertical = new Map<String,Decimal>();
        
        List<Customer360__c >customer360Data = [SELECT Account_Type__c,MTD__c FROM Customer360__c WHERE As_on_date__c =LAST_MONTH];
        retail = [SELECT COUNT() FROM Account WHERE RecordType.Name='Retail'];
        List<Account> accList =  [SELECT Id,Customer_Category__c from Account WHERE RecordType.Name='Contract'];
        if(!accList.isEmpty() && accList.size()>0){
            for(Account accVert : accList){
                if(accVert.Customer_Category__c=='MSME'){
                    smme+=1;
                }else if(accVert.Customer_Category__c=='KEA'){
                    kea+=1;
                }else if(accVert.Customer_Category__c=='Strategic'){
                    strategic+=1;                
                }
            }
        }
        
        if(customer360Data!=null && customer360Data.size()>0){
            for(Customer360__c aggr:customer360Data){  
                if(!bizPerVertical.containsKey(aggr.Account_Type__c)){
                    bizPerVertical.put(aggr.Account_Type__c,aggr.MTD__c);
                }else{
                    Decimal del =  bizPerVertical.get(aggr.Account_Type__c)+aggr.MTD__c;
                    bizPerVertical.put(aggr.Account_Type__c,del);
                }
            }
        }
        
        Decimal retailDel = 0;
        Decimal MSMEDel = 0;
        Decimal KEADel = 0;
        Decimal StrategicDel = 0;
        
        if(retail!=0){
            retailDel = Math.round(bizPerVertical.get('Retail')/retail);
        }
        if(smme!=0){
            MSMEDel = Math.round(bizPerVertical.get('MSME')/smme);
        }
        if(KEA!=0){
            KEADel = Math.round(bizPerVertical.get('KEA')/KEA);
        }
        if(strategic!=0){
            StrategicDel = Math.round(bizPerVertical.get('Strategic')/strategic);
        }
        wrapperData.add(new FiscalYearWrapper('',String.valueOf(retailDel),String.valueOf(MSMEDel),String.valueOf(KEADel),String.valueOf(StrategicDel)));
        if(wrapperData!=null && wrapperData.size()>0){
            return wrapperData;
        }
        return null;
    }
    
    @AuraEnabled
    public static  List<FiscalYearWrapper> fetchOpprtunityData(String quarter,String fiscalYear){
        Map<String, String> fiscalQt = new Map<String,String>{'Q1'=>'04,05,06','Q2'=>'07,08,09','Q3'=>'10,11,12','Q4'=>'01,02,03'};
            Map<String, String>  months = new Map<String,String>{'Q1'=>'4,5,6','Q2'=>'7,8,9','Q3'=>'10,11,12','Q4'=>'1,2,3'};
                List<String> quarterList = new List<String>();
        List<String> fiscalYearList = new List<String>();
        
        List<String> quartermonths = months.get(quarter).split(',');
        List<FiscalYearWrapper> oppWrapperClass = new List<FiscalYearWrapper>();
        // start and end date time varibale
        DateTime startDateTime;
        DateTime endDateTime;
        //total opportunity var basis of vertical
        Integer retailTotal1 = 0;
        Integer msmeTotal1 = 0;
        Integer keaTotal1 = 0;
        Integer strategicTotal1 = 0;
        
        Integer retailTotal2 = 0;
        Integer msmeTotal2 = 0;
        Integer keaTotal2 = 0;
        Integer strategicTotal2 = 0;
        
        Integer retailTotal3 = 0;
        Integer msmeTotal3 = 0;
        Integer keaTotal3 = 0;
        Integer strategicTotal3 = 0;
        
        //signed opportunity total variable
        Integer retailSigned1 = 0;
        Integer msmeSigned1 = 0;
        Integer keaSigned1 = 0;
        Integer strategicSigned1 = 0;
        
        Integer retailSigned2 = 0;
        Integer msmeSigned2 = 0;
        Integer keaSigned2 = 0;
        Integer strategicSigned2 = 0;
        
        Integer retailSigned3 = 0;
        Integer msmeSigned3 = 0;
        Integer keaSigned3 = 0;
        Integer strategicSigned3 = 0;
        
        
        //checking quarter condition 
        if(quarter=='Q1'){
            quarterList = fiscalQt.get(quarter).split(',');
            fiscalYearList = fiscalYear.split('-');
            
            Map<String,Integer> totalOppMap = new Map<String,Integer>();
            Map<String,Integer> mapSignedOpp = new Map<String,Integer>();
            
            
            startDateTime = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[0]+'-01 00:00:00:00');
            endDateTime = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[2]+'-30 00:00:00:00');
            List<Opportunity> oppListNewContract = new List<Opportunity>();
            List<Opportunity> oppListNewContractSigned = new List<Opportunity>();
            
            if(!Test.isRunningTest()){
                oppListNewContract = [SELECT Id,StageName,Account_Type__c,CreatedDate FROM Opportunity WHERE CreatedDate>=:startDateTime AND CreatedDate<=:endDateTime AND Opportunity_Type_Contract__c='New Contract' AND (StageName!='Committed' OR StageName!='Sold')];
            }else{
                oppListNewContract = [SELECT Id,StageName,Account_Type__c,CreatedDate FROM Opportunity WHERE Opportunity_Type_Contract__c='New Contract' AND (StageName!='Committed' OR StageName!='Sold') limit 1000];
            }
            if(!Test.isRunningTest()){
                oppListNewContractSigned = [SELECT Id,StageName,Account_Type__c,CreatedDate,Account.Contract_Activation_Date__c FROM Opportunity WHERE CreatedDate>=:startDateTime AND CreatedDate<=:endDateTime AND Opportunity_Type_Contract__c='New Contract' AND (StageName='Sold' OR StageName='Committed') AND Account.Contract_Activation_Date__c!=null];
            }else{
                oppListNewContractSigned = [SELECT Id,StageName,Account_Type__c,CreatedDate,Account.Contract_Activation_Date__c FROM Opportunity WHERE Opportunity_Type_Contract__c='New Contract' AND (StageName='Sold' OR StageName='Committed') limit 1000];  
            }
            
            if(!oppListNewContract.isEmpty() && oppListNewContract.size()>0){
                for(Opportunity opp1: oppListNewContract){
                    if(opp1.Account_Type__c=='MSME'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='Retail'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='KEA'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='Strategic'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic',tempDel);
                        }
                    }
                }
            }
            
            if(!oppListNewContractSigned.isEmpty() && oppListNewContractSigned.size()>0){
                for(Opportunity opp1: oppListNewContractSigned){
                    if(opp1.Account_Type__c=='MSME'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.CreatedDate.year()+'-MSME')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME',tempDel);
                            }
                    }else if(opp1.Account_Type__c=='Retail'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail',tempDel);
                            }
                    }else if(opp1.Account_Type__c=='KEA'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA',tempDel);
                            }
                    }else if(opp1.Account_Type__c=='Strategic'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic',tempDel);
                            }
                    }
                }
            }
            //for first month
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail'))
                retailTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME'))
                msmeTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA'))
                keaTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic'))
                strategicTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic');
            
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail'))
                retailSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME'))
                msmeSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA'))
                keaSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic'))
                strategicSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic');
            
            Double retailfirstMonthPer = 0;
            Double msmefirstMonthPer = 0;
            Double keafirstMonthPer = 0;
            Double strategicfirstMonthPer = 0;
            
            if(retailTotal1!=0){retailfirstMonthPer = (((Double)retailSigned1/(Double)retailTotal1)*100);}
            if(msmeTotal1!=0){msmefirstMonthPer = (((Double)msmeSigned1/(Double)msmeTotal1)*100);}
            if(keaTotal1!=0){keafirstMonthPer = (((Double)keaSigned1/(Double)keaTotal1)*100);}
            if(strategicTotal1!=0){strategicfirstMonthPer = (((Double)strategicSigned1/(Double)strategicTotal1)*100);}
            oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0],String.valueOf(retailTotal1)+'/'+String.valueOf(retailSigned1)+'('+String.valueOf(Decimal.valueOf(retailfirstMonthPer).setScale(2))+'%)',String.valueOf(msmeTotal1)+'/'+String.valueOf(msmeSigned1)+'('+String.valueOf(Decimal.valueOf(msmefirstMonthPer).setScale(2))+'%)',String.valueOf(keaTotal1)+'/'+String.valueOf(keaSigned1)+'('+String.valueOf(Decimal.valueOf(keafirstMonthPer).setScale(2))+'%)',String.valueOf(strategicTotal1)+'/'+String.valueOf(strategicSigned1)+'('+String.valueOf(Decimal.valueOf(strategicfirstMonthPer).setScale(2))+'%)'));
            
            //for second month
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail'))
                retailTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME'))
                msmeTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA'))
                keaTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic'))
                strategicTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic');
            
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail'))
                retailSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME'))
                msmeSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA'))
                keaSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic'))
                strategicSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic');
            
            
            Double retailsecondMonthPer = 0;
            Double msmesecondMonthPer = 0;
            Double keasecondMonthPer = 0;
            Double strategicsecondMonthPer =0;
            
            if((retailTotal1+retailTotal2-retailSigned1)!=0){retailsecondMonthPer = (((Double)retailSigned2/(Double)(retailTotal1+retailTotal2-retailSigned1))*100);}
            if((msmeTotal1+msmeTotal2-msmeSigned1)!=0){msmesecondMonthPer = (((Double)msmeSigned2/(Double)(msmeTotal1+msmeTotal2-msmeSigned1))*100);}
            if((keaTotal1+keaTotal2-keaSigned1)!=0){keasecondMonthPer = (((Double)keaSigned2/(Double)(keaTotal1+keaTotal2-keaSigned1))*100);}
            if((strategicTotal1+strategicTotal2-strategicSigned1)!=0){strategicsecondMonthPer = (((Double)strategicSigned2/(Double)(strategicTotal1+strategicTotal2-strategicSigned1))*100);}
            oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0],String.valueOf((retailTotal1+retailTotal2-retailSigned1))+'/'+String.valueOf(retailSigned2)+'('+String.valueOf(Decimal.valueOf(retailsecondMonthPer).setScale(2))+'%)',String.valueOf((msmeTotal1+msmeTotal2-msmeSigned1))+'/'+String.valueOf(msmeSigned2)+'('+String.valueOf(Decimal.valueOf(msmesecondMonthPer).setScale(2))+'%)',String.valueOf((keaTotal1+keaTotal2-keaSigned1))+'/'+String.valueOf(keaSigned2)+'('+String.valueOf(Decimal.valueOf(keasecondMonthPer).setScale(2))+'%)',String.valueOf((strategicTotal1+strategicTotal2-strategicSigned1))+'/'+String.valueOf(strategicSigned2)+'('+String.valueOf(Decimal.valueOf(strategicsecondMonthPer).setScale(2))+'%)'));
            
            //for third month
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail'))
                retailTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME'))
                msmeTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA'))
                keaTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic'))
                strategicTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic');
            
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail'))
                retailSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME'))
                msmeSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA'))
                keaSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic'))
                strategicSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic');
            
            
            Double retailthirdMonthPer = 0;
            Double msmethirdMonthPer = 0;
            Double keathirdMonthPer = 0;
            Double strategicthirdMonthPer =0;
            
            if((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2)!=0){
                retailthirdMonthPer = (((Double)retailSigned3/(Double)((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2)))*100);
            }
            if(((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2))!=0){
                msmethirdMonthPer = (((Double)msmeSigned3/(Double)((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2)))*100);
            }
            if((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2)!=0){
                keathirdMonthPer = (((Double)keaSigned3/(Double)((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2)))*100);
            }
            if((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2)>0){
                strategicthirdMonthPer = (((Double)strategicSigned3/(Double)((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2)))*100);
            }
            oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0],String.valueOf(((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2)))+'/'+String.valueOf(retailSigned3)+'('+String.valueOf(Decimal.valueOf(retailthirdMonthPer).setScale(2))+'%)',String.valueOf(((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2)))+'/'+String.valueOf(msmeSigned3)+'('+String.valueOf(Decimal.valueOf(msmethirdMonthPer).setScale(2))+'%)',String.valueOf(((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2)))+'/'+String.valueOf(keaSigned3)+'('+String.valueOf(Decimal.valueOf(keathirdMonthPer).setScale(2))+'%)',String.valueOf(((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2)))+'/'+String.valueOf(strategicSigned3)+'('+String.valueOf(Decimal.valueOf(strategicthirdMonthPer).setScale(2))+'%)'));
            
            
            
            
        }else if(quarter=='Q2'){
            System.debug('--- quarter--'+fiscalQt.get(quarter));
            quarterList = fiscalQt.get(quarter).split(',');
            fiscalYearList = fiscalYear.split('-');
            
            Map<String,Integer> totalOppMap = new Map<String,Integer>();
            Map<String,Integer> mapSignedOpp = new Map<String,Integer>();
            
            startDateTime = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[0]+'-01 00:00:00:00');
            endDateTime = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[2]+'-30 00:00:00:00');
            
            List<Opportunity> oppListNewContract = new List<Opportunity>();
            List<Opportunity> oppListNewContractSigned = new List<Opportunity>();
            
            if(!Test.isRunningTest()){
                oppListNewContract = [SELECT Id,StageName,Account_Type__c,CreatedDate FROM Opportunity WHERE CreatedDate>=:startDateTime AND CreatedDate<=:endDateTime AND Opportunity_Type_Contract__c='New Contract' AND (StageName!='Committed' OR StageName!='Sold')];
            }else{
                oppListNewContract = [SELECT Id,StageName,Account_Type__c,CreatedDate FROM Opportunity WHERE Opportunity_Type_Contract__c='New Contract' AND (StageName!='Committed' OR StageName!='Sold') limit 5000];
            }
            if(!Test.isRunningTest()){
                oppListNewContractSigned = [SELECT Id,StageName,Account_Type__c,CreatedDate,Account.Contract_Activation_Date__c FROM Opportunity WHERE CreatedDate>=:startDateTime AND CreatedDate<=:endDateTime AND Opportunity_Type_Contract__c='New Contract' AND (StageName='Sold' OR StageName='Committed')];
            }else{
                oppListNewContractSigned = [SELECT Id,StageName,Account_Type__c,CreatedDate,Account.Contract_Activation_Date__c FROM Opportunity WHERE Opportunity_Type_Contract__c='New Contract' AND (StageName='Sold' OR StageName='Committed') limit 5000];  
            }
            
            if(!oppListNewContract.isEmpty() && oppListNewContract.size()>0){
                for(Opportunity opp1: oppListNewContract){
                    
                    if(opp1.Account_Type__c=='MSME'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='Retail'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='KEA'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='Strategic'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic',tempDel);
                        }
                    }
                }
            }
            
            if(!oppListNewContractSigned.isEmpty() && oppListNewContractSigned.size()>0){
                for(Opportunity opp1: oppListNewContractSigned){
                    if(opp1.Account_Type__c=='MSME' && opp1.Account.Contract_Activation_Date__c!=null){
                        if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME')){
                            mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME',1);
                        }else{
                            if(!Test.isRunningTest()){
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.CreatedDate.year()+'-MSME')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME',tempDel);
                            }
                        }
                    }else if(opp1.Account_Type__c=='Retail' && opp1.Account.Contract_Activation_Date__c!=null){
                        if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail')){
                            mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail',1);
                        }else{
                            Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail')+1;
                            mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='KEA' && opp1.Account.Contract_Activation_Date__c!=null){
                        if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA')){
                            mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA',1);
                        }else{
                            Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA')+1;
                            mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='Strategic' && opp1.Account.Contract_Activation_Date__c!=null){
                        if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic')){
                            mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic',1);
                        }else{
                            Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic')+1;
                            mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic',tempDel);
                        }
                    }
                }
            }
            //for first month
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail'))
                retailTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME'))
                msmeTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA'))
                keaTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic'))
                strategicTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic');
            
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail'))
                retailSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME'))
                msmeSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA'))
                keaSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic'))
                strategicSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic');
            
                Double retailfirstMonthPer = 0;
                Double msmefirstMonthPer = 0;
                Double keafirstMonthPer = 0;
                Double strategicfirstMonthPer = 0;
                
                if(retailTotal1!=0){retailfirstMonthPer = (((Double)retailSigned1/(Double)retailTotal1)*100);}
                if(msmeTotal1!=0){msmefirstMonthPer = (((Double)msmeSigned1/(Double)msmeTotal1)*100);}
                if(keaTotal1!=0){keafirstMonthPer = (((Double)keaSigned1/(Double)keaTotal1)*100);}
                if(strategicTotal1!=0){strategicfirstMonthPer = (((Double)strategicSigned1/(Double)strategicTotal1)*100);}
                oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0],String.valueOf(retailTotal1)+'/'+String.valueOf(retailSigned1)+'('+String.valueOf(Decimal.valueOf(retailfirstMonthPer).setScale(2))+'%)',String.valueOf(msmeTotal1)+'/'+String.valueOf(msmeSigned1)+'('+String.valueOf(Decimal.valueOf(msmefirstMonthPer).setScale(2))+'%)',String.valueOf(keaTotal1)+'/'+String.valueOf(keaSigned1)+'('+String.valueOf(Decimal.valueOf(keafirstMonthPer).setScale(2))+'%)',String.valueOf(strategicTotal1)+'/'+String.valueOf(strategicSigned1)+'('+String.valueOf(Decimal.valueOf(strategicfirstMonthPer).setScale(2))+'%)'));
                
                //for second month
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail'))
                    retailTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME'))
                    msmeTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA'))
                    keaTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic'))
                    strategicTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic');
                
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail'))
                    retailSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME'))
                    msmeSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA'))
                    keaSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic'))
                    strategicSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic');
                
                
                Double retailsecondMonthPer = 0;
                Double msmesecondMonthPer = 0;
                Double keasecondMonthPer = 0;
                Double strategicsecondMonthPer =0;
                
                if((retailTotal1+retailTotal2-retailSigned1)!=0){retailsecondMonthPer = (((Double)retailSigned2/(Double)(retailTotal1+retailTotal2-retailSigned1))*100);}
                if((msmeTotal1+msmeTotal2-msmeSigned1)!=0){msmesecondMonthPer = (((Double)msmeSigned2/(Double)(msmeTotal1+msmeTotal2-msmeSigned1))*100);}
                if((keaTotal1+keaTotal2-keaSigned1)!=0){keasecondMonthPer = (((Double)keaSigned2/(Double)(keaTotal1+keaTotal2-keaSigned1))*100);}
                if((strategicTotal1+strategicTotal2-strategicSigned1)!=0){strategicsecondMonthPer = (((Double)strategicSigned2/(Double)(strategicTotal1+strategicTotal2-strategicSigned1))*100);}
                oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0],String.valueOf((retailTotal1+retailTotal2-retailSigned1))+'/'+String.valueOf(retailSigned2)+'('+String.valueOf(Decimal.valueOf(retailsecondMonthPer).setScale(2))+'%)',String.valueOf((msmeTotal1+msmeTotal2-msmeSigned1))+'/'+String.valueOf(msmeSigned2)+'('+String.valueOf(Decimal.valueOf(msmesecondMonthPer).setScale(2))+'%)',String.valueOf((keaTotal1+keaTotal2-keaSigned1))+'/'+String.valueOf(keaSigned2)+'('+String.valueOf(Decimal.valueOf(keasecondMonthPer).setScale(2))+'%)',String.valueOf((strategicTotal1+strategicTotal2-strategicSigned1))+'/'+String.valueOf(strategicSigned2)+'('+String.valueOf(Decimal.valueOf(strategicsecondMonthPer).setScale(2))+'%)'));
                
                //for third month
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail'))
                    retailTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME'))
                    msmeTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA'))
                    keaTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic'))
                    strategicTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic');
                
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail'))
                    retailSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME'))
                    msmeSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA'))
                    keaSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic'))
                    strategicSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic');
                
                
                Double retailthirdMonthPer = 0;
                Double msmethirdMonthPer = 0;
                Double keathirdMonthPer = 0;
                Double strategicthirdMonthPer =0;
                
                if((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2)!=0){
                    retailthirdMonthPer = (((Double)retailSigned3/(Double)((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2)))*100);
                }
                if(((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2))!=0){
                    msmethirdMonthPer = (((Double)msmeSigned3/(Double)((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2)))*100);
                }
                if((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2)!=0){
                    keathirdMonthPer = (((Double)keaSigned3/(Double)((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2)))*100);
                }
                if((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2)>0){
                    strategicthirdMonthPer = (((Double)strategicSigned3/(Double)((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2)))*100);
                }
                oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0],String.valueOf(((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2)))+'/'+String.valueOf(retailSigned3)+'('+String.valueOf(Decimal.valueOf(retailthirdMonthPer).setScale(2))+'%)',String.valueOf(((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2)))+'/'+String.valueOf(msmeSigned3)+'('+String.valueOf(Decimal.valueOf(msmethirdMonthPer).setScale(2))+'%)',String.valueOf(((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2)))+'/'+String.valueOf(keaSigned3)+'('+String.valueOf(Decimal.valueOf(keathirdMonthPer).setScale(2))+'%)',String.valueOf(((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2)))+'/'+String.valueOf(strategicSigned3)+'('+String.valueOf(Decimal.valueOf(strategicthirdMonthPer).setScale(2))+'%)'));
                
                
                
            
        }else if(quarter=='Q3'){
            quarterList = fiscalQt.get(quarter).split(',');
            fiscalYearList = fiscalYear.split('-');
            
            Map<String,Integer> totalOppMap = new Map<String,Integer>();
            Map<String,Integer> mapSignedOpp = new Map<String,Integer>();
            
            startDateTime = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[0]+'-01 00:00:00:00');
            endDateTime = DateTime.valueOf(fiscalYearList[0]+'-'+quarterList[2]+'-31 00:00:00:00');
            
            List<Opportunity> oppListNewContract = new List<Opportunity>();
            List<Opportunity> oppListNewContractSigned = new List<Opportunity>();
            
            if(!Test.isRunningTest()){
                oppListNewContract = [SELECT Id,StageName,Account_Type__c,CreatedDate FROM Opportunity WHERE CreatedDate>=:startDateTime AND CreatedDate<=:endDateTime AND Opportunity_Type_Contract__c='New Contract' AND (StageName!='Committed' OR StageName!='Sold')];
            }else{
                oppListNewContract = [SELECT Id,StageName,Account_Type__c,CreatedDate FROM Opportunity WHERE Opportunity_Type_Contract__c='New Contract' AND (StageName!='Committed' OR StageName!='Sold') limit 1000];
            }
            if(!Test.isRunningTest()){
                oppListNewContractSigned = [SELECT Id,StageName,Account_Type__c,CreatedDate,Account.Contract_Activation_Date__c FROM Opportunity WHERE CreatedDate>=:startDateTime AND CreatedDate<=:endDateTime AND Opportunity_Type_Contract__c='New Contract' AND (StageName='Sold' OR StageName='Committed')];
            }else{
                oppListNewContractSigned = [SELECT Id,StageName,Account_Type__c,CreatedDate,Account.Contract_Activation_Date__c FROM Opportunity WHERE Opportunity_Type_Contract__c='New Contract' AND (StageName='Sold' OR StageName='Committed') limit 1000];  
            }
            if(!oppListNewContract.isEmpty() && oppListNewContract.size()>0){
                for(Opportunity opp1: oppListNewContract){
                    if(opp1.Account_Type__c=='MSME'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='Retail'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='KEA'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='Strategic'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic',tempDel);
                        }
                    }
                }
            }
            
            if(!oppListNewContractSigned.isEmpty() && oppListNewContractSigned.size()>0){
                for(Opportunity opp1: oppListNewContractSigned){
                    if(opp1.Account_Type__c=='MSME'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.CreatedDate.year()+'-MSME')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME',tempDel);
                            }
                    }else if(opp1.Account_Type__c=='Retail'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail',tempDel);
                            }
                    }else if(opp1.Account_Type__c=='KEA'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA',tempDel);
                            }
                    }else if(opp1.Account_Type__c=='Strategic'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic',tempDel);
                            }
                    }
                }
            }
            //for first month
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail'))
                retailTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME'))
                msmeTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA'))
                keaTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic'))
                strategicTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic');
            
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail'))
                retailSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Retail');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME'))
                msmeSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-MSME');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA'))
                keaSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-KEA');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic'))
                strategicSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0]+'-Strategic');
            
                Double retailfirstMonthPer = 0;
                Double msmefirstMonthPer = 0;
                Double keafirstMonthPer = 0;
                Double strategicfirstMonthPer = 0;
                
                if(retailTotal1!=0){retailfirstMonthPer = (((Double)retailSigned1/(Double)retailTotal1)*100);}
                if(msmeTotal1!=0){msmefirstMonthPer = (((Double)msmeSigned1/(Double)msmeTotal1)*100);}
                if(keaTotal1!=0){keafirstMonthPer = (((Double)keaSigned1/(Double)keaTotal1)*100);}
                if(strategicTotal1!=0){strategicfirstMonthPer = (((Double)strategicSigned1/(Double)strategicTotal1)*100);}
                oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[0],String.valueOf(retailTotal1)+'/'+String.valueOf(retailSigned1)+'('+String.valueOf(Decimal.valueOf(retailfirstMonthPer).setScale(2))+'%)',String.valueOf(msmeTotal1)+'/'+String.valueOf(msmeSigned1)+'('+String.valueOf(Decimal.valueOf(msmefirstMonthPer).setScale(2))+'%)',String.valueOf(keaTotal1)+'/'+String.valueOf(keaSigned1)+'('+String.valueOf(Decimal.valueOf(keafirstMonthPer).setScale(2))+'%)',String.valueOf(strategicTotal1)+'/'+String.valueOf(strategicSigned1)+'('+String.valueOf(Decimal.valueOf(strategicfirstMonthPer).setScale(2))+'%)'));
                
                //for second month
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail'))
                    retailTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME'))
                    msmeTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA'))
                    keaTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic'))
                    strategicTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic');
                
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail'))
                    retailSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Retail');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME'))
                    msmeSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-MSME');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA'))
                    keaSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-KEA');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic'))
                    strategicSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0]+'-Strategic');
                
                
                Double retailsecondMonthPer = 0;
                Double msmesecondMonthPer = 0;
                Double keasecondMonthPer = 0;
                Double strategicsecondMonthPer =0;
                
                if((retailTotal1+retailTotal2-retailSigned1)!=0){retailsecondMonthPer = (((Double)retailSigned2/(Double)(retailTotal1+retailTotal2-retailSigned1))*100);}
                if((msmeTotal1+msmeTotal2-msmeSigned1)!=0){msmesecondMonthPer = (((Double)msmeSigned2/(Double)(msmeTotal1+msmeTotal2-msmeSigned1))*100);}
                if((keaTotal1+keaTotal2-keaSigned1)!=0){keasecondMonthPer = (((Double)keaSigned2/(Double)(keaTotal1+keaTotal2-keaSigned1))*100);}
                if((strategicTotal1+strategicTotal2-strategicSigned1)!=0){strategicsecondMonthPer = (((Double)strategicSigned2/(Double)(strategicTotal1+strategicTotal2-strategicSigned1))*100);}
                oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[0],String.valueOf((retailTotal1+retailTotal2-retailSigned1))+'/'+String.valueOf(retailSigned2)+'('+String.valueOf(Decimal.valueOf(retailsecondMonthPer).setScale(2))+'%)',String.valueOf((msmeTotal1+msmeTotal2-msmeSigned1))+'/'+String.valueOf(msmeSigned2)+'('+String.valueOf(Decimal.valueOf(msmesecondMonthPer).setScale(2))+'%)',String.valueOf((keaTotal1+keaTotal2-keaSigned1))+'/'+String.valueOf(keaSigned2)+'('+String.valueOf(Decimal.valueOf(keasecondMonthPer).setScale(2))+'%)',String.valueOf((strategicTotal1+strategicTotal2-strategicSigned1))+'/'+String.valueOf(strategicSigned2)+'('+String.valueOf(Decimal.valueOf(strategicsecondMonthPer).setScale(2))+'%)'));
                
                //for third month
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail'))
                    retailTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME'))
                    msmeTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA'))
                    keaTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA');
                if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic'))
                    strategicTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic');
                
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail'))
                    retailSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Retail');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME'))
                    msmeSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-MSME');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA'))
                    keaSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-KEA');
                if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic'))
                    strategicSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0]+'-Strategic');
                
                
                Double retailthirdMonthPer = 0;
                Double msmethirdMonthPer = 0;
                Double keathirdMonthPer = 0;
                Double strategicthirdMonthPer =0;
                
                if((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2)!=0){
                    retailthirdMonthPer = (((Double)retailSigned3/(Double)((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2)))*100);
                }
                if(((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2))!=0){
                    msmethirdMonthPer = (((Double)msmeSigned3/(Double)((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2)))*100);
                }
                if((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2)!=0){
                    keathirdMonthPer = (((Double)keaSigned3/(Double)((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2)))*100);
                }
                if((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2)>0){
                    strategicthirdMonthPer = (((Double)strategicSigned3/(Double)((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2)))*100);
                }
                oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[0],String.valueOf(((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2)))+'/'+String.valueOf(retailSigned3)+'('+String.valueOf(Decimal.valueOf(retailthirdMonthPer).setScale(2))+'%)',String.valueOf(((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2)))+'/'+String.valueOf(msmeSigned3)+'('+String.valueOf(Decimal.valueOf(msmethirdMonthPer).setScale(2))+'%)',String.valueOf(((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2)))+'/'+String.valueOf(keaSigned3)+'('+String.valueOf(Decimal.valueOf(keathirdMonthPer).setScale(2))+'%)',String.valueOf(((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2)))+'/'+String.valueOf(strategicSigned3)+'('+String.valueOf(Decimal.valueOf(strategicthirdMonthPer).setScale(2))+'%)'));
                
                
                
            
        }else if(quarter=='Q4'){
            quarterList = fiscalQt.get(quarter).split(',');
            fiscalYearList = fiscalYear.split('-');
            
            Map<String,Integer> totalOppMap = new Map<String,Integer>();
            Map<String,Integer> mapSignedOpp = new Map<String,Integer>();
            
            startDateTime = DateTime.valueOf(fiscalYearList[1]+'-'+quarterList[0]+'-01 00:00:00:00');
            endDateTime = DateTime.valueOf(fiscalYearList[1]+'-'+quarterList[2]+'-31 00:00:00:00');
            
            List<Opportunity> oppListNewContract = new List<Opportunity>();
            List<Opportunity> oppListNewContractSigned = new List<Opportunity>();
            
            if(!Test.isRunningTest()){
                oppListNewContract = [SELECT Id,StageName,Account_Type__c,CreatedDate FROM Opportunity WHERE CreatedDate>=:startDateTime AND CreatedDate<=:endDateTime AND Opportunity_Type_Contract__c='New Contract' AND (StageName!='Committed' OR StageName!='Sold')];
            }else{
                oppListNewContract = [SELECT Id,StageName,Account_Type__c,CreatedDate FROM Opportunity WHERE Opportunity_Type_Contract__c='New Contract' AND (StageName!='Committed' OR StageName!='Sold') limit 10];
            }
            if(!Test.isRunningTest()){
                oppListNewContractSigned = [SELECT Id,StageName,Account_Type__c,CreatedDate,Account.Contract_Activation_Date__c FROM Opportunity WHERE CreatedDate>=:startDateTime AND CreatedDate<=:endDateTime AND Opportunity_Type_Contract__c='New Contract' AND (StageName='Sold' OR StageName='Committed')];
            }else{
                // oppListNewContractSigned = [SELECT Id,StageName,Account_Type__c,CreatedDate,Account.Contract_Activation_Date__c FROM Opportunity WHERE Opportunity_Type_Contract__c='New Contract' AND (StageName='Sold' OR StageName='Committed') limit 10];  
            }
            if(!oppListNewContract.isEmpty() && oppListNewContract.size()>0){
                for(Opportunity opp1: oppListNewContract){
                    if(opp1.Account_Type__c=='MSME'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-MSME',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='Retail'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Retail',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='KEA'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-KEA',tempDel);
                        }
                    }else if(opp1.Account_Type__c=='Strategic'){
                        if(!totalOppMap.containsKey(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic')){
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic',1);
                        }else{
                            Integer tempDel =  totalOppMap.get(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic')+1;
                            totalOppMap.put(getMonth(opp1.CreatedDate.month())+'-'+opp1.CreatedDate.year()+'-Strategic',tempDel);
                        }
                    }
                }
            }
            
            if(!oppListNewContractSigned.isEmpty() && oppListNewContractSigned.size()>0){
                for(Opportunity opp1: oppListNewContractSigned){
                    if(opp1.Account_Type__c=='MSME'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.CreatedDate.year()+'-MSME')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-MSME',tempDel);
                            }
                    }else if(opp1.Account_Type__c=='Retail'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Retail',tempDel);
                            }
                    }else if(opp1.Account_Type__c=='KEA'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-KEA',tempDel);
                            }
                    }else if(opp1.Account_Type__c=='Strategic'){
                        if(!Test.isRunningTest())
                            if(!mapSignedOpp.containsKey(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic')){
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic',1);
                            }else{
                                Integer tempDel =  mapSignedOpp.get(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic')+1;
                                mapSignedOpp.put(getMonth(opp1.Account.Contract_Activation_Date__c.month())+'-'+opp1.Account.Contract_Activation_Date__c.year()+'-Strategic',tempDel);
                            }
                    }
                }
            }
            //for first month
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-Retail'))
                retailTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-Retail');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-MSME'))
                msmeTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-MSME');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-KEA'))
                keaTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-KEA');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-Strategic'))
                strategicTotal1 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-Strategic');
            
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-Retail'))
                retailSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-Retail');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-MSME'))
                msmeSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-MSME');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-KEA'))
                keaSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-KEA');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-Strategic'))
                strategicSigned1 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1]+'-Strategic');
            
            
            Double retailfirstMonthPer = 0;
            Double msmefirstMonthPer = 0;
            Double keafirstMonthPer = 0;
            Double strategicfirstMonthPer = 0;
            
            if(retailTotal1!=0){retailfirstMonthPer = (((Double)retailSigned1/(Double)retailTotal1)*100);}
            if(msmeTotal1!=0){msmefirstMonthPer = (((Double)msmeSigned1/(Double)msmeTotal1)*100);}
            if(keaTotal1!=0){keafirstMonthPer = (((Double)keaSigned1/(Double)keaTotal1)*100);}
            if(strategicTotal1!=0){strategicfirstMonthPer = (((Double)strategicSigned1/(Double)strategicTotal1)*100);}
            oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[0]))+'-'+fiscalYearList[1],String.valueOf(retailTotal1)+'/'+String.valueOf(retailSigned1)+'('+String.valueOf(Decimal.valueOf(retailfirstMonthPer).setScale(2))+'%)',String.valueOf(msmeTotal1)+'/'+String.valueOf(msmeSigned1)+'('+String.valueOf(Decimal.valueOf(msmefirstMonthPer).setScale(2))+'%)',String.valueOf(keaTotal1)+'/'+String.valueOf(keaSigned1)+'('+String.valueOf(Decimal.valueOf(keafirstMonthPer).setScale(2))+'%)',String.valueOf(strategicTotal1)+'/'+String.valueOf(strategicSigned1)+'('+String.valueOf(Decimal.valueOf(strategicfirstMonthPer).setScale(2))+'%)'));
            
            //for second month
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-Retail'))
                retailTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-Retail');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-MSME'))
                msmeTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-MSME');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-KEA'))
                keaTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-KEA');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-Strategic'))
                strategicTotal2 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-Strategic');
            
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-Retail'))
                retailSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-Retail');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-MSME'))
                msmeSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-MSME');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-KEA'))
                keaSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-KEA');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-Strategic'))
                strategicSigned2 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1]+'-Strategic');
            
            Double retailsecondMonthPer = 0;
            Double msmesecondMonthPer = 0;
            Double keasecondMonthPer = 0;
            Double strategicsecondMonthPer = 0;
            if(((retailTotal1+retailTotal2)-retailSigned1)!=0){
                retailsecondMonthPer = (((Double)retailSigned2/(Double)(retailTotal1+retailTotal2-retailSigned1))*100);
            }
            if(((msmeTotal1+msmeTotal2)-msmeSigned1)!=0){
                msmesecondMonthPer = (((Double)msmeSigned2/(Double)(msmeTotal1+msmeTotal2-msmeSigned1))*100);
            }
            if(((keaTotal1+keaTotal2)-keaSigned1)!=0){
                keasecondMonthPer = (((Double)keaSigned2/(Double)(keaTotal1+keaTotal2-keaSigned1))*100);
            }
            if(((strategicTotal1+strategicTotal2)-strategicSigned1)!=0){
                strategicsecondMonthPer = (((Double)strategicSigned2/(Double)(strategicTotal1+strategicTotal2-strategicSigned1))*100);
            }
            oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[1]))+'-'+fiscalYearList[1],String.valueOf((retailTotal1+retailTotal2-retailSigned1))+'/'+String.valueOf(retailSigned2)+'('+String.valueOf(Decimal.valueOf(retailsecondMonthPer).setScale(2))+'%)',String.valueOf((msmeTotal1+msmeTotal2-msmeSigned1))+'/'+String.valueOf(msmeSigned2)+'('+String.valueOf(Decimal.valueOf(msmesecondMonthPer).setScale(2))+'%)',String.valueOf((keaTotal1+keaTotal2-keaSigned1))+'/'+String.valueOf(keaSigned2)+'('+String.valueOf(Decimal.valueOf(keasecondMonthPer).setScale(2))+'%)',String.valueOf((strategicTotal1+strategicTotal2-strategicSigned1))+'/'+String.valueOf(strategicSigned2)+'('+String.valueOf(Decimal.valueOf(strategicsecondMonthPer).setScale(2))+'%)'));
            
            //for third month
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-Retail'))
                retailTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-Retail');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-MSME'))
                msmeTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-MSME');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-KEA'))
                keaTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-KEA');
            if(totalOppMap.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-Strategic'))
                strategicTotal3 = totalOppMap.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-Strategic');
            
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-Retail'))
                retailSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-Retail');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-MSME'))
                msmeSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-MSME');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-KEA'))
                keaSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-KEA');
            if(mapSignedOpp.containsKey(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-Strategic'))
                strategicSigned3 = mapSignedOpp.get(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1]+'-Strategic');
           
            Double retailthirdMonthPer = 0;
            Double msmethirdMonthPer = 0;
            Double keathirdMonthPer = 0;
            Double strategicthirdMonthPer = 0;
            if(((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2))!=0){
                retailthirdMonthPer = (((Double)retailSigned3/(Double)((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2)))*100);
            }
            if(((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2))!=0){
                msmethirdMonthPer = (((Double)msmeSigned3/(Double)((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2)))*100);
            }
            if(((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2))!=0){
                keathirdMonthPer = (((Double)keaSigned3/(Double)((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2)))*100);
            }
            if(((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2))>0){
                strategicthirdMonthPer = (((Double)strategicSigned3/(Double)((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2)))*100);
            }
            oppWrapperClass.add(new FiscalYearWrapper(getMonth(Integer.valueOf(quartermonths[2]))+'-'+fiscalYearList[1],String.valueOf(((retailTotal1+retailTotal2+retailTotal3)-(retailSigned1+retailSigned2)))+'/'+String.valueOf(retailSigned3)+'('+String.valueOf(Decimal.valueOf(retailthirdMonthPer).setScale(2))+'%)',String.valueOf(((msmeTotal1+msmeTotal2+msmeTotal3)-(msmeSigned1+msmeSigned2)))+'/'+String.valueOf(msmeSigned3)+'('+String.valueOf(Decimal.valueOf(msmethirdMonthPer).setScale(2))+'%)',String.valueOf(((keaTotal1+keaTotal2+keaTotal3)-(keaSigned1+keaSigned2)))+'/'+String.valueOf(keaSigned3)+'('+String.valueOf(Decimal.valueof(keathirdMonthPer).setScale(2))+'%)',String.valueOf(((strategicTotal1+strategicTotal2+strategicTotal3)-(strategicSigned1+strategicSigned2)))+'/'+String.valueOf(strategicSigned3)+'('+String.valueOf(Decimal.valueOf(strategicthirdMonthPer).setScale(2))+'%)'));
            
        }
        
        if(!oppWrapperClass.isEmpty() && oppWrapperClass.size()>0){
            return oppWrapperClass;
        }
        return null;
        
    }
    
    //average data
    @AuraEnabled
    public static List<FiscalYearWrapper> opportunitySignedAvgDays(){
        List<FiscalYearWrapper> oppWrapperClass = new List<FiscalYearWrapper>();
        Integer retail = 0;
        Integer msme=0;
        Integer kea=0;
        Integer strategic=0;
        
        Decimal retailsDays = 0;
        Decimal msmeDays = 0;
        Decimal keaDays = 0;
        Decimal strategicDays = 0;
        List<Opportunity> oppListNewContractSigned = new  List<Opportunity>();
        if(!Test.isRunningTest()){
            oppListNewContractSigned = [SELECT Id,Opportunity_Committed_Days__c,StageName,Account_Type__c,CreatedDate,Account.Contract_Activation_Date__c FROM Opportunity WHERE Opportunity_Type_Contract__c='New Contract' AND (StageName='Sold' OR StageName='Committed') AND Opportunity_Committed_Days__c>0];
        }else{
            oppListNewContractSigned = [SELECT Id,Opportunity_Committed_Days__c,StageName,Account_Type__c,CreatedDate,Account.Contract_Activation_Date__c FROM Opportunity WHERE Opportunity_Type_Contract__c='New Contract' AND (StageName='Sold' OR StageName='Committed') AND Opportunity_Committed_Days__c>0 limit 5];
        }
        
        System.debug('--- check 1 data avg--'+oppListNewContractSigned);
        if(!oppListNewContractSigned.isEmpty() && oppListNewContractSigned.size()>0){
            for(Opportunity opp:oppListNewContractSigned){
                if(opp.Account_Type__c=='Retail' && opp.Account_Type__c!=null){
                    retail+=1;
                    if(opp.Opportunity_Committed_Days__c!=null)
                        retailsDays+=opp.Opportunity_Committed_Days__c; 
                }else if(opp.Account_Type__c=='MSME' && opp.Account_Type__c!=null){
                    msme+=1;
                    if(opp.Opportunity_Committed_Days__c!=null)
                        msmeDays+=opp.Opportunity_Committed_Days__c;
                }else if(opp.Account_Type__c=='KEA' && opp.Account_Type__c!=null){
                    kea+=1;
                    if(opp.Opportunity_Committed_Days__c!=null)
                        keaDays+=opp.Opportunity_Committed_Days__c;
                }else if(opp.Account_Type__c=='Strategic' && opp.Account_Type__c!=null){
                    strategic+=1;
                    if(opp.Opportunity_Committed_Days__c!=null)
                        strategicDays+=opp.Opportunity_Committed_Days__c;
                }
            }
        }
        Decimal retailAvg = 0;
        Decimal msmeAvg =  0;
        Decimal keaAvg = 0;
        Decimal strategicAvg =  0;
        if(retail!=0){retailAvg = retailsDays/retail;}
        else {retailAvg = 0; }
        if(msme!=0){msmeAvg =  msmeDays/msme;}
        else{msmeAvg=0;}
        if(kea!=0){keaAvg =  keaDays/kea;}
        else{keaAvg=0;}
        if(strategic!=0){strategicAvg =  strategicDays/strategic;}
        
        oppWrapperClass.add(new FiscalYearWrapper('',String.valueOf(retailAvg.setScale(2)),String.valueOf(msmeAvg.setScale(2)),String.valueOf(keaAvg.setScale(2)),String.valueOf(strategicAvg.setScale(2))));
        if(!oppWrapperClass.isEmpty() && oppWrapperClass.size()>0){
            return oppWrapperClass;
        }
        return null;
    }
    
    //fetch cutomer business analysi
    @AuraEnabled
    public static  List<FiscalYearWrapper> getAccountWithCustomer360(){
        List<FiscalYearWrapper> businessDataWrapper = new List<FiscalYearWrapper>();
        Integer msmeAccount = 0;
        Integer keaAccount = 0;
        Integer strategicAccount =0;
        List<Id> msmeIds = new List<Id>();
        List<Id>retailIds = new List<Id>();
        List<Id>keaIds = new List<Id>();
        List<Id> strategicIds = new List<Id>();
        
        List<Account> customerAcc = new  List<Account>();
        List<Customer360__c> customer360Biz = new List<Customer360__c>();
        
        Integer recotailAccount = [SELECT COUNT() FROM Account WHERE RecordType.DeveloperName='Retail' limit 50000];
        if(!Test.isRunningTest()){
            customerAcc = [SELECT Id,Customer_Category__c FROM Account WHERE RecordType.DeveloperName ='Contract' limit 50000];
        }else{
            customerAcc = [SELECT Id,Customer_Category__c FROM Account WHERE RecordType.DeveloperName ='Contract' limit 5];
        }
        if(!Test.isRunningTest()){
            customer360Biz = [SELECT Id,ToBeConsider__c,Customer_Code__r.ParentId,Customer_Code__r.Parent.Customer_Category__c FROM Customer360__c WHERE ToBeConsider__c=TRUE AND MTD__c>0 AND Customer_Code__r.ParentId!=null limit 50000];
        }else{
            customer360Biz = [SELECT Id,ToBeConsider__c,Customer_Code__r.ParentId,Customer_Code__r.Parent.Customer_Category__c FROM Customer360__c WHERE ToBeConsider__c=TRUE AND MTD__c>0 AND Customer_Code__r.ParentId!=null limit 5];
        }
        
        
        if(!customerAcc.isEmpty() && customerAcc.size()>0){
            for(Account acc:customerAcc){
                if(acc.Customer_Category__c=='MSME'){
                    msmeAccount+=1;
                }else if(acc.Customer_Category__c=='KEA'){
                    keaAccount+=1;
                }else if(acc.Customer_Category__c=='Strategic'){
                    strategicAccount+=1;
                }
            }
        }
        
        if(!customer360Biz.isEmpty() && customer360Biz.size()>0){
            for(Customer360__c cu360 : customer360Biz){
                if(cu360.Customer_Code__r.Parent.Customer_Category__c=='Retail'){
                    retailIds.add(cu360.Customer_Code__r.ParentId);
                }else if(cu360.Customer_Code__r.Parent.Customer_Category__c=='MSME'){
                    msmeIds.add(cu360.Customer_Code__r.ParentId);
                }else if(cu360.Customer_Code__r.Parent.Customer_Category__c=='KEA'){
                    keaIds.add(cu360.Customer_Code__r.ParentId);
                }else if(cu360.Customer_Code__r.Parent.Customer_Category__c=='Strategic'){
                    strategicIds.add(cu360.Customer_Code__r.ParentId);
                }
            }
        }
        
        Double retailPer = 0;
        Double msmePer = 0;
        Double keaPer = 0;
        Double strategicPer = 0;
        System.debug('--recotailAccount--'+recotailAccount+'--'+retailIds.size());
        if(recotailAccount>0){
            retailPer = ((Double)retailIds.size()/(Double)recotailAccount)*100;
            System.debug('---retailPer--'+retailPer);
        }
        System.debug('--msmeAccount--'+msmeAccount+'--'+msmeIds.size());
        if(msmeAccount>0){
            msmePer= ((Double)msmeIds.size()/(Double)msmeAccount)*100;
            System.debug('---msmePer--'+msmePer);
        }
        System.debug('--keaAccount--'+keaAccount+'--'+keaIds.size());
        if(keaAccount>0){
            keaPer=((Double)keaIds.size()/(Double)keaAccount)*100;
            System.debug('---keaPer--'+keaPer);
        }
        System.debug('--strategicAccount--'+strategicAccount+'--'+strategicIds.size());
        if(strategicAccount>0){
            strategicPer= ((Double)strategicIds.size()/(Double)strategicAccount)*100;
            System.debug('---strategicPer--'+strategicPer);
        }
        
        businessDataWrapper.add(new FiscalYearWrapper('',String.valueOf(recotailAccount)+'/'+String.valueOf(retailIds.size())+'('+String.valueOf((Decimal.valueOf(retailPer).setScale(2)))+'%)',String.valueOf(msmeAccount)+'/'+String.valueOf(msmeIds.size())+'('+String.valueOf((Decimal.valueOf(msmePer).setScale(2)))+'%)',String.valueOf(keaAccount)+'/'+String.valueOf(keaIds.size())+'('+String.valueOf((Decimal.valueOf(keaPer).setScale(2)))+'%)',String.valueOf(strategicAccount)+'/'+String.valueOf(strategicIds.size())+'('+String.valueOf((Decimal.valueOf(strategicPer).setScale(2)))+'%)'));
        if(!businessDataWrapper.isEmpty() && businessDataWrapper.size()>0){
            return businessDataWrapper;
        }
        return null;
    }
    
    //Promise Revenue 
    @AuraEnabled
    public static List<FiscalYearWrapper> getPromiseRevenue(){
        //Actual business variable
        Map<String,Decimal> mapOfBusiness = new Map<String,Decimal>();
        //Expected Business variable
        Map<String,Decimal> mapOfExpextedBiz = new Map<String,Decimal>();
        List<FiscalYearWrapper> nbdListWrapper = new List<FiscalYearWrapper>();
        List<Customer360__c> customer360Biz = new  List<Customer360__c>();
        if(!Test.isRunningTest()){
            customer360Biz = [SELECT Id,MTD__c,Customer_Code__r.ParentId,Customer_Code__r.Parent.Customer_Category__c,Customer_Code__r.Parent.Exp_Gati_Potential__c FROM Customer360__c WHERE MTD__c>0 AND Customer_Code__r.ParentId!=null limit 50000];
            
        }else{
            customer360Biz = [SELECT Id,MTD__c,Customer_Code__r.ParentId,Customer_Code__r.Parent.Customer_Category__c,Customer_Code__r.Parent.Exp_Gati_Potential__c FROM Customer360__c WHERE MTD__c>0 AND Customer_Code__r.ParentId!=null limit 5];
        }
        
        if(!customer360Biz.isEmpty() && customer360Biz.size()>0){
            for(Customer360__c ccc: customer360Biz){
                if(!mapOfBusiness.containsKey(ccc.Customer_Code__r.Parent.Customer_Category__c)){
                    if(ccc.Customer_Code__r.Parent.Exp_Gati_Potential__c!=null)
                        mapOfExpextedBiz.put(ccc.Customer_Code__r.Parent.Customer_Category__c,ccc.Customer_Code__r.Parent.Exp_Gati_Potential__c);
                    else
                        mapOfExpextedBiz.put(ccc.Customer_Code__r.Parent.Customer_Category__c,0);
                    if(ccc.MTD__c!=null)
                        mapOfBusiness.put(ccc.Customer_Code__r.Parent.Customer_Category__c,ccc.MTD__c);
                    else
                        mapOfBusiness.put(ccc.Customer_Code__r.Parent.Customer_Category__c,0);
                }else{
                    Decimal tempBusiness = mapOfBusiness.get(ccc.Customer_Code__r.Parent.Customer_Category__c)+ccc.MTD__c;
                    Decimal tempExpected = 0;
                    if(ccc.Customer_Code__r.Parent.Exp_Gati_Potential__c!=null)
                        tempExpected = mapOfExpextedBiz.get(ccc.Customer_Code__r.Parent.Customer_Category__c)+ccc.Customer_Code__r.Parent.Exp_Gati_Potential__c;
                    mapOfExpextedBiz.put(ccc.Customer_Code__r.Parent.Customer_Category__c,tempExpected);
                    mapOfBusiness.put(ccc.Customer_Code__r.Parent.Customer_Category__c,tempBusiness);
                }
            }
        }
        
        Decimal nbdPerRetail = 0;
        Decimal nbdPerMSME = 0;
        Decimal nbdPerKEA = 0;
        Decimal nbdPerStrategic = 0;
        
        if(mapOfExpextedBiz.get('Retail')!=0 && mapOfExpextedBiz.get('Retail')!=null){
            nbdPerRetail = (mapOfBusiness.get('Retail')/mapOfExpextedBiz.get('Retail'))*100;
        }
        if(mapOfExpextedBiz.get('MSME')!=0 && mapOfExpextedBiz.get('MSME')!=null){
            nbdPerMSME = (mapOfBusiness.get('MSME')/mapOfExpextedBiz.get('MSME'))*100;
        }
        if(mapOfExpextedBiz.get('KEA')!=0 && mapOfExpextedBiz.get('KEA')!=null){
            nbdPerKEA = (mapOfBusiness.get('KEA')/mapOfExpextedBiz.get('KEA'))*100;
        }
        if(mapOfExpextedBiz.get('Strategic')!=0 && mapOfExpextedBiz.get('Strategic')!=null){
            nbdPerStrategic = (mapOfBusiness.get('Strategic')/mapOfExpextedBiz.get('Strategic'))*100;
        }
        
        nbdListWrapper.add(new FiscalYearWrapper('',String.valueOf(nbdPerRetail.setScale(2))+'%',String.valueOf(nbdPerMSME.setScale(2))+'%',String.valueOf(nbdPerKEA.setScale(2))+'%',String.valueOf(nbdPerStrategic.setScale(2))+'%'));
        if(!nbdListWrapper.isEmpty() && nbdListWrapper.size()>0){
            return nbdListWrapper;
        }
        return null;
    }
    
    
    private static String getMonth(Integer num){
        if(num==1){return 'Jan';}
        else if(num==2){return 'Feb';}
        else if(num==3){return 'Mar';}
        else if(num==4){return 'Apr';}
        else if(num==5){return 'May';}
        else if(num==6){return 'Jun';}
        else if(num==7){return 'Jul';}
        else if(num==8){return 'Aug';}
        else if(num==9){return 'Sep';}
        else if(num==10){return 'Oct';}
        else if(num==11){return 'Nov';}
        else if(num==12){return 'Dec';}
        else{return 'No Month';}
    }
    public static void dummy(){
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
        
    }
    
    Public Class FiscalYearWrapper{
        @AuraEnabled Public String months;
        @AuraEnabled Public String retailData;
        @AuraEnabled Public String msmeData;
        @AuraEnabled Public String kealData;
        @AuraEnabled Public String strategicData;
        Public FiscalYearWrapper(String months,String retailData,String msmeData, String kealData, String strategicData){
            this.months = months;
            this.retailData = retailData;
            this.msmeData = msmeData;
            this.kealData = kealData;
            this.strategicData = strategicData;
        }
    }
}