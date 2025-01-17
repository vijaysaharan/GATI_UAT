public with sharing class UpdateSalesDashboardUsers implements Schedulable {
    public void execute (SchedulableContext sc){
        Set<String> userIds = new Set<String>();
        Set<String> newUsers = new Set<String>();

        List<SalesDashboardUser__c> salesUser = [SELECT UserList__c 
                                                    FROM SalesDashboardUser__c 
                                                    WHERE StartDate__c <=: System.today() 
                                                    AND EndDate__c >=: System.today()
                                                    LIMIT 1
                                                ];
        if(salesUser != null && salesUser.size() > 0){
            for(String us : salesUser[0].UserList__c.split(',')){
                userIds.add(us);   
            }
        }

        List<Lead> newLeadCreated = [SELECT Id, OwnerId FROM Lead WHERE CreatedDate >= YESTERDAY];
        List<Opportunity> newOpportunityCreated = [SELECT Id, OwnerId FROM Opportunity WHERE CreatedDate >= YESTERDAY];
        List<Customer_Connect__c> newCustomerConnectCreated = [SELECT Id, OwnerId FROM Customer_Connect__c WHERE CreatedDate >= YESTERDAY];
        List<Sales_KRA__c> newSalesKRACreated = [SELECT Id, KAM_KAE__c FROM Sales_KRA__c WHERE CreatedDate >= YESTERDAY];

        if(newLeadCreated != null && newLeadCreated.size() > 0){
            for(Lead ld : newLeadCreated){
                if(ld.OwnerId != null && !userIds.contains(ld.OwnerId)){
                    newUsers.add(ld.OwnerId);
                }
            }
        }
        if(newOpportunityCreated != null && newOpportunityCreated.size() > 0){
            for(Opportunity opp : newOpportunityCreated){
                if(opp.OwnerId != null && !userIds.contains(opp.OwnerId)){
                    newUsers.add(opp.OwnerId);
                }
            }
        }
        if(newCustomerConnectCreated != null && newCustomerConnectCreated.size() > 0){
            for(Customer_Connect__c cc : newCustomerConnectCreated){
                if(cc.OwnerId != null && !userIds.contains(cc.OwnerId)){
                    newUsers.add(cc.OwnerId);
                }
            }
        }
        if(newSalesKRACreated != null && newSalesKRACreated.size() > 0){
            for(Sales_KRA__c sKRA : newSalesKRACreated){
                if(sKRA.KAM_KAE__c != null && !userIds.contains(sKRA.KAM_KAE__c)){
                    newUsers.add(sKRA.KAM_KAE__c);
                }
            }
        }

        if(newUsers != null && newUsers.size()>0){
            for(String us : newUsers){
                salesUser[0].UserList__c += ','+us;
            }
            update salesUser[0];
        }
    }
}