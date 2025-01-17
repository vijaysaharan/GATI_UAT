public class CreateEventHandler {
    
    public static void insertEventHelper(List<Customer_Connect__c> newList){
        List<Event> insertEvent = new List<Event>();
        Set<Id> accSetIds = new Set<Id>();
        Set<Id> leadSetIds = new Set<Id>();
        Set<DateTime> startDate = new Set<DateTime>();
        Set<DateTime> endDate = new Set<DateTime>();
        Boolean createEvent = false;
        for(Customer_Connect__c acc : newList){
            startDate.add(acc.Visit_Start_Date__c);
            endDate.add(acc.Visit_End_Date__c);
            if(acc.Customer_Code__c!=null){
                accSetIds.add(acc.Customer_Code__c);
            }if(acc.Lead__c!=null){
                leadSetIds.add(acc.Lead__c);
            }
        }
        Map<Id,Account> mapOfAccount = new Map<ID, Account>([SELECT Id, Name FROM Account WHERE Id IN:accSetIds]);
        Map<Id,Lead> mapOfLead = new Map<ID, Lead>([SELECT Id, Name FROM Lead WHERE Id IN:leadSetIds]);  
        List<Event> eventListOnnasisOfUser = [SELECT Id,OwnerId,StartDateTime,EndDateTime FROM Event WHERE OwnerId=:UserInfo.getUserId()];
        if(!eventListOnnasisOfUser.isEmpty() && eventListOnnasisOfUser.size()>0){
            for(Event evt:eventListOnnasisOfUser){
                for(Customer_Connect__c err:newList){
                    if(evt.StartDateTime < err.Visit_End_Date__c && evt.EndDateTime > err.Visit_Start_Date__c){
                        err.Visit_Start_Date__c.addError('another meeting already scheduled at same time');
                        createEvent = true;
                    }
                }
            }
        }
        
        if(createEvent==false){
        for(Customer_Connect__c cc : newList){
            Event ev = new Event();
            if(cc.Customer_Code__c!=null){
                ev.Subject = mapOfAccount.get(cc.Customer_Code__c).Name+':'+cc.Call_Type__c+':'+cc.Sub_Type__c;
            }else if(cc.Lead__c!=null){
                ev.Subject = mapOfLead.get(cc.Lead__c).Name+':'+cc.Call_Type__c+':'+cc.Sub_Type__c;
            }else{
                ev.Subject = cc.Call_Type__c+':'+cc.Sub_Type__c;
            }
            ev.StartDateTime = cc.Visit_Start_Date__c;
            ev.EndDateTime = cc.Visit_End_Date__c;
            ev.Type = cc.Call_Type__c;
            ev.OwnerId = cc.OwnerId;
            ev.WhatId = cc.Id;
            insertEvent.add(ev);            
        }
        }
        if(!insertEvent.isEmpty() && insertEvent.size()>0){
            database.insert(insertEvent);
        }
    }
    
    public static void updateHelper(List<Customer_Connect__c> newList, Map<Id,Customer_Connect__c> oldMap){
        List<Event> updateEvent = new List<Event>();
        Set<Id> accSetIds = new Set<Id>();
        Set<Id> leadSetIds = new Set<Id>();
        Set<Id> ccIds = new Set<Id>();
        List<Customer_Connect__c> cloneCustomerConnect = new List<Customer_Connect__c>();
        List<Customer_Connect__c> updateCustomerConnect = new List<Customer_Connect__c>();
        Map<Id,Event> evMap = new Map<Id,Event>();
        Boolean isChecked = false;
        Set<Id> ccIdsForEventDel = new Set<Id>();
        
        for(Customer_Connect__c acc : newList){
            if(acc.Customer_Code__c!=null){
                accSetIds.add(acc.Customer_Code__c);
            }if(acc.Lead__c!=null){
                leadSetIds.add(acc.Lead__c);
            }
            ccIds.add(acc.Id);
            if(acc.Visit_Status__c=='Postponed' && oldMap.get(acc.Id).Visit_Status__c!='Postponed'){
                if(oldMap.get(acc.Id).Visit_Start_Date__c==acc.Visit_Start_Date__c){
                    acc.Visit_Start_Date__c.addError('Please select new date in case of customer connect postponed.');
                    isChecked = true;                    
                }
            }
            if((acc.Visit_Status__c=='Postponed' && oldMap.get(acc.Id).Visit_Status__c!='Postponed') || (oldMap.get(acc.Id).Visit_Status__c!='Cancel' && acc.Visit_Status__c=='Cancel')){
                ccIdsForEventDel.add(acc.Id);
            }
        }
        
        List<Event> delEvent = [SELECT Id, Subject, StartDateTime, EndDateTime, Type, OwnerId, WhatId FROM Event WHERE WhatId IN:ccIdsForEventDel];
        if(!delEvent.isEmpty() && delEvent.size()>0){
            delete delEvent;
        }
        
        Map<Id,Account> mapOfAccount = new Map<ID, Account>([SELECT Id, Name FROM Account WHERE Id IN:accSetIds]);
        Map<Id,Lead> mapOfLead = new Map<ID, Lead>([SELECT Id, Name FROM Lead WHERE Id IN:leadSetIds]); 
        
        
        //Map<Id,Event> mapOfEvent = new Map<Id,Event>([SELECT Id, Subject, StartDateTime, EndDateTime, Type, OwnerId, WhatId FROM Event WHERE WhatId IN:ccIds]);
        //for(Event ev : mapOfEvent.values()){
           // evMap.put(ev.WhatId,ev);
        //}
        
        if(isChecked==false){
        for(Customer_Connect__c cc : newList){
            if(oldMap.get(cc.Id).Visit_Start_Date__c!= cc.Visit_Start_Date__c){
                Event ev = new Event();
                if(cc.Customer_Code__c!=null){
                    ev.Subject = mapOfAccount.get(cc.Customer_Code__c).Name+':'+cc.Call_Type__c+':'+cc.Sub_Type__c;
                }else{
                    ev.Subject = mapOfLead.get(cc.Lead__c).Name+':'+cc.Call_Type__c+':'+cc.Sub_Type__c;
                }
                ev.StartDateTime = cc.Visit_Start_Date__c;
                ev.EndDateTime = cc.Visit_End_Date__c;
                ev.Type = cc.Call_Type__c;
                ev.OwnerId = cc.OwnerId;
                ev.WhatId = cc.Id;
                updateEvent.add(ev);    
                System.debug('--- check 1--'+ev);
                
            }
            System.debug('-- insert event--'+updateEvent);
            //clone customer connect
            if(oldMap.get(cc.Id).Next_Visit_Date_Time__c!= cc.Next_Visit_Date_Time__c){
                Customer_Connect__c clone = new Customer_Connect__c();
                clone.Customer_Code__c = cc.Customer_Code__c;
                clone.Call_Type__c = cc.Call_Type__c;
                clone.Status_of_Discussion__c = cc.Status_of_Discussion__c;
                clone.Sub_Type__c = cc.Sub_Type__c;
                clone.Lead__c = cc.Lead__c;
                clone.Visit_Start_Date__c = cc.Next_Visit_Date_Time__c;
                clone.Visit_End_Date__c = cc.Next_Visit_Date_Time__c.addHours(1);
                clone.Expected_Closure_Date__c = cc.Expected_Closure_Date__c;
                clone.Day_Start_Km__c = cc.Day_Start_Km__c;
                clone.Day_End_Km__c = cc.Day_End_Km__c;
                clone.Closure_Remarks__c = cc.Closure_Remarks__c;
                clone.Created_Today__c = cc.Created_Today__c;
                clone.Key_Discussion_Description__c = cc.Key_Discussion_Description__c;
                clone.EmailBody__c = cc.EmailBody__c;
                
                cloneCustomerConnect.add(clone);
            }
            // update customer connect
            if(oldMap.get(cc.Id).Visit_Start_Date__c!=cc.Visit_Start_Date__c){
                Customer_Connect__c custConnectpdate = new Customer_Connect__c();
                custConnectpdate.Id = cc.Id;
                custConnectpdate.Customer_Code__c = cc.Customer_Code__c;
                custConnectpdate.Call_Type__c = cc.Call_Type__c;
                custConnectpdate.Status_of_Discussion__c = cc.Status_of_Discussion__c;
                custConnectpdate.Sub_Type__c = cc.Sub_Type__c;
                custConnectpdate.Lead__c = cc.Lead__c;
                custConnectpdate.Visit_Start_Date__c = cc.Visit_Start_Date__c;
                custConnectpdate.Visit_End_Date__c = cc.Visit_End_Date__c;
                custConnectpdate.Expected_Closure_Date__c = cc.Expected_Closure_Date__c;
                custConnectpdate.Day_Start_Km__c = cc.Day_Start_Km__c;
                custConnectpdate.Day_End_Km__c = cc.Day_End_Km__c;
                custConnectpdate.Closure_Remarks__c = cc.Closure_Remarks__c;
                custConnectpdate.Created_Today__c = cc.Created_Today__c;
                //clone.loc__c = cc.loc__c;
                custConnectpdate.Key_Discussion_Description__c = cc.Key_Discussion_Description__c;
                custConnectpdate.EmailBody__c = cc.EmailBody__c;
                custConnectpdate.Visit_Status__c = cc.Visit_Status__c;
                
                updateCustomerConnect.add(custConnectpdate);
            }
            
            
        } 
        if(!updateEvent.isEmpty() && updateEvent.size()>0){
            database.insert(updateEvent);
        }
        if(!updateCustomerConnect.isEmpty() && updateCustomerConnect.size()>0){
            database.update(updateCustomerConnect);
        }
        if(!cloneCustomerConnect.isEmpty() && cloneCustomerConnect.size()>0){
            insert cloneCustomerConnect;
            
        }
        }
    }
    
    public static void deleteEventHelper(List<Customer_Connect__c> oldList){
        Set<Id> delccIds = new Set<Id>();
        for(Customer_Connect__c delcc:oldList){
            delccIds.add(delcc.Id);
        }
        
        List<Event> listOfEvent =[SELECT Id, Subject FROM Event WHERE WhatId IN:delccIds];
        if(!listOfEvent.isEmpty() && listOfEvent.size()>0){
            database.delete(listOfEvent);
        }
    }
    
    @AuraEnabled
    public static String getCustomerConnect(String eventId){
        String customerId = [SELECT Id,WhatId FROM EVENT WHERE Id=:eventId].WhatId;
        return customerId;
    }
    
    @AuraEnabled
    public static String updatEventData(String recordId, String visited){
        Event evt = [SELECT Id, Visited__c,WhatId FROM Event WHERE Id=:recordId];
        Customer_Connect__c custConnect= [SELECT Id, Visit_Status__c FROM Customer_Connect__c WHERE Id=:evt.WhatId];
        System.debug('--- check data--'+custConnect);
        if(evt!=null){
            evt.Visited__c = visited; 
            try{
                update evt;
            }catch(Exception ex){
                System.debug('--- errro--'+ex.getMessage()+ex.getLineNumber());
            }
            if(custConnect!=null){
                custConnect.Visit_Status__c = visited;
                try{
                    update custConnect;
                }catch(Exception ex){
                    System.debug('--- error occur when Customer connect update--'+ex.getMessage()+ex.getLineNumber());
                }
            }
            return evt.WhatId;
        }else{
            return 'Error';
        }
    }
    
    public static void updateCustomer360(List<Customer_Connect__c> customerConnectData){
        Set<Id> customerCodes = new Set<Id>();
        Map<Id,List<Customer_Connect__c>> accountToCustomerConnects = new Map<Id,List<Customer_Connect__c>>();
        String monthYear = System.now().format('MMMM').substring(0,3).toUpperCase()+'-'+System.now().year();
        List<Customer360__c> listToUpdate = new List<Customer360__c>();
        
        for(Customer_Connect__c cc : customerConnectData){
            if(cc.Customer_Code__c != null){
                customerCodes.add(cc.Customer_Code__c);
            }
        }
        if(customerCodes != null && customerCodes.size()>0){
            List<Customer_Connect__c> customerConnects = [SELECT Id,Check_In_Time__c,Customer_Code__c,Month_Year__c,LastModifiedById 
                                                          FROM Customer_Connect__c 
                                                          WHERE Month_Year__c =: monthYear 
                                                          AND Customer_Code__c IN: customerCodes 
                                                          AND Check_In_Time__c != null 
                                                          ORDER BY Check_In_Time__c DESC
                                                         ];
            List<Customer360__c> customer360Data = [SELECT Month_Year__c,Visits__c,Last_Visited_By__c,Last_Visit_DateTime__c,Customer_Code__c 
                                                    FROM Customer360__c 
                                                    WHERE MonthYear__c =: monthYear 
                                                    AND Customer_Code__c IN: customerCodes
                                                   ];
            if(customerConnects != null && customerConnects.size()>0){
                for(Customer_Connect__c c : customerConnects){
                    if(accountToCustomerConnects.containsKey(c.Customer_Code__c)){
                        accountToCustomerConnects.get(c.Customer_Code__c).add(c);
                    }
                    else{
                        accountToCustomerConnects.put(c.Customer_Code__c,new List<Customer_Connect__c>{c});
                    }
                }
            }
            if(customer360Data != null && customer360Data.size()>0 && accountToCustomerConnects != null){
                for(Customer360__c cus : customer360Data){
                    if(accountToCustomerConnects.containsKey(cus.Customer_Code__c)){
                        cus.Last_Visit_DateTime__c = accountToCustomerConnects.get(cus.Customer_Code__c)[0].Check_In_Time__c;
                        cus.Last_Visited_By__c = accountToCustomerConnects.get(cus.Customer_Code__c)[0].LastModifiedById;
                        cus.Visits__c = accountToCustomerConnects.get(cus.Customer_Code__c).size();
                        cus.Last_Connect__c = accountToCustomerConnects.get(cus.Customer_Code__c)[0].Id;
                        listToUpdate.add(cus);
                    }
                }
            }
            if(listToUpdate != null && listToUpdate.size()>0){
                update listToUpdate;
            }
        }
    }
}