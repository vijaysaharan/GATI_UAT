trigger TargetOwnerAssignTrigger on Sales_KRA__c (before insert,before update) {
    if(Trigger.isBefore && Trigger.isInsert){
        TargetOwnerAssignTriggerHandler.targetOwnerAssign(trigger.new);
    }
}