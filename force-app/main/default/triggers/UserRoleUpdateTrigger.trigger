trigger UserRoleUpdateTrigger on User (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        //UserRoleUpdateTriggerHandler.updateRoleNotification(Trigger.oldMap,Trigger.new);
    }
}