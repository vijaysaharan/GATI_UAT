trigger Customer360Trigger on Customer360__c (after insert, after update) {
    if(System.Label.Customer_360_Trigger_Handle=='True'){
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) && checkRecurisveRun.rurnCustomer360Batch==true){
            checkRecurisveRun.rurnCustomer360Batch = false;
            Set<Id> customer360Ids = new Set<Id>();
            for(Customer360__c cc : Trigger.new){
                customer360Ids.add(cc.Id);
            }
            if(!customer360Ids.isEmpty() && customer360Ids.size()>0){
                TargetUpdateOnCustomer360Batch.startCustMethod(customer360Ids);
            }
        }
    }
    
}