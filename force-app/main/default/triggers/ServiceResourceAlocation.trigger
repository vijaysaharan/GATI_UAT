trigger ServiceResourceAlocation on AccountTeamMember (before insert, before delete ) {
    if(Trigger.isBefore && Trigger.isInsert){
        ServiceResourceTriggerHelper.serviceResourceAllocation(Trigger.New);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        ServiceResourceTriggerHelper.mapCustomerCodeToStaffCode(Trigger.oldMap.keySet());
    }    
}