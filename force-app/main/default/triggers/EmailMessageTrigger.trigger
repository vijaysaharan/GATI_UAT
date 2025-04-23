trigger EmailMessageTrigger on EmailMessage (after insert,before insert,after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        try{
            EmailMessageTriggerHandler.createNewCaseForClosedCase(Trigger.new);
        }catch(Exception e){}
    }
    
    if(Trigger.isAfter && Trigger.isInsert){        
        try{
            EmailMessageTriggerHandler.updateFirstResponseOnCase(Trigger.new);
            EmailMessageTriggerHandler.updateEmailAddressInCase(Trigger.new);
            EmailMessageTriggerHandler.sendNotificationOnEmailReply(Trigger.new);
            EmailMessageTriggerHandler.updateAnaliticsOnCase(Trigger.new);
            EmailMessageTriggerHandler.deleteOlderEmailMessages(Trigger.new);
        }catch(Exception e){}
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        EmailMessageTriggerHandler.verifyStatusChange(Trigger.new, Trigger.oldMap);
    }
}