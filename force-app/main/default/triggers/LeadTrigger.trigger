trigger LeadTrigger on Lead (before insert, after insert, after update) {       
    if(Trigger.isBefore && Trigger.isInsert){
        LeadTriggerHelperForCrossSell.duplicatePreventExceptCrossSell(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert){
        LeadTriggerHelperForCrossSell.approvalLockToLeads(Trigger.new);
        if(System.Label.Cross_Sell_Notification=='Active' || Test.isRunningTest()){
            LeadTriggerHelperForCrossSell.sendEmailNotification(Trigger.new);
        }  
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        LeadTriggerHelperForCrossSell.handleRevisitNotificationAndConversion(Trigger.new);
        if(System.Label.Cross_Sell_Notification=='Active' || Test.isRunningTest()){
            LeadTriggerHelperForCrossSell.sendEmailNotificationOwnerChange(Trigger.new,Trigger.oldMap);
        } 
    }
}